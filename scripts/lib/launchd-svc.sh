#!/bin/bash
# ============================================================================
# scripts/lib/launchd-svc.sh — launchd service primitives
# ============================================================================
# Three thin wrappers around `launchctl load|unload|list` so consumers don't
# reinvent the "load the plist, verify it landed in `launchctl list`" dance.
# Consumers keep their own dispatch + domain-specific messages — this lib
# only owns the load/unload/verify primitive.
#
# Usage:
#   source "$(dirname "${BASH_SOURCE[0]}")/lib/launchd-svc.sh"
#   if svc_start "$LAUNCHD_PLIST" "$LAUNCHD_LABEL"; then
#     echo "started"
#   fi
# ============================================================================

[ -n "${_DOTFILES_LAUNCHD_SVC_LOADED:-}" ] && return 0
_DOTFILES_LAUNCHD_SVC_LOADED=1

# True (0) iff the launchd label is currently loaded.
svc_is_loaded() {
  launchctl list | grep -q "$1"
}

# Load the plist, return 0 iff `launchctl list` confirms it loaded.
# Usage: svc_start <plist-path> <label>
svc_start() {
  local plist="$1" label="$2"
  launchctl load "$plist" 2>/dev/null
  svc_is_loaded "$label"
}

# Unload the plist, return 0 iff `launchctl list` confirms it unloaded.
# Usage: svc_stop <plist-path> <label>
svc_stop() {
  local plist="$1" label="$2"
  launchctl unload "$plist" 2>/dev/null
  ! svc_is_loaded "$label"
}

# Unload → sleep 1 → load, return 0 iff loaded at the end.
# Usage: svc_restart <plist-path> <label>
svc_restart() {
  local plist="$1" label="$2"
  launchctl unload "$plist" 2>/dev/null
  sleep 1
  launchctl load "$plist" 2>/dev/null
  svc_is_loaded "$label"
}
