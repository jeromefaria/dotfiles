#!/bin/bash
# Audio backup service controller — launchd lifecycle + manual + wizard.
#
# Mirrors the manage-sync.sh pattern from the mail-sync setup, extended
# with audio-specific gates (mount check, trusted-router allowlist, hotspot
# detection) and a wizard for first-time setup. Usually invoked via the
# `audio-backup` shell alias defined in dotfiles/terminal/zsh/aliases/macos.sh.
#
# Usage:
#   audio-backup start              Enable the nightly schedule
#   audio-backup stop               Disable the schedule
#   audio-backup restart            Reload schedule (after config edits)
#   audio-backup status             Show service state + last sync
#   audio-backup logs               Tail recent sync logs
#   audio-backup verify             Check the Drive backup matches the source
#   audio-backup regenerate-filters Rebuild audio-backup-filters.txt from the conf
#   audio-backup prune [--dry-run]  Delete version folders older than retention
#   audio-backup now [opts]         Run sync manually right now (passes opts to sync.sh)
#   audio-backup now --dry-run      Preview transfer
#   audio-backup now --force        Bypass router allowlist (warns on hotspot)
#   audio-backup now --force --yes  Bypass and skip the hotspot warn
#   audio-backup wizard             Interactive run (gates, dry-run, confirm, sync)
#   audio-backup wizard --setup     First-time setup (rclone config, router, plist)
#
# Off-device working copy (Audio drive may be disconnected for pull, must be
# connected for push):
#   audio-backup pull <remote-rel-path> <local-dest>
#                                   Download a folder/file from Drive to a
#                                   local path you choose. No Audio drive
#                                   required.
#   audio-backup push <local-src> <remote-rel-path> [--yes]
#                                   Sync local changes back to the Audio drive
#                                   (drive must be mounted). Shows a dry-run
#                                   diff, prompts to confirm. Next nightly
#                                   backup then reflects to Drive.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${AUDIO_BACKUP_CONFIG:-${SCRIPT_DIR}/audio-backup.conf}"
SYNC_SCRIPT="${SCRIPT_DIR}/audio-backup-sync.sh"

# ─── Network detection helper ──────────────────────────────────────────
# Network identity is established via the Wi-Fi service's router IP.
# macOS Tahoe (and Sonoma 14.4+) redacts SSID/BSSID from every user-space
# API without Location Services. Router IP is permission-free and also
# VPN-immune (the system default gateway is hijacked by a tunnel; this
# Wi-Fi-specific router IP is not).
current_wifi_router() {
  networksetup -getinfo Wi-Fi 2>/dev/null | awk -F': ' '/^Router:/{print $2; exit}'
}

is_trusted_router() {
  local router="$1"
  [ -z "$router" ] && return 1
  for allowed in "${TRUSTED_ROUTER_ALLOWLIST[@]}"; do
    [ "$router" = "$allowed" ] && return 0
  done
  return 1
}

if [ ! -f "$CONFIG" ]; then
  echo "ERROR: config not found at $CONFIG" >&2
  exit 1
fi
# shellcheck disable=SC1090
source "$CONFIG"

# Shared TTY-aware colors + launchd service primitives
source "${SCRIPT_DIR}/lib/io.sh"
source "${SCRIPT_DIR}/lib/launchd-svc.sh"

usage() {
  # Print the leading comment block (everything after the shebang up to the
  # first non-comment, non-blank line) with the leading "# " stripped.
  awk 'NR==1{next} /^#/{sub(/^# ?/,""); print; next} /^[[:space:]]*$/{next} {exit}' "$0"
}

# ─── Helper: generate launchd plist from config ────────────────────────
generate_plist() {
  mkdir -p "$(dirname "$LAUNCHD_PLIST")"
  local watch_path; watch_path="$(dirname "$SOURCE")"   # Audio drive mount point
  cat > "$LAUNCHD_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${LAUNCHD_LABEL}</string>

    <key>ProgramArguments</key>
    <array>
        <string>${SYNC_SCRIPT}</string>
    </array>

    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>${SCHEDULE_HOUR}</integer>
        <key>Minute</key>
        <integer>${SCHEDULE_MINUTE}</integer>
    </dict>

    <!-- Also fire when the Audio drive is (re)mounted, so a nightly run missed
         because the drive was disconnected catches up as soon as it reappears. -->
    <key>WatchPaths</key>
    <array>
        <string>${watch_path}</string>
    </array>

    <key>RunAtLoad</key>
    <false/>

    <key>StandardOutPath</key>
    <string>${LOG_DIR}/launchd.out.log</string>

    <key>StandardErrorPath</key>
    <string>${LOG_DIR}/launchd.err.log</string>

    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
</dict>
</plist>
EOF
}

