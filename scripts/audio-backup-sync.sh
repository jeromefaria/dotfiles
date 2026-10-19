#!/bin/bash
# Audio drive → Google Drive sync (one-shot).
#
# Idempotent. Safe to run from launchd or manually. Respects all gates
# (source mounted, SSID allowlist, hotspot detection) by default.
#
# Usage:
#   audio-backup-sync.sh                  # default: run with all gates
#   audio-backup-sync.sh --dry-run        # preview rclone transfer, no writes
#   audio-backup-sync.sh --force          # bypass SSID + hotspot gates (still warns on hotspot)
#   audio-backup-sync.sh --force --yes    # bypass + skip warn (caution: burns hotspot data)
#   audio-backup-sync.sh --bwlimit 50M    # override bandwidth cap
#
# Exit codes:
#   0  = sync ran successfully, OR gate failed cleanly (treated as no-op)
#   1  = config / setup error
#   2+ = rclone failure (propagated)

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${AUDIO_BACKUP_CONFIG:-${SCRIPT_DIR}/audio-backup.conf}"

if [ ! -f "$CONFIG" ]; then
  echo "ERROR: config not found at $CONFIG" >&2
  exit 1
fi
# shellcheck disable=SC1090
source "$CONFIG"

# ─── Colors (TTY only) — provided by lib/io.sh ─────────────────────────
source "${SCRIPT_DIR}/lib/io.sh"

# ─── Args ──────────────────────────────────────────────────────────────
DRY_RUN=0
FORCE=0
SKIP_WARN=0
BWLIMIT_OVERRIDE=""

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run)        DRY_RUN=1; shift ;;
    --force)          FORCE=1; shift ;;
    --yes|-y)         SKIP_WARN=1; shift ;;
    --bwlimit)        BWLIMIT_OVERRIDE="$2"; shift 2 ;;
    --bwlimit=*)      BWLIMIT_OVERRIDE="${1#*=}"; shift ;;
    -h|--help)
      awk 'NR==1{next} /^#/{sub(/^# ?/,""); print; next} /^[[:space:]]*$/{next} {exit}' "$0"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

# ─── Logging ───────────────────────────────────────────────────────────
mkdir -p "$LOG_DIR" 2>/dev/null || true
LOG_FILE="${LOG_DIR}/$(date "+${LOG_FILE_PATTERN}")"

log() {
  # Both to stdout (color) and to logfile (plain)
  echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $*"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE" 2>/dev/null || true
}

log_warn() {
  echo -e "${YELLOW}[$(date '+%H:%M:%S')] ⚠ $*${NC}"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARN: $*" >> "$LOG_FILE" 2>/dev/null || true
}

log_err() {
  echo -e "${RED}[$(date '+%H:%M:%S')] ✗ $*${NC}" >&2
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >> "$LOG_FILE" 2>/dev/null || true
}

log_ok() {
  echo -e "${GREEN}[$(date '+%H:%M:%S')] ✓ $*${NC}"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] OK: $*" >> "$LOG_FILE" 2>/dev/null || true
}

# ─── Alerting ──────────────────────────────────────────────────────────
# Post a macOS notification. Best-effort: never fails the run, and is a no-op
# when NOTIFY_ENABLED=0. Prefers terminal-notifier (its own app identity, so
# the "Alerts" style toggle targets only these alerts and a shared -group id
# means a new alert replaces the prior one); falls back to osascript, which
# posts under "Script Editor". Both work from the launchd (gui) context.
notify() {
  [ "${NOTIFY_ENABLED:-1}" = "1" ] || return 0
  local title="$1" message="$2"
  # Try terminal-notifier; fall back to osascript if it's absent OR fails
  # (e.g. its notifications are disabled), so an alert is never lost silently.
  if command -v terminal-notifier >/dev/null 2>&1 \
     && terminal-notifier -title "$title" -message "$message" \
          -group "${NOTIFIER_GROUP:-audio-backup}" >/dev/null 2>&1; then
    return 0
  fi
  local t="${title//\"/\\\"}" m="${message//\"/\\\"}"
  osascript -e "display notification \"${m}\" with title \"${t}\"" >/dev/null 2>&1 || true
}

