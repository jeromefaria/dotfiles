#!/bin/bash
# ============================================================================
# scripts/tm-backup-staleness-check.sh
# ============================================================================
# Runs daily via launchd. Reads the last completed-backup timestamp, compares
# it against $TM_STALE_ALERT_HOURS, and notifies via terminal-notifier (falls
# back to osascript) if that backup is too old — or if the timestamp cannot be
# read at all, which means the destination isn't currently reachable.
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

# shellcheck source=lib/notify.sh
source "${SCRIPT_DIR}/lib/notify.sh"

STALE_HOURS="${TM_STALE_ALERT_HOURS:-48}"
COOLDOWN_HOURS="${TM_STALE_NOTIFY_COOLDOWN_HOURS:-12}"
# NOTIFY_ENABLED and NOTIFIER_GROUP are read by notify_post in lib/notify.sh,
# which shellcheck cannot see across the source boundary.
# shellcheck disable=SC2034
NOTIFY_ENABLED="${TM_NOTIFY_ENABLED:-1}"
# shellcheck disable=SC2034
NOTIFIER_GROUP="${TM_NOTIFIER_GROUP:-tm-backup}"
LOG_DIR="${TM_STALENESS_LOG_DIR:-${HOME}/Library/Logs/tm-backup}"
STATE_DIR="${TM_STALENESS_STATE_DIR:-${HOME}/Library/Application Support/tm-backup}"

MODE="notify"
[ "${1:-}" = "--check" ] && MODE="check"

mkdir -p "$LOG_DIR" "$STATE_DIR" 2>/dev/null || true
LOG_FILE="$LOG_DIR/staleness-check.log"

# One-time migration: relocate the cooldown marker from LOG_DIR (where a
# disk cleaner can wipe it) to STATE_DIR (which cleaners leave alone).
[ -f "${LOG_DIR}/.last-stale-notify" ] && [ ! -f "${STATE_DIR}/.last-stale-notify" ] \
  && mv "${LOG_DIR}/.last-stale-notify" "${STATE_DIR}/.last-stale-notify" 2>/dev/null

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_FILE" 2>/dev/null || true
}

# The last-backup timestamp has two sources, because the obvious one does not
# work where this script actually runs.
#
# `tmutil latestbackup` is authoritative, but it requires Full Disk Access. A
# launchd agent does not have it, so under launchd the call exits 80 with a
# message pointing at the Privacy pane. That made every scheduled run take the
# "destination unreachable" branch and alert on a perfectly healthy backup —
# and, because it never obtained a date, a genuinely stale backup would not
# have been detected either. The monitor was blind in both directions.
#
# Time Machine's own preferences carry the same information and are readable
# without Full Disk Access, because `defaults` goes through cfprefsd instead of
# opening the protected file — which is why `defaults read` succeeds on this
# path where `plutil` against the same path fails. SnapshotDates lists
# completed backups only: interrupted and in-progress containers never appear
# in it, which is exactly the semantics a staleness check needs.
TM_PREFS="${TM_PREFS_PATH:-/Library/Preferences/com.apple.TimeMachine.plist}"

# `tmutil latestbackup` prints a path shaped like
# /Volumes/.timemachine/<uuid>/YYYY-MM-DD-HHMMSS.backup/... — parse the leaf
# date. Returns non-zero when tmutil errored, including the no-FDA case.
tmutil_backup_epoch() {
  local path date_str
  path="$(tmutil latestbackup 2>/dev/null)" || return 1
  [ -n "$path" ] || return 1

  # Extract YYYY-MM-DD-HHMMSS from the leaf path segment.
  date_str="$(basename "$path" | sed -nE 's/^([0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{6})\.backup.*$/\1/p')"
  [ -n "$date_str" ] || return 1

  # macOS `date` expects a specific format string for parsing.
  date -j -f "%Y-%m-%d-%H%M%S" "$date_str" "+%s" 2>/dev/null
}

# Newest completed backup across every configured destination, read from
# preferences. Exporting to XML and indexing with plutil avoids parsing the
# NeXTSTEP format `defaults read` prints — and avoids confusing SnapshotDates
# with the sibling AttemptDates array, which records tries rather than
# successes. Taking the newest across destinations means a machine that
# rotates between docks reports its most recent success, not whichever
# destination happens to be listed first.
prefs_backup_epoch() {
  local exported destinations index count iso epoch newest=""

  exported="$(defaults export "$TM_PREFS" - 2>/dev/null)" || return 1
  [ -n "$exported" ] || return 1

  destinations="$(printf '%s' "$exported" \
    | plutil -extract Destinations raw -o - - 2>/dev/null)"
  [[ "$destinations" =~ ^[0-9]+$ ]] || return 1

  for (( index = 0; index < destinations; index++ )); do
    count="$(printf '%s' "$exported" \
      | plutil -extract "Destinations.${index}.SnapshotDates" raw -o - - 2>/dev/null)"
    [[ "$count" =~ ^[0-9]+$ ]] && [ "$count" -gt 0 ] || continue

    iso="$(printf '%s' "$exported" \
      | plutil -extract "Destinations.${index}.SnapshotDates.$(( count - 1 ))" raw -o - - 2>/dev/null)"
    [ -n "$iso" ] || continue

    epoch="$(date -j -u -f "%Y-%m-%dT%H:%M:%SZ" "$iso" "+%s" 2>/dev/null)" || continue
    [ -n "$epoch" ] || continue

    if [ -z "$newest" ] || [ "$epoch" -gt "$newest" ]; then
      newest="$epoch"
    fi
  done

  [ -n "$newest" ] || return 1
  printf '%s\n' "$newest"
}

# Prefer the authoritative source when it is permitted, fall back to the one
# that always is. Which source answered is logged, because "stale" means
# something different depending on it. Both failing is the real
# destination-unreachable signal.
latest_backup_epoch() {
  local epoch

  if epoch="$(tmutil_backup_epoch)"; then
    log "Source: tmutil latestbackup"
    printf '%s\n' "$epoch"
    return 0
  fi

  if epoch="$(prefs_backup_epoch)"; then
    log "Source: Time Machine preferences (tmutil needs Full Disk Access)"
    printf '%s\n' "$epoch"
    return 0
  fi

  return 1
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
  log "No last-backup date from tmutil or preferences — destination unreachable"
  message="Backup destination is not reachable — no recent backup can be confirmed."
fi

# Stale. In --check mode, just report and exit non-zero (no notification).
if [ "$MODE" = "check" ]; then
  echo "$message" >&2
  exit 1
fi

# Cooldown-guarded notify. Marker lives in STATE_DIR (cleaner-safe), not LOG_DIR.
notify_marker="$STATE_DIR/.last-stale-notify"
cooldown_seconds=$(( COOLDOWN_HOURS * 3600 ))
last_notify=0
[ -f "$notify_marker" ] && last_notify="$(cat "$notify_marker" 2>/dev/null || echo 0)"
[[ "$last_notify" =~ ^[0-9]+$ ]] || last_notify=0

if [ $(( now - last_notify )) -ge "$cooldown_seconds" ]; then
  notify_post "Time Machine backup stale" "$message"
  log "Notified: $message"
  echo "$now" > "$notify_marker" 2>/dev/null || true
else
  log "Suppressed (cooldown ${COOLDOWN_HOURS}h): $message"
fi