# ─── Subcommands ───────────────────────────────────────────────────────
cmd_start() {
  [ -f "$LAUNCHD_PLIST" ] || { echo -e "${RED}❌ Plist not found at $LAUNCHD_PLIST.${NC}"; echo "Run: $0 wizard --setup"; return 1; }
  echo -e "${BLUE}Starting $LAUNCHD_LABEL...${NC}"
  if svc_start "$LAUNCHD_PLIST" "$LAUNCHD_LABEL"; then
    echo -e "${GREEN}✅ Service started — backup will run daily at ${SCHEDULE_HOUR}:$(printf "%02d" "$SCHEDULE_MINUTE")${NC}"
  else
    echo -e "${RED}❌ Failed to start${NC}"
    return 1
  fi
}

cmd_stop() {
  echo -e "${BLUE}Stopping $LAUNCHD_LABEL...${NC}"
  if svc_stop "$LAUNCHD_PLIST" "$LAUNCHD_LABEL"; then
    echo -e "${GREEN}✅ Service stopped${NC}"
  else
    echo -e "${RED}❌ Failed to stop${NC}"
    return 1
  fi
}

cmd_restart() {
  cmd_stop
  sleep 1
  cmd_start
}

cmd_status() {
  echo -e "${BLUE}$LAUNCHD_LABEL status:${NC}"
  if svc_is_loaded "$LAUNCHD_LABEL"; then
    echo -e "${GREEN}✅ Service loaded (scheduled daily at ${SCHEDULE_HOUR}:$(printf "%02d" "$SCHEDULE_MINUTE"))${NC}"
  else
    echo -e "${YELLOW}⚪ Service not loaded${NC}"
  fi
  echo ""
  echo "─── Last sync log ───"
  local latest
  latest=$(ls -t "$LOG_DIR"/audio-backup-*.log 2>/dev/null | head -1)
  if [ -n "$latest" ]; then
    echo "$latest:"
    tail -20 "$latest"
  else
    echo "No logs yet."
  fi
}

cmd_logs() {
  local latest
  latest=$(ls -t "$LOG_DIR"/audio-backup-*.log 2>/dev/null | head -1)
  echo -e "${BLUE}Recent sync log:${NC} $latest"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  if [ -n "$latest" ]; then
    tail -50 "$latest"
  else
    echo "No logs found."
  fi
  echo ""
  if [ -f "${LOG_DIR}/launchd.err.log" ] && [ -s "${LOG_DIR}/launchd.err.log" ]; then
    echo -e "${RED}─── launchd stderr ───${NC}"
    tail -20 "${LOG_DIR}/launchd.err.log"
  fi
}

cmd_now() {
  echo -e "${BLUE}Running sync manually...${NC}"
  exec "$SYNC_SCRIPT" "$@"
}

cmd_wizard() {
  local setup=0
  if [ "${1:-}" = "--setup" ]; then setup=1; shift; fi

  if [ "$setup" -eq 1 ]; then
    wizard_setup
  else
    wizard_interactive
  fi
}

