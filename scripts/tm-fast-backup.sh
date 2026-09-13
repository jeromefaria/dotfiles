#!/bin/bash
# Time Machine — backup runner (fast or gentle).
#
# Default mode lifts the low-priority I/O throttle on backupd for the duration
# of one backup — the biggest speedup for a slow (HDD) destination or a large
# initial full backup — keeps the Mac awake, runs the backup in the foreground
# (blocking), then restores the throttle (which also resets on reboot).
#
# --gentle mode does NOT touch the throttle: it runs the same blocking backup
# at backupd's normal (throttled) I/O priority. Use it whenever the destination
# is reached through a USB hub or dock — lifting the throttle there maximises
# DMA pressure and can trigger a USB DART kernel panic on Apple Silicon. Gentle
# needs no sudo. Rule of thumb: throttle-lift for DIRECT connections only;
# --gentle for anything behind a hub/dock.
#
# Usage:
#   tm-fast-backup             Fast blocking backup (throttle lifted; direct-connect only)
#   tm-fast-backup --gentle    Blocking backup at normal priority (dock/hub-safe; no sudo)
#   tm-fast-backup --dry-run   Show what it would do; change nothing
#   (--gentle and --dry-run may be combined)
#
# Ctrl-C stops the backup; in the default mode the throttle is still restored.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/io.sh
source "${SCRIPT_DIR}/lib/io.sh"

CONFIG="${SCRIPT_DIR}/tm-backup.conf"
# shellcheck disable=SC1090
[ -f "$CONFIG" ] && source "$CONFIG"
THROTTLE_KNOB="${LOWPRI_THROTTLE_SYSCTL:-debug.lowpri_throttle_enabled}"
# Seconds to wait on the destination-info gate before declaring the TM
# subsystem wedged. tmutil can hang indefinitely right after a reconnect;
# this bounds it so the script fails fast instead of blocking silently.
GATE_TIMEOUT="${TM_GATE_TIMEOUT:-20}"

# Run a command with a wall-clock limit. Uses timeout/gtimeout when present
# (coreutils), otherwise a portable bash fallback. Exit 124 signals timeout,
# matching GNU timeout's convention.
run_bounded() {
  local secs="$1"; shift
  if command -v timeout >/dev/null 2>&1; then timeout "$secs" "$@"; return $?; fi
  if command -v gtimeout >/dev/null 2>&1; then gtimeout "$secs" "$@"; return $?; fi

  "$@" &
  local pid=$!
  ( sleep "$secs"; kill -TERM "$pid" 2>/dev/null ) &
  local watcher=$!
  wait "$pid" 2>/dev/null
  local rc=$?
  if kill -0 "$watcher" 2>/dev/null; then
    kill -TERM "$watcher" 2>/dev/null
    wait "$watcher" 2>/dev/null
    return "$rc"
  fi
  return 124
}

DRY_RUN=0
GENTLE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --gentle)  GENTLE=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) awk 'NR==1{next} /^#/{sub(/^# ?/,""); print; next} /^[[:space:]]*$/{next} {exit}' "$0"; exit 0 ;;
    *) print_error "Unknown argument: $1"; exit 1 ;;
  esac
done

# ─── Gate: a destination must be configured (and the subsystem responsive) ─
run_bounded "$GATE_TIMEOUT" tmutil destinationinfo >/dev/null 2>&1
GATE_RC=$?
if [ "$GATE_RC" -eq 124 ]; then
  print_error "Time Machine did not respond within ${GATE_TIMEOUT}s — the subsystem looks wedged (common right after reconnecting the destination)."
  print_info "Re-plug the destination or wait a moment, then re-run. To adjust the limit: TM_GATE_TIMEOUT=<seconds> $0"
  exit 1
elif [ "$GATE_RC" -ne 0 ]; then
  print_error "No Time Machine destination configured (System Settings > General > Time Machine)."
  exit 1
fi

MODE_LABEL=$([ "$GENTLE" -eq 1 ] && echo "gentle (throttle untouched — dock/hub-safe)" || echo "fast (throttle lifted — direct-connect only)")
print_header "Time Machine backup — $MODE_LABEL"
tmutil destinationinfo 2>/dev/null | awk -F': *' '/Name|Kind|Mount Point/{printf "  %-12s %s\n", $1":", $2}'

if [ "$DRY_RUN" -eq 1 ]; then
  if [ "$GENTLE" -eq 1 ]; then
    print_info "DRY-RUN — would caffeinate and run a blocking backup at normal priority; throttle untouched, no sudo."
  else
    print_info "DRY-RUN — would set ${THROTTLE_KNOB}=0, caffeinate, run a blocking backup, then restore the throttle."
  fi
  exit 0
fi

# ─── Gentle: no throttle change, no sudo — just a foreground backup ─────
if [ "$GENTLE" -eq 1 ]; then
  print_step "Backing up (gentle — normal I/O priority, screen kept awake)..."
  print_info "Watch progress in another pane with:  tmutil status"
  caffeinate -dis tmutil startbackup --block
  print_success "Backup complete."
  exit 0
fi

# ─── Fast: sudo up-front + keep-alive so the post-backup restore never re-prompts ─
print_step "Requesting sudo (needed to lift the I/O throttle)..."
sudo -v || { print_error "sudo required."; exit 1; }

ORIG_THROTTLE="$(sysctl -n "$THROTTLE_KNOB" 2>/dev/null || echo 1)"

# Install cleanup BEFORE launching the keepalive so a Ctrl+C in the launch
# window still restores the throttle and reaps the loop via the EXIT trap.
# KEEPALIVE_PID may be unset at trap-fire time; `kill ""` errors silently.
cleanup() {
  sudo sysctl -w "${THROTTLE_KNOB}=${ORIG_THROTTLE}" >/dev/null 2>&1
  kill "${KEEPALIVE_PID:-}" 2>/dev/null
  print_success "Throttle restored (${THROTTLE_KNOB}=${ORIG_THROTTLE})."
}
trap cleanup EXIT INT TERM

( while kill -0 "$$" 2>/dev/null; do sudo -n true; sleep 60; done ) &
KEEPALIVE_PID=$!

print_step "Lifting I/O throttle (${THROTTLE_KNOB}: ${ORIG_THROTTLE} -> 0)..."
sudo sysctl -w "${THROTTLE_KNOB}=0" >/dev/null

print_step "Backing up (foreground, screen kept awake)..."
print_info "Watch progress in another pane with:  tmutil status"
caffeinate -dis sudo tmutil startbackup --block

print_success "Backup complete."
