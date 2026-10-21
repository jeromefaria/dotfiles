#!/bin/bash
# ============================================================================
# scripts/lib/notify.sh — Bounded macOS notification delivery
# ============================================================================
# Source from any script that posts user-facing alerts:
#   source "${SCRIPT_DIR}/lib/notify.sh"
#   notify_post "Backup stale" "No successful run in 3 days."
#
# Reads two variables from the caller, both optional:
#   NOTIFY_ENABLED           1 (default) to post, 0 to silence everything
#   NOTIFIER_GROUP           terminal-notifier group id; a new alert in the
#                            same group replaces the prior one
#   NOTIFY_TIMEOUT_SECONDS   per-notifier wall-clock bound (default 5)
#
# Why the bound: terminal-notifier waits on Notification Center's delivery
# callback. With no Aqua session — a headless login, a CI runner, SSH without
# a GUI — that callback never arrives and it blocks forever. Every caller here
# is a launchd agent that notifies *about* a backup, so an unbounded notify
# hangs the very job it was only meant to report on.
# ============================================================================

[ -n "${_DOTFILES_NOTIFY_LOADED:-}" ] && return 0
_DOTFILES_NOTIFY_LOADED=1

# shellcheck source=bounded.sh
source "$(dirname "${BASH_SOURCE[0]}")/bounded.sh"

readonly NOTIFY_DELIVERED=0
readonly NOTIFY_FAILED=1
readonly NOTIFY_DISABLED=2

# Generous: a healthy terminal-notifier answers in well under a second.
NOTIFY_TIMEOUT_SECONDS="${NOTIFY_TIMEOUT_SECONDS:-5}"

# Post a macOS notification. Prefers terminal-notifier (it has its own app
# identity, so the "Alerts" style toggle in System Settings targets only these
# alerts); falls back to osascript, which posts under "Script Editor". Both
# work from the launchd (gui) context.
#
# Returns $NOTIFY_DELIVERED / $NOTIFY_FAILED / $NOTIFY_DISABLED. A caller must
# not read a failure as delivery — a launchd agent with no GUI session, or
# with notification permission denied, fails here every single time.
notify_post() {
  [ "${NOTIFY_ENABLED:-1}" = "1" ] || return "$NOTIFY_DISABLED"

  local title="$1" message="$2"
  local group="${NOTIFIER_GROUP:-dotfiles}"
  local limit="${NOTIFY_TIMEOUT_SECONDS:-5}"

  if command -v terminal-notifier >/dev/null 2>&1 \
     && run_bounded "$limit" terminal-notifier \
          -title "$title" -message "$message" -group "$group" >/dev/null 2>&1; then
    return "$NOTIFY_DELIVERED"
  fi

  local escaped_title="${title//\"/\\\"}" escaped_message="${message//\"/\\\"}"
  if run_bounded "$limit" osascript \
       -e "display notification \"${escaped_message}\" with title \"${escaped_title}\"" \
       >/dev/null 2>&1; then
    return "$NOTIFY_DELIVERED"
  fi

  return "$NOTIFY_FAILED"
}