# Fire a staleness alert if the last SUCCESSFUL backup is older than the
# threshold (or none is on record). Called on every unattended run — before
# the gates below — so a job that keeps SKIPPING (drive unmounted, untrusted
# network; all exit 0) still surfaces instead of rotting silently. A cooldown
# marker prevents repeat spam when the drive's mount flaps (WatchPaths refire).
check_staleness() {
  local state_dir="${STATE_DIR:-${HOME}/Library/Application Support/audio-backup}"
  mkdir -p "$state_dir" 2>/dev/null || true
  local success_marker="${LAST_SUCCESS_FILE:-${state_dir}/last-success}"
  local notify_marker="${state_dir}/.last-stale-notify"

  # One-time migration: if the pre-relocation markers still exist under
  # LOG_DIR (which cleaners like mole periodically wipe), move them to the
  # persistent STATE_DIR so history isn't lost on the next cleaner sweep.
  [ -f "${LOG_DIR}/.last-success" ] && [ ! -f "$success_marker" ] \
    && mv "${LOG_DIR}/.last-success" "$success_marker" 2>/dev/null
  [ -f "${LOG_DIR}/.last-stale-notify" ] && [ ! -f "$notify_marker" ] \
    && mv "${LOG_DIR}/.last-stale-notify" "$notify_marker" 2>/dev/null
  local max_days="${STALE_ALERT_DAYS:-3}"
  local cooldown=$(( ${STALE_NOTIFY_COOLDOWN_HOURS:-12} * 3600 ))
  local now last message last_notify
  now="$(date +%s)"

  last=""
  [ -f "$success_marker" ] && last="$(cat "$success_marker" 2>/dev/null)"
  if [[ "$last" =~ ^[0-9]+$ ]]; then
    local age_days=$(( (now - last) / 86400 ))
    [ "$age_days" -lt "$max_days" ] && return 0          # fresh enough — nothing to do
    message="Last successful Audio backup was ${age_days}d ago (threshold ${max_days}d)."
  else
    message="No successful Audio backup on record yet."
  fi

  last_notify=0
  [ -f "$notify_marker" ] && last_notify="$(cat "$notify_marker" 2>/dev/null)"
  [[ "$last_notify" =~ ^[0-9]+$ ]] || last_notify=0
  if [ $(( now - last_notify )) -ge "$cooldown" ]; then
    notify "Audio backup stale" "$message"
    log_warn "Staleness alert: $message"
    echo "$now" > "$notify_marker" 2>/dev/null || true
  fi
}

# Unattended (launchd) runs only — a manual run is the user actively looking,
# so a popup would just be noise.
[ -t 1 ] || check_staleness

# The agent fires on mount changes as well as on the clock, so most wake-ups
# have nothing to do. Answering those from the success marker costs one stat,
# where letting them through costs a full-tree rclone scan each time.
sync_is_recent_enough() {
  local window_hours="${MIN_RESYNC_INTERVAL_HOURS:-0}"
  [ "$window_hours" -gt 0 ] || return 1

  local state_dir="${STATE_DIR:-${HOME}/Library/Application Support/audio-backup}"
  local success_marker="${LAST_SUCCESS_FILE:-${state_dir}/last-success}"
  [ -f "$success_marker" ] || return 1

  local last_success
  last_success="$(cat "$success_marker" 2>/dev/null)"
  [[ "$last_success" =~ ^[0-9]+$ ]] || return 1

  [ $(( ($(date +%s) - last_success) / 3600 )) -lt "$window_hours" ]
}

if [ ! -t 1 ] && [ "$FORCE" -eq 0 ] && sync_is_recent_enough; then
  log "Last successful sync is under ${MIN_RESYNC_INTERVAL_HOURS}h old — nothing to do."
  exit 0
fi