wizard_setup() {
  local bar="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "$bar"
  echo " Audio Backup — First-Time Setup"
  echo "$bar"
  echo ""

  # 1. rclone installed?
  if ! command -v rclone &> /dev/null; then
    echo -e "${RED}✗ rclone not installed.${NC}"
    echo "  Install: brew install rclone"
    return 1
  fi
  echo -e "${GREEN}✓ rclone installed${NC} ($(rclone version | head -1))"

  # 2. rclone remote configured?
  if rclone listremotes | grep -q "^${RCLONE_REMOTE}:$"; then
    echo -e "${GREEN}✓ rclone remote '${RCLONE_REMOTE}:' configured${NC}"
  else
    echo -e "${YELLOW}⚠ rclone remote '${RCLONE_REMOTE}:' NOT configured.${NC}"
    echo "  Need to run interactive OAuth setup. Recipe:"
    echo "    rclone config"
    echo "    n) New remote"
    echo "    name> ${RCLONE_REMOTE}"
    echo "    Storage> drive"
    echo "    client_id, client_secret> (blank for default; OK for personal use)"
    echo "    scope> 1 (full access)"
    echo "    root_folder_id> blank"
    echo "    service_account_file> blank"
    echo "    Edit advanced config> n"
    echo "    Use auto config> y (opens browser)"
    echo "    Configure as Shared Drive> n"
    echo ""
    read -r -p "Run 'rclone config' now? [Y/n]: " ans
    if [[ ! "$ans" =~ ^[Nn]$ ]]; then
      rclone config
    fi
    if ! rclone listremotes | grep -q "^${RCLONE_REMOTE}:$"; then
      echo -e "${RED}✗ Remote still not configured. Aborting setup.${NC}"
      return 1
    fi
  fi

  # 3. Current Wi-Fi router — offer as allowlist seed
  local router
  router="$(current_wifi_router)"
  echo ""
  echo "Current Wi-Fi router: ${router:-<not on Wi-Fi>}"
  echo "Configured trusted-router allowlist (from audio-backup.conf):"
  for r in "${TRUSTED_ROUTER_ALLOWLIST[@]}"; do echo "  • $r"; done
  if [ -n "$router" ] && ! is_trusted_router "$router"; then
    echo -e "${YELLOW}⚠ Current router '$router' is NOT in the allowlist.${NC}"
    echo "  Edit ${CONFIG} to add it (or replace the placeholder)."
  fi

  # 4. Filters file
  if [ -f "$FILTERS_FILE" ]; then
    echo -e "${GREEN}✓ Filters file present${NC} ($FILTERS_FILE)"
  else
    echo -e "${RED}✗ Filters file missing at $FILTERS_FILE${NC}"
    return 1
  fi

  # 5. Log dir
  mkdir -p "$LOG_DIR"
  echo -e "${GREEN}✓ Log dir ready${NC} ($LOG_DIR)"

  # 6. Dry-run
  echo ""
  read -r -p "Run a dry-run preview now? [Y/n]: " ans
  if [[ ! "$ans" =~ ^[Nn]$ ]]; then
    "$SYNC_SCRIPT" --dry-run
  fi

  # 7. Generate plist + offer to enable
  echo ""
  echo "Schedule (from config): daily at ${SCHEDULE_HOUR}:$(printf "%02d" "$SCHEDULE_MINUTE")"
  read -r -p "Generate launchd plist + enable nightly schedule? [Y/n]: " ans
  if [[ ! "$ans" =~ ^[Nn]$ ]]; then
    generate_plist
    echo -e "${GREEN}✓ Plist written${NC} ($LAUNCHD_PLIST)"
    cmd_start
  fi

  echo ""
  echo "$bar"
  echo " Setup complete."
  echo "$bar"
  echo ""
  echo "Useful next commands:"
  echo "  $0 status               # check service"
  echo "  $0 now --dry-run        # preview a run"
  echo "  $0 logs                 # tail logs"
  echo "  $0 wizard               # interactive sync"
}

wizard_interactive() {
  local bar="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "$bar"
  echo " Audio Backup — Interactive Run"
  echo "$bar"
  echo ""

  echo "─── Pre-flight ───"
  local issues=0

  # Mount
  if [ -f "$SENTINEL" ]; then
    echo -e "${GREEN}✓ Source mounted${NC}"
  else
    echo -e "${RED}✗ Source not mounted (sentinel $SENTINEL missing)${NC}"
    issues=$((issues+1))
  fi

  # Wi-Fi router (not the system default gateway — VPN would mask it)
  local wifi_router
  wifi_router="$(current_wifi_router)"
  echo "  Wi-Fi router: ${wifi_router:-<not on Wi-Fi>}"
  local trusted=0
  is_trusted_router "$wifi_router" && trusted=1
  if [[ "$wifi_router" == ${HOTSPOT_GATEWAY_PATTERN}* ]]; then
    echo -e "${YELLOW}⚠ iPhone hotspot detected${NC}"
  elif [ "$trusted" -eq 1 ]; then
    echo -e "${GREEN}✓ Trusted network${NC}"
  else
    echo -e "${YELLOW}⚠ Untrusted network (will need --force)${NC}"
  fi

  if [ $issues -gt 0 ]; then
    echo -e "${RED}Cannot proceed: source drive not mounted.${NC}"
    return 1
  fi

  echo ""
  echo "─── Dry-run preview ───"
  "$SYNC_SCRIPT" --dry-run --force --yes

  echo ""
  read -r -p "Run the actual sync now? [y/N]: " ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    if [ "$trusted" -eq 1 ]; then
      "$SYNC_SCRIPT"
    else
      "$SYNC_SCRIPT" --force --yes
    fi
  else
    echo "Cancelled."
  fi
}

