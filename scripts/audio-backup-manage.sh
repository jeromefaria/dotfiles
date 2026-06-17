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
#   audio-backup now [opts]         Run sync manually right now (passes opts to sync.sh)
#   audio-backup now --dry-run      Preview transfer
#   audio-backup now --force        Bypass router allowlist (warns on hotspot)
#   audio-backup now --force --yes  Bypass and skip the hotspot warn
#   audio-backup wizard             Interactive run (gates, dry-run, confirm, sync)
#   audio-backup wizard --setup     First-time setup (rclone config, router, plist)

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${SCRIPT_DIR}/audio-backup.conf"
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

# Colors
if [ -t 1 ]; then
  GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
else
  GREEN=''; BLUE=''; YELLOW=''; RED=''; NC=''
fi

usage() {
  # Print the leading comment block (everything after the shebang up to the
  # first non-comment, non-blank line) with the leading "# " stripped.
  awk 'NR==1{next} /^#/{sub(/^# ?/,""); print; next} /^[[:space:]]*$/{next} {exit}' "$0"
}

# ─── Helper: generate launchd plist from config ────────────────────────
generate_plist() {
  mkdir -p "$(dirname "$LAUNCHD_PLIST")"
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
  launchctl load "$LAUNCHD_PLIST" 2>/dev/null
  if launchctl list | grep -q "$LAUNCHD_LABEL"; then
    echo -e "${GREEN}✅ Service started — backup will run daily at ${SCHEDULE_HOUR}:$(printf "%02d" "$SCHEDULE_MINUTE")${NC}"
  else
    echo -e "${RED}❌ Failed to start${NC}"
    return 1
  fi
}

cmd_stop() {
  echo -e "${BLUE}Stopping $LAUNCHD_LABEL...${NC}"
  launchctl unload "$LAUNCHD_PLIST" 2>/dev/null
  if ! launchctl list | grep -q "$LAUNCHD_LABEL"; then
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
  if launchctl list | grep -q "$LAUNCHD_LABEL"; then
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

# ─── Dispatch ──────────────────────────────────────────────────────────
case "${1:-}" in
  start)    shift; cmd_start "$@" ;;
  stop)     shift; cmd_stop "$@" ;;
  restart)  shift; cmd_restart "$@" ;;
  status)   shift; cmd_status "$@" ;;
  logs)     shift; cmd_logs "$@" ;;
  now)      shift; cmd_now "$@" ;;
  wizard)   shift; cmd_wizard "$@" ;;
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
