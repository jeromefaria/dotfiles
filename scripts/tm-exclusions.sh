#!/bin/bash
# Time Machine — exclusion manager.
#
# Applies a version-controlled set of regeneratable / re-downloadable paths as
# Time Machine exclusions, so the backup footprint stays well under the
# destination size and Time Machine keeps a healthy chain of history instead
# of thrashing into a fresh full backup. The list lives in tm-backup.conf
# (TM_EXCLUSIONS) — edit it there, then re-run `tm-exclusions apply`. Usually
# invoked via the `tm-exclusions` shell alias.
#
# Usage:
#   tm-exclusions list      Show the configured exclusion paths
#   tm-exclusions status    Show each path's current excluded/included state
#   tm-exclusions apply     Exclude every configured path (sticky; needs sudo)
#   tm-exclusions remove    Un-exclude every configured path (needs sudo)
#
# Sticky exclusions (`tmutil addexclusion -p`) survive the path being deleted
# and recreated, and re-apply cleanly after erasing or replacing the TM disk.

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/io.sh
source "${SCRIPT_DIR}/lib/io.sh"

CONFIG="${SCRIPT_DIR}/tm-backup.conf"
if [ ! -f "$CONFIG" ]; then print_error "Config not found: $CONFIG"; exit 1; fi
# shellcheck disable=SC1090
source "$CONFIG"

cmd_list() {
  print_header "Configured Time Machine exclusions"
  for p in "${TM_EXCLUSIONS[@]}"; do echo "  $p"; done
  echo ""
  print_info "${#TM_EXCLUSIONS[@]} paths — edit TM_EXCLUSIONS in tm-backup.conf"
}

cmd_status() {
  print_header "Time Machine exclusion status"
  for p in "${TM_EXCLUSIONS[@]}"; do
    if tmutil isexcluded "$p" 2>/dev/null | grep -q "Excluded"; then
      print_success "excluded  $p"
    else
      print_warning "INCLUDED  $p"
    fi
  done
}

cmd_apply() {
  print_header "Applying Time Machine exclusions"
  print_step "sudo needed for the system paths (/opt, /Library)..."
  sudo -v || { print_error "sudo required."; exit 1; }
  local applied=0
  for p in "${TM_EXCLUSIONS[@]}"; do
    if sudo tmutil addexclusion -p "$p" 2>/dev/null; then
      print_success "excluded  $p"; applied=$((applied + 1))
    else
      print_error "failed    $p"
    fi
  done
  echo ""
  print_info "${applied}/${#TM_EXCLUSIONS[@]} applied. Verify with: tm-exclusions status"
}

cmd_remove() {
  print_header "Removing Time Machine exclusions"
  sudo -v || { print_error "sudo required."; exit 1; }
  for p in "${TM_EXCLUSIONS[@]}"; do
    if sudo tmutil removeexclusion -p "$p" 2>/dev/null; then
      print_success "included  $p"
    else
      print_error "failed    $p"
    fi
  done
}

case "${1:-}" in
  list)             cmd_list ;;
  status)           cmd_status ;;
  apply)            cmd_apply ;;
  remove)           cmd_remove ;;
  ""|-h|--help)     awk 'NR==1{next} /^#/{sub(/^# ?/,""); print; next} /^[[:space:]]*$/{next} {exit}' "$0" ;;
  *)                print_error "Unknown command: $1"; echo ""; awk 'NR==1{next} /^#/{sub(/^# ?/,""); print; next} /^[[:space:]]*$/{next} {exit}' "$0"; exit 1 ;;
esac
