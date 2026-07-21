#!/bin/bash
# Time Machine — fast full-backup runner.
#
# Lifts the low-priority I/O throttle on backupd for the duration of one
# backup — the single biggest speedup for a slow (HDD) destination or a large
# initial full backup — keeps the Mac awake, runs the backup in the foreground
# (blocking), then restores the throttle. The throttle also resets to its
# default on reboot. Usually invoked via the `tm-fast-backup` shell alias.
#
# Usage:
#   tm-fast-backup            Run a fast, blocking backup now
#   tm-fast-backup --dry-run  Show what it would do; change nothing
#
# Needs sudo (to toggle the throttle sysctl). Ctrl-C stops the backup and
# still restores the throttle.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/io.sh
source "${SCRIPT_DIR}/lib/io.sh"

CONFIG="${SCRIPT_DIR}/tm-backup.conf"
# shellcheck disable=SC1090
[ -f "$CONFIG" ] && source "$CONFIG"
THROTTLE_KNOB="${LOWPRI_THROTTLE_SYSCTL:-debug.lowpri_throttle_enabled}"

DRY_RUN=0
case "${1:-}" in
  --dry-run) DRY_RUN=1 ;;
  -h|--help) awk 'NR==1{next} /^#/{sub(/^# ?/,""); print; next} /^[[:space:]]*$/{next} {exit}' "$0"; exit 0 ;;
  "") ;;
  *) print_error "Unknown argument: $1"; exit 1 ;;
esac

# ─── Gate: a destination must be configured ────────────────────────────
if ! tmutil destinationinfo >/dev/null 2>&1; then
  print_error "No Time Machine destination configured (System Settings > General > Time Machine)."
  exit 1
fi

print_header "Time Machine — fast backup"
tmutil destinationinfo 2>/dev/null | awk -F': *' '/Name|Kind|Mount Point/{printf "  %-12s %s\n", $1":", $2}'

if [ "$DRY_RUN" -eq 1 ]; then
  print_info "DRY-RUN — would set ${THROTTLE_KNOB}=0, caffeinate, run a blocking backup, then restore the throttle."
  exit 0
fi

# ─── sudo up-front + keep-alive so the post-backup restore never re-prompts ─
print_step "Requesting sudo (needed to lift the I/O throttle)..."
sudo -v || { print_error "sudo required."; exit 1; }
( while kill -0 "$$" 2>/dev/null; do sudo -n true; sleep 60; done ) &
KEEPALIVE_PID=$!

ORIG_THROTTLE="$(sysctl -n "$THROTTLE_KNOB" 2>/dev/null || echo 1)"

cleanup() {
  sudo sysctl -w "${THROTTLE_KNOB}=${ORIG_THROTTLE}" >/dev/null 2>&1
  kill "$KEEPALIVE_PID" 2>/dev/null
  print_success "Throttle restored (${THROTTLE_KNOB}=${ORIG_THROTTLE})."
}
trap cleanup EXIT INT TERM

print_step "Lifting I/O throttle (${THROTTLE_KNOB}: ${ORIG_THROTTLE} -> 0)..."
sudo sysctl -w "${THROTTLE_KNOB}=0" >/dev/null

print_step "Backing up (foreground, screen kept awake)..."
print_info "Watch progress in another pane with:  tmutil status"
caffeinate -dis sudo tmutil startbackup --block

print_success "Backup complete."