# ─── Off-device working copy: pull / push ──────────────────────────────
cmd_pull() {
  local remote_path="${1:-}"
  local local_dest="${2:-}"

  if [ -z "$remote_path" ] || [ -z "$local_dest" ]; then
    echo "Usage: $0 pull <remote-rel-path> <local-dest>" >&2
    echo "  e.g. $0 pull \"Projects/Albums/MyAlbum\" ~/work/MyAlbum" >&2
    return 1
  fi

  if ! command -v rclone &> /dev/null; then
    echo -e "${RED}✗ rclone not installed.${NC}" >&2
    return 1
  fi
  if ! rclone listremotes | grep -q "^${RCLONE_REMOTE}:$"; then
    echo -e "${RED}✗ rclone remote '${RCLONE_REMOTE}:' not configured.${NC}" >&2
    return 1
  fi
  if [ ! -f "$FILTERS_FILE" ]; then
    echo -e "${RED}✗ Filters file not found at $FILTERS_FILE${NC}" >&2
    return 1
  fi

  local src="${RCLONE_REMOTE}:${RCLONE_DEST_PATH}/${remote_path}"
  echo -e "${BLUE}Pulling${NC} $src"
  echo -e "    ${BLUE}→${NC} $local_dest"
  mkdir -p "$(dirname "$local_dest")"

  # Probe whether source is a file or a directory. rclone refuses ANY filter
  # flag (--exclude, --filter-from, etc.) on a single-file source, so we have
  # to skip excludes when pulling a file.
  local rclone_filters=()
  if rclone lsjson --stat "$src" 2>/dev/null | grep -q '"IsDir": *true'; then
    # Directory: build rclone-style excludes from LIVE_JUNK_* in audio-backup.conf.
    # (Not using --filter-from because the nightly filter file is anchored
    # at the drive root and breaks when applied to a sub-path.)
    local d g
    for d in "${LIVE_JUNK_DIRS[@]}"; do
      rclone_filters+=(--exclude="${d}/**")
    done
    for g in "${LIVE_JUNK_GLOBS[@]}"; do
      rclone_filters+=(--exclude="${g}")
    done
  fi

  # copyto (not copy): preserves exact destination path semantics for both
  # files and directories. Plain `copy` nests files inside a dir at the
  # given path, which is not what users expect.
  # ${arr[@]+...} idiom: safely expand even when array is empty under `set -u`.
  if rclone copyto "$src" "$local_dest" \
       ${rclone_filters[@]+"${rclone_filters[@]}"} \
       --progress; then
    echo -e "${GREEN}✓ Pull complete${NC}"
    echo "  When ready to merge back: $0 push \"$local_dest\" \"$remote_path\""
    return 0
  else
    echo -e "${RED}✗ Pull failed${NC}" >&2
    return 1
  fi
}