# ─── Gate 1: source drive mounted ──────────────────────────────────────
if [ ! -f "$SENTINEL" ]; then
  log_warn "Source drive not mounted (sentinel $SENTINEL not found). Skipping."
  exit 0
fi

# ─── Gate 2: trusted-router allowlist + hotspot check ──────────────────
# Network identity is established via the Wi-Fi service's router IP, not
# SSID. On macOS Tahoe (and Sonoma 14.4+) the SSID/BSSID surface is
# redacted by the OS in every user-space API — `ipconfig getsummary` and
# `system_profiler` both literally return "<redacted>" without a Location
# Services entitlement. Router IP, by contrast, is exposed by
# `networksetup -getinfo Wi-Fi` with no permission required. It is also
# VPN-immune (the system default gateway is hijacked by a tunnel; the
# Wi-Fi service router is not).
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

is_hotspot() {
  local router="$1"
  [[ "$router" == ${HOTSPOT_GATEWAY_PATTERN}* ]]
}

WIFI_ROUTER="$(current_wifi_router)"
BWLIMIT="${BWLIMIT_OVERRIDE:-$BWLIMIT_DEFAULT}"

if [ "$FORCE" -eq 0 ]; then
  # Strict gates — used by launchd schedule
  if is_hotspot "$WIFI_ROUTER"; then
    log_warn "iPhone hotspot detected (router $WIFI_ROUTER). Skipping. (Use --force to override.)"
    exit 0
  fi
  if ! is_trusted_router "$WIFI_ROUTER"; then
    log_warn "Router '${WIFI_ROUTER:-<none>}' not in trusted allowlist. Skipping. (Use --force to override.)"
    exit 0
  fi
else
  # Forced — but warn on hotspot unless --yes
  if is_hotspot "$WIFI_ROUTER"; then
    if [ "$SKIP_WARN" -eq 0 ]; then
      echo -e "${RED}WARNING:${NC} iPhone hotspot detected (router $WIFI_ROUTER)."
      echo "  Backup may transfer substantial data over mobile connection."
      echo "  Bandwidth will be capped at $BWLIMIT_FORCE (override with --bwlimit)."
      read -r -p "  Proceed? [y/N]: " ans
      if [[ ! "$ans" =~ ^[Yy]$ ]]; then
        log_warn "User declined hotspot run. Aborting."
        exit 0
      fi
    fi
    BWLIMIT="${BWLIMIT_OVERRIDE:-$BWLIMIT_FORCE}"
    log_warn "Forced run on hotspot. Bandwidth capped at $BWLIMIT."
  elif ! is_trusted_router "$WIFI_ROUTER"; then
    log_warn "Forced run on untrusted router '${WIFI_ROUTER:-<none>}'. Bandwidth capped at $BWLIMIT_FORCE."
    BWLIMIT="${BWLIMIT_OVERRIDE:-$BWLIMIT_FORCE}"
  fi
fi

# ─── Gate 3: filters file present ──────────────────────────────────────
if [ ! -f "$FILTERS_FILE" ]; then
  log_err "Filters file not found at $FILTERS_FILE"
  exit 1
fi

# ─── Gate 4: rclone installed ──────────────────────────────────────────
if ! command -v rclone &> /dev/null; then
  log_err "rclone not installed. Install with: brew install rclone"
  exit 1
fi

# ─── Gate 5: rclone remote configured ──────────────────────────────────
if ! rclone listremotes | grep -q "^${RCLONE_REMOTE}:$"; then
  log_err "rclone remote '${RCLONE_REMOTE}:' not configured. Run: rclone config"
  exit 1
fi

# ─── Gate 6: Time Machine not mid-backup ───────────────────────────────
# The Time Machine destination hangs off the same USB hub chain as the source
# drive. Running both at once saturates the bus and is how each of them ends up
# interrupted, so defer instead of competing — launchd retries on its next fire,
# and a manual run says so plainly rather than failing halfway.
if [ "${DEFER_WHILE_TIME_MACHINE_RUNS:-1}" = "1" ] \
   && tmutil status 2>/dev/null | grep -q 'Running = 1'; then
  log_warn "Time Machine is mid-backup — deferring to avoid contending for the same USB bus. Skipping."
  exit 0
