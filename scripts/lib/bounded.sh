#!/bin/bash
# ============================================================================
# scripts/lib/bounded.sh — Run a command under a wall-clock bound
# ============================================================================
# Source from any script with a step that can hang rather than fail:
#   source "${SCRIPT_DIR}/lib/bounded.sh"
#   run_bounded 120 rclone lsf "$SOURCE"
#
# A hang is worse than a failure for an unattended job: a volume on a wedged
# bus answers `stat` but never returns from a traversal, `tmutil` can sit
# forever right after a reconnect, and terminal-notifier with no Aqua session
# waits on a delivery callback that never comes. Each one parks a launchd agent
# on its lock until the next login.
#
# This replaces three separate copies of the same helper — in
# audio-backup-sync.sh, tm-fast-backup.sh and the notification path — which had
# drifted to three different fallbacks, one of them "run unbounded".
# ============================================================================

[ -n "${_DOTFILES_BOUNDED_LOADED:-}" ] && return 0
_DOTFILES_BOUNDED_LOADED=1

# Seconds between liveness checks in the fallback path.
readonly BOUNDED_POLL_INTERVAL=0.2

# Run a command, killing it if it outlives $1 seconds. Returns the command's
# own exit status, or 124 on timeout — matching GNU timeout, whose convention
# this follows because it is the implementation used when available.
#
# stdout and stderr pass straight through, so `$(run_bounded 5 cmd)` captures
# exactly what `$(cmd)` would. Callers that want silence redirect themselves.
#
# coreutils' `timeout` is preferred: it is a tested C implementation and costs
# no polling. Older coreutils installs it prefixed as `gtimeout`, so both names
# are tried. The bash fallback exists because coreutils is a Homebrew package
# and the machines most likely to hang here are the ones whose setup never
# finished — degrading to *unbounded* would skip the bound exactly when it
# matters most.
run_bounded() {
  local limit_seconds="$1"
  shift

  if command -v timeout >/dev/null 2>&1; then
    timeout "$limit_seconds" "$@"
    return $?
  fi

  if command -v gtimeout >/dev/null 2>&1; then
    gtimeout "$limit_seconds" "$@"
    return $?
  fi

  "$@" &
  local pid=$!
  # Integer arithmetic only: bash has no floats, so count fixed-width polls
  # rather than tracking elapsed seconds.
  local polls_remaining
  polls_remaining=$(awk -v s="$limit_seconds" -v i="$BOUNDED_POLL_INTERVAL" 'BEGIN { printf "%d", s / i }')

  while kill -0 "$pid" 2>/dev/null; do
    if [ "$polls_remaining" -le 0 ]; then
      kill -TERM "$pid" 2>/dev/null
      # Reap quietly: the shell announces a signalled job on its own stderr,
      # and a caller capturing 2>&1 would read "Terminated" as command output.
      wait "$pid" 2>/dev/null
      return 124
    fi

    sleep "$BOUNDED_POLL_INTERVAL"
    polls_remaining=$(( polls_remaining - 1 ))
  done

  wait "$pid" 2>/dev/null
}