cmd_push() {
  local local_src=""
  local remote_path=""
  local skip_confirm=0

  while [ $# -gt 0 ]; do
    case "$1" in
      --yes|-y) skip_confirm=1; shift ;;
      *)
        if   [ -z "$local_src" ];   then local_src="$1"
        elif [ -z "$remote_path" ]; then remote_path="$1"
        else echo "Unexpected argument: $1" >&2; return 1
        fi
        shift
        ;;
    esac
  done

  if [ -z "$local_src" ] || [ -z "$remote_path" ]; then
    echo "Usage: $0 push <local-src> <remote-rel-path> [--yes]" >&2
    echo "  e.g. $0 push ~/work/MyAlbum \"Projects/Albums/MyAlbum\"" >&2
    return 1
  fi

  if [ ! -e "$local_src" ]; then
    echo -e "${RED}✗ Local source not found: $local_src${NC}" >&2
    return 1
  fi
  if [ ! -f "$SENTINEL" ]; then
    echo -e "${RED}✗ Audio drive not mounted (sentinel $SENTINEL missing).${NC}" >&2
    echo "  Push requires the Audio drive to be connected." >&2
    return 1
  fi
  if [ ! -f "$FILTERS_FILE" ]; then
    echo -e "${RED}✗ Filters file not found at $FILTERS_FILE${NC}" >&2
    return 1
  fi

  local target="${SOURCE}/${remote_path}"
  local rsync_src="$local_src"
  local rsync_dst="$target"
  local target_existed=1
  [ -e "$target" ] || target_existed=0

  # Folder push needs trailing slashes for rsync's "copy contents" semantics
  if [ -d "$local_src" ]; then
    rsync_src="${local_src%/}/"
    rsync_dst="${target%/}/"
  fi

  # Build rsync-style excludes from LIVE_JUNK_* (same source of truth as
  # cmd_pull). rsync wants trailing `/` on dir patterns, no trailing `**`.
  local rsync_excludes=()
  local d g
  for d in "${LIVE_JUNK_DIRS[@]}"; do
    rsync_excludes+=(--exclude="${d}/")
  done
  for g in "${LIVE_JUNK_GLOBS[@]}"; do
    rsync_excludes+=(--exclude="${g}")
  done

  echo -e "${BLUE}── Dry-run preview ──${NC}"
  if [ "$target_existed" -eq 0 ]; then
    echo -e "${YELLOW}⚠ Target does not exist on Audio drive — push will CREATE: $target${NC}"
  fi
  rsync -a --dry-run --itemize-changes "${rsync_excludes[@]}" \
    "$rsync_src" "$rsync_dst" | head -40

  echo ""
  if [ "$skip_confirm" -eq 0 ]; then
    read -r -p "Proceed with push? [y/N]: " ans
    if [[ ! "$ans" =~ ^[Yy]$ ]]; then
      echo "Aborted."
      return 0
    fi
  fi

  mkdir -p "$(dirname "$target")"
  if rsync -a --info=stats2 "${rsync_excludes[@]}" "$rsync_src" "$rsync_dst"; then
    echo -e "${GREEN}✓ Push complete${NC} → $target"
  else
    echo -e "${RED}✗ Push failed${NC}" >&2
    return 1
  fi

  echo ""
  if [ "$skip_confirm" -eq 0 ]; then
    read -r -p "Delete local source ($local_src)? [y/N]: " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      rm -rf "$local_src"
      echo -e "${GREEN}✓ Deleted local source${NC}"
    else
      echo "  (kept — delete manually when ready)"
    fi
  fi

  echo ""
  echo "The next nightly backup run will reflect this to Drive."
}

# ─── Regenerate the rclone filter file from the conf arrays (single source) ─
cmd_regenerate_filters() {
  {
    echo "# rclone --filter-from rules for the Audio drive backup."
    echo "#"
    echo "# GENERATED from audio-backup.conf (LIVE_JUNK_*, MACOS_CLUTTER, SCOPE_INCLUDE)."
    echo "# Do NOT edit by hand — edit the conf, then run: audio-backup regenerate-filters"
    echo "#"
    echo "# Order matters: first match wins.  '+' include  '-' exclude  '**' any depth."
    echo ""
    echo "# ─── Live regeneratable artefacts inside projects (recreated by Live) ─"
    for d in "${LIVE_JUNK_DIRS[@]}"; do echo "- Projects/**/${d}/**"; done
    echo ""
    echo "# ─── Loose junk globs anywhere in the tree ───────────────────────────"
    for g in "${LIVE_JUNK_GLOBS[@]}"; do echo "- **/${g}"; done
    echo ""
    echo "# ─── Extra macOS filesystem clutter ──────────────────────────────────"
    for c in "${MACOS_CLUTTER[@]}"; do echo "- **/${c}"; done
    echo ""
    echo "# ─── Include the in-scope top-level folders ───────────────────────────"
    for s in "${SCOPE_INCLUDE[@]}"; do echo "+ ${s}"; done
    echo ""
    echo "# ─── Exclude everything else (Libraries/, Samples/, …) ────────────────"
    echo "- *"
  } > "$FILTERS_FILE"
  echo -e "${GREEN}✓ Regenerated${NC} $FILTERS_FILE from audio-backup.conf"
}