fi

# ─── Concurrency lock (stop a manual run and the nightly run overlapping) ─
LOCK_DIR="${TMPDIR:-/tmp}/audio-backup.lock"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  log_warn "Another audio-backup run already holds the lock ($LOCK_DIR). Skipping."
  exit 0
fi
trap 'rmdir "$LOCK_DIR" 2>/dev/null' EXIT

# ─── Run rclone ────────────────────────────────────────────────────────
DEST="${RCLONE_REMOTE}:${RCLONE_DEST_PATH}"
VERSIONS_DEST="${RCLONE_REMOTE}:${RCLONE_VERSIONS_PATH}/$(date +%Y-%m-%d)"

log "Source: $SOURCE"
log "Dest:   $DEST"
log "Router: ${WIFI_ROUTER:-<none>}"
log "BW:     $BWLIMIT"
log "Filters: $FILTERS_FILE"

# 'sync' mirrors SOURCE→DEST so source deletions/reorgs propagate; --backup-dir
# first MOVES every overwritten/deleted file into the dated versions folder, so
# the mirror stays clean while nothing is ever actually lost.
RCLONE_ARGS=(
  sync "$SOURCE" "$DEST"
  --filter-from "$FILTERS_FILE"
  --backup-dir "$VERSIONS_DEST"
  --bwlimit "$BWLIMIT"
  --log-file "$LOG_FILE"
  --log-level INFO
  --transfers "${RCLONE_TRANSFERS:-2}"
  --checkers "${RCLONE_CHECKERS:-4}"
)

# Live progress bar on a TTY; periodic one-line stats when unattended (launchd),
# so the logfile gets heartbeats instead of thousands of progress redraws.
if [ -t 1 ]; then
  RCLONE_ARGS+=(--progress)
else
  RCLONE_ARGS+=(--stats 30s --stats-one-line)
fi

if [ "$DRY_RUN" -eq 1 ]; then
  log "DRY-RUN — no writes"
  RCLONE_ARGS+=(--dry-run)
fi

# Pre-flight read probe. Two unrelated faults present identically from here, so
# the probe's job is not just to fail but to say which one it hit:
#   • the volume fell off a loaded bus — the mount lingers, traversal throws en
#     masse, and cycling the mount can genuinely clear it;
#   • macOS refused access to the removable volume — enumeration returns EPERM
#     immediately, and no amount of remounting will ever change that.
#
# The probe deliberately runs through rclone. rclone performs the transfer and
# therefore holds the volume's privacy grant; probing with any other binary
# tests a permission the real work never needs. A shell-side `find` here
# discarded stderr and reported EPERM as "zero entries", which is
# indistinguishable from a dead bus — that cost sixteen nights of backups.
PROBE_DIAGNOSIS=""

source_survives_probe() {
  [ "${PREFLIGHT_PROBE_ENABLED:-1}" = "1" ] || return 0

  PROBE_DIAGNOSIS=""

  local listing status
  listing="$(run_bounded "${PROBE_TIMEOUT_SECONDS:-120}" \
    rclone lsf "$SOURCE" --max-depth 1 --retries 1 --low-level-retries 1 2>&1)"
  status=$?

  # Any entry proves enumeration works. The question is "can the contents be
  # listed", not "does the root exist" — Gate 1 already answered the latter.
  if [ "$status" -eq 0 ] && [ -n "$listing" ]; then
    return 0
  fi

  if printf '%s\n' "$listing" | grep -qiE 'operation not permitted|permission denied'; then
    PROBE_DIAGNOSIS="permission"
  else
    PROBE_DIAGNOSIS="unreadable"
  fi

  return 1
}

