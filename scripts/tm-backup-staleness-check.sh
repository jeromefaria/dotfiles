#!/bin/bash
# ============================================================================
# scripts/tm-backup-staleness-check.sh
# ============================================================================
# Runs daily via launchd. Reads `tmutil latestbackup`, compares the timestamp
# against $TM_STALE_ALERT_HOURS, and notifies via terminal-notifier (falls
# back to osascript) if the last completed backup is too old — or if
# `tmutil latestbackup` itself errors, which means the destination isn't
# currently mountable.
#
# Cooldown-guarded via a .last-stale-notify marker so a stuck dock doesn't
# spam the user every check. Mirrors the audio-backup staleness pattern
# (source: scripts/audio-backup-sync.sh:88-133).
#
# Usage:
#   tm-backup-staleness-check.sh          # normal check, notify if stale
#   tm-backup-staleness-check.sh --check  # exit 0 fresh / 1 stale, no notify (for scripting)
# ============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${TM_BACKUP_CONFIG:-${SCRIPT_DIR}/tm-backup.conf}"

# shellcheck disable=SC1090
[ -f "$CONFIG" ] && source "$CONFIG"

STALE_HOURS="${TM_STALE_ALERT_HOURS:-48}"
COOLDOWN_HOURS="${TM_STALE_NOTIFY_COOLDOWN_HOURS:-12}"
NOTIFY_ENABLED="${TM_NOTIFY_ENABLED:-1}"
NOTIFIER_GROUP="${TM_NOTIFIER_GROUP:-tm-backup}"
LOG_DIR="${TM_STALENESS_LOG_DIR:-${HOME}/Library/Logs/tm-backup}"

MODE="notify"
[ "${1:-}" = "--check" ] && MODE="check"

mkdir -p "$LOG_DIR" 2>/dev/null || true
LOG_FILE="$LOG_DIR/staleness-check.log"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_FILE" 2>/dev/null || true
}

# Post a macOS notification. Silent no-op when NOTIFY_ENABLED=0. Prefers
# terminal-notifier so the "Alerts" style toggle in System Settings targets
# only these alerts; falls back to osascript when it's absent or fails.
notify() {
  [ "$NOTIFY_ENABLED" = "1" ] || return 0
  local title="$1" message="$2"

  if command -v terminal-notifier >/dev/null 2>&1 \
     && terminal-notifier -title "$title" -message "$message" \
          -group "$NOTIFIER_GROUP" >/dev/null 2>&1; then
    return 0
  fi

  local t="${title//\"/\\\"}" m="${message//\"/\\\"}"
  osascript -e "display notification \"${m}\" with title \"${t}\"" >/dev/null 2>&1 || true
}

# Extract the last-backup timestamp. `tmutil latestbackup` prints a path shaped
# like /Volumes/.timemachine/<uuid>/YYYY-MM-DD-HHMMSS.backup/... — parse the
# leaf date. Returns non-zero if tmutil errored (destination unmountable, no
# backups yet on this destination, TM disabled).
latest_backup_epoch() {
  local path date_str
  path="$(tmutil latestbackup 2>/dev/null)" || return 1
  [ -n "$path" ] || return 1

  # Extract YYYY-MM-DD-HHMMSS from the leaf path segment.
  date_str="$(basename "$path" | sed -nE 's/^([0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{6})\.backup.*$/\1/p')"
  [ -n "$date_str" ] || return 1

  # macOS `date` expects a specific format string for parsing.
  date -j -f "%Y-%m-%d-%H%M%S" "$date_str" "+%s" 2>/dev/null
}

now="$(date +%s)"
last=""
if last="$(latest_backup_epoch)"; then
  age_seconds=$(( now - last ))
  age_hours=$(( age_seconds / 3600 ))
  last_human="$(date -r "$last" '+%Y-%m-%d %H:%M')"
  log "Last backup: $last_human (age ${age_hours}h; threshold ${STALE_HOURS}h)"

  if [ "$age_hours" -lt "$STALE_HOURS" ]; then
    [ "$MODE" = "check" ] && exit 0
    exit 0
  fi

  message="No successful backup in ${age_hours}h (last: ${last_human}). Threshold ${STALE_HOURS}h."
else
  log "tmutil latestbackup unavailable — destination probably not mounted"
  message="Backup destination is not reachable — no recent backup can be confirmed."
fi

# Stale. In --check mode, just report and exit non-zero (no notification).
if [ "$MODE" = "check" ]; then
  echo "$message" >&2
  exit 1
fi

# Cooldown-guarded notify.
notify_marker="$LOG_DIR/.last-stale-notify"
cooldown_seconds=$(( COOLDOWN_HOURS * 3600 ))
last_notify=0
[ -f "$notify_marker" ] && last_notify="$(cat "$notify_marker" 2>/dev/null || echo 0)"
[[ "$last_notify" =~ ^[0-9]+$ ]] || last_notify=0

if [ $(( now - last_notify )) -ge "$cooldown_seconds" ]; then
  notify "Time Machine backup stale" "$message"
  log "Notified: $message"
  echo "$now" > "$notify_marker" 2>/dev/null || true
else
  log "Suppressed (cooldown ${COOLDOWN_HOURS}h): $message"
fi