# ─── Verify the Drive backup matches the (filtered) source ─────────────
cmd_verify() {
  if ! command -v rclone &>/dev/null; then
    echo -e "${RED}rclone not installed${NC}" >&2; return 1
  fi
  local dest="${RCLONE_REMOTE}:${RCLONE_DEST_PATH}"
  echo -e "${BLUE}Verifying${NC} $SOURCE  →  $dest  (filtered, one-way)…"
  # --one-way: only flag source files missing/different at dest; ignore extra
  # dest files (older versions, backup-dir contents), which are expected.
  rclone check "$SOURCE" "$dest" --filter-from "$FILTERS_FILE" --one-way "$@"
}

# ─── Prune version folders older than the retention window ─────────────
# Deletes whole Audio-versions/<YYYY-MM-DD> folders by their date (lexical ==
# chronological), NOT by file mtime — so "90 days retention" keeps 90 days of
# history regardless of how old the versioned files' contents are.
cmd_prune() {
  local dry=0
  [ "${1:-}" = "--dry-run" ] && dry=1
  if ! command -v rclone &>/dev/null; then
    echo -e "${RED}rclone not installed${NC}" >&2; return 1
  fi
  local days="${VERSION_RETENTION_DAYS:-90}"
  local versions="${RCLONE_REMOTE}:${RCLONE_VERSIONS_PATH}"
  local cutoff
  cutoff="$(date -v-"${days}"d +%Y-%m-%d 2>/dev/null)" || cutoff="$(date -d "-${days} days" +%Y-%m-%d 2>/dev/null)"
  if [ -z "$cutoff" ]; then echo -e "${RED}could not compute cutoff date${NC}" >&2; return 1; fi

  echo -e "${BLUE}Prune${NC} $versions — removing version folders dated before $cutoff (retention ${days}d)"
  local removed=0
  while IFS= read -r d; do
    d="${d%/}"
    [[ "$d" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || continue   # only dated folders
    if [[ "$d" < "$cutoff" ]]; then
      if [ "$dry" -eq 1 ]; then
        echo "  would remove  $d"
      else
        rclone purge "${versions}/${d}" 2>/dev/null && echo "  removed  $d"
      fi
      removed=$((removed + 1))
    fi
  done < <(rclone lsf --dirs-only "$versions" 2>/dev/null)

  if [ "$removed" -eq 0 ]; then
    echo -e "  ${GREEN}nothing to prune${NC} (no version folders older than $cutoff)"
  elif [ "$dry" -eq 1 ]; then
    echo -e "  ${YELLOW}$removed folder(s) would be removed${NC} (dry-run)"
  else
    echo -e "  ${GREEN}✓ pruned $removed folder(s)${NC}"
  fi
}

# ─── Dispatch ──────────────────────────────────────────────────────────
# Guarded so tests can source the file to call cmd_* / generate_plist
# directly without triggering the case dispatch.
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
  return 0
fi

case "${1:-}" in
  start)    shift; cmd_start "$@" ;;
  stop)     shift; cmd_stop "$@" ;;
  restart)  shift; cmd_restart "$@" ;;
  status)   shift; cmd_status "$@" ;;
  logs)     shift; cmd_logs "$@" ;;
  now)      shift; cmd_now "$@" ;;
  wizard)   shift; cmd_wizard "$@" ;;
  pull)     shift; cmd_pull "$@" ;;
  push)     shift; cmd_push "$@" ;;
  verify)   shift; cmd_verify "$@" ;;
  regenerate-filters|filters) shift; cmd_regenerate_filters "$@" ;;
  prune)    shift; cmd_prune "$@" ;;
  ""|-h|--help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown command: $1" >&2
    echo ""
    usage
    exit 1
    ;;
esac