# A permission denial and a bus fault need opposite responses — one needs a
# human in System Settings, the other needs the mount cycled — so the abort
# names the one it actually saw rather than guessing at hardware.
abort_unreadable_source() {
  if [ "${PROBE_DIAGNOSIS:-}" = "permission" ]; then
    log_err "Pre-flight read probe failed — macOS denied access to ${SOURCE}."
    log_err "Grant Full Disk Access to $(command -v rclone) under System Settings → Privacy & Security."
    log_err "Homebrew installs each rclone version to its own path, so upgrading rclone revokes the grant."
    notify "Audio backup blocked" "macOS denied rclone access to the Audio volume — re-grant Full Disk Access."
  else
    log_err "Pre-flight read probe failed — the source is mounted but unreadable (bus or drive fault)."
    notify "Audio backup aborted" "Source unreadable before transfer. Check the drive's connection."
  fi

  exit 1
}

# Bound a recovery step. A wedged bus endpoint can make diskutil block with no
# timeout of its own, and a Keychain item whose ACL does not yet trust
# `security` opens a GUI prompt that nobody is awake to answer — either would
# hang the nightly run indefinitely while holding the lock. Degrades to running
# unbounded if coreutils is not installed, since a bounded step is an
# improvement on hanging but not worth a hard dependency.
run_bounded() {
  local limit_seconds="$1"
  shift

  if command -v timeout >/dev/null 2>&1; then
    timeout "$limit_seconds" "$@"
    return $?
  fi

  "$@"
}

source_volume_device() {
  run_bounded "${RECOVERY_STEP_TIMEOUT_SECONDS:-60}" diskutil info "$1" 2>/dev/null \
    | awk -F': *' '/^ *Device Identifier/ { print $2; exit }'
}

# Unlocks the FileVault-encrypted source without ever putting its passphrase on
# a command line, where `ps` would expose it to every user on the machine.
# `security` prints a stored blob as hex whenever it is not valid UTF-8, which
# is the case here, so the decoded form is tried first and the literal one kept
# as a fallback rather than guessing from the shape of the string.
unlock_source_volume() {
  local device="$1"
  local keychain_item="${SOURCE_VOLUME_UUID:-}"
  [ -n "$keychain_item" ] || return 1

  local step_timeout="${RECOVERY_STEP_TIMEOUT_SECONDS:-60}"
  local keychain_timeout="${KEYCHAIN_READ_TIMEOUT_SECONDS:-10}"

  local stored_passphrase
  if ! stored_passphrase="$(run_bounded "$keychain_timeout" \
       security find-generic-password -w -s "$keychain_item" 2>/dev/null)"; then
    log_warn "Could not read the volume passphrase from the Keychain within ${keychain_timeout}s — see audio-backup.conf."
    return 1
  fi
  [ -n "$stored_passphrase" ] || return 1

  if [[ "$stored_passphrase" =~ ^([0-9a-fA-F]{2})+$ ]] \
     && printf '%s' "$stored_passphrase" | xxd -r -p 2>/dev/null \
          | run_bounded "$step_timeout" \
              diskutil apfs unlockVolume "$device" -stdinpassphrase >/dev/null 2>&1; then
    return 0
  fi

  printf '%s' "$stored_passphrase" \
    | run_bounded "$step_timeout" \
        diskutil apfs unlockVolume "$device" -stdinpassphrase >/dev/null 2>&1
}

# Cycle the mount to re-establish a wedged bus endpoint. Unlocking an APFS
# volume mounts it as a side effect, so the plain mount is attempted first and
# the unlock only covers the case where the volume relocked on unmount.
remount_source() {
  local mount_point="${SOURCE_VOLUME_MOUNT:-$(dirname "$SOURCE")}"
  local settle_seconds="${SOURCE_REMOUNT_SETTLE_SECONDS:-10}"

  local device
  device="$(source_volume_device "$mount_point")"
  if [ -z "$device" ]; then
    log_warn "Could not resolve a device for ${mount_point} — skipping recovery."
    return 1
  fi

  local step_timeout="${RECOVERY_STEP_TIMEOUT_SECONDS:-60}"

  log "Source unreadable — cycling ${device} to clear the fault..."
  run_bounded "$step_timeout" diskutil unmount force "$mount_point" >/dev/null 2>&1 || true
  sleep "$settle_seconds"

  # A plain mount is tried first because macOS resolves the passphrase itself
  # for a volume it already remembers, which needs no Keychain read at all.
  if ! run_bounded "$step_timeout" diskutil mount "$device" >/dev/null 2>&1 \
     && ! unlock_source_volume "$device"; then
    log_warn "${device} would not remount — the volume is left unmounted and locked."
    return 1
  fi
  sleep "$settle_seconds"

  [ -f "$SENTINEL" ]
}

if ! source_survives_probe; then
  # Remounting cannot grant a permission, so a denial skips recovery entirely
  # rather than cycling a healthy volume and breaking its symlinks for nothing.
  if [ "$PROBE_DIAGNOSIS" = "permission" ]; then
    abort_unreadable_source
  fi

  if [ "${RECOVER_SOURCE_ON_PROBE_FAILURE:-1}" = "1" ] \
     && remount_source && source_survives_probe; then
    log "Source recovered after remount — continuing."
  else
    abort_unreadable_source
  fi
fi

# Whole-sync retry. rclone is idempotent, so a second pass completes whatever
# the first dropped — but only attempt it when the source has actually come
# back, otherwise we just spin up another doomed run.
run_rclone_with_retries() {
  local attempts=$(( ${SYNC_RETRY_ATTEMPTS:-1} + 1 ))
  local delay="${SYNC_RETRY_DELAY_SECONDS:-30}"
  local attempt=1

  while :; do
    log "Starting rclone (attempt ${attempt}/${attempts})..."
    rclone "${RCLONE_ARGS[@]}" && return 0

    local status=$?
    [ "$attempt" -ge "$attempts" ] && return "$status"

    log_warn "rclone exited ${status} — waiting ${delay}s before retrying"
    sleep "$delay"

    if [ ! -f "$SENTINEL" ]; then
      log_err "Source drive is gone (sentinel $SENTINEL missing) — not retrying."
      return "$status"
    fi
    if ! source_survives_probe; then
      log_err "Source still unreadable after ${delay}s (${PROBE_DIAGNOSIS}) — not retrying."
      return "$status"
    fi

    attempt=$(( attempt + 1 ))
  done
}

if run_rclone_with_retries; then
  log_ok "Sync complete"
  # Stamp the success marker the staleness watchdog reads (real runs only —
  # a dry-run transferred nothing, so it must not reset the clock). Lives
  # under STATE_DIR so cleaners that sweep ~/Library/Logs/ leave it alone.
  if [ "$DRY_RUN" -eq 0 ]; then
    # NOT `local`: this block runs at top level, not inside a function, where
    # `local` is a runtime error that `set -u` then escalates into an abort on
    # the next line. Every successful sync therefore lost its success marker AND
    # skipped the prune below, so the staleness watchdog kept firing even though
    # rclone had completed cleanly.
    state_dir="${STATE_DIR:-${HOME}/Library/Application Support/audio-backup}"
    mkdir -p "$state_dir" 2>/dev/null || true
    date +%s > "${LAST_SUCCESS_FILE:-${state_dir}/last-success}" 2>/dev/null || true
  fi
  # Auto-prune version folders past the retention window (honours --dry-run).
  log "Pruning versions older than ${VERSION_RETENTION_DAYS:-90}d..."
  if [ "$DRY_RUN" -eq 1 ]; then
    "${SCRIPT_DIR}/audio-backup-manage.sh" prune --dry-run 2>&1 | while IFS= read -r l; do log "$l"; done
  else
    "${SCRIPT_DIR}/audio-backup-manage.sh" prune 2>&1 | while IFS= read -r l; do log "$l"; done
  fi
  exit 0
else
  rc=$?
  log_err "rclone exited $rc"
  notify "Audio backup FAILED" "rclone exited $rc. Check $LOG_FILE"
  exit "$rc"
fi
