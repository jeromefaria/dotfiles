#!/bin/bash
# ============================================================================
# scripts/lib/sudo-keepalive.sh — sudo timestamp keepalive primitives
# ============================================================================
# Source, then:
#
#   sudo_keepalive_start   # sudo -v + background loop; stores PID in
#                          # $_SUDO_KEEPALIVE_PID
#   ... work that needs sudo ...
#   sudo_keepalive_stop    # kills the loop; safe to call more than once
#
# This library deliberately does NOT install signal traps. Bash callers
# should register `sudo_keepalive_stop` in their own EXIT/INT/TERM trap
# alongside whatever else they clean up; zsh callers (functions) should
# use TRAPEXIT/TRAPINT/TRAPTERM instead (bash `trap ... EXIT` fires at
# shell exit, not function return, so it would be wrong for a zsh
# function). Callers own trap composition — the lib owns the primitive.
# ============================================================================

# Idempotency: sourcing twice is a no-op.
[ -n "${_DOTFILES_SUDO_KEEPALIVE_LOADED:-}" ] && return 0
_DOTFILES_SUDO_KEEPALIVE_LOADED=1

_SUDO_KEEPALIVE_PID=""

# Refresh sudo, then launch a background loop that pings `sudo -n true`
# every 60s until the parent shell dies (self-terminating via kill -0).
# Returns non-zero if the initial `sudo -v` fails (bad password, etc).
sudo_keepalive_start() {
  sudo -v || return 1
  ( while kill -0 "$$" 2>/dev/null; do sudo -n true; sleep 60; done ) &
  _SUDO_KEEPALIVE_PID=$!
}

# Reap the keepalive loop. Safe to call when none is running and safe to
# call more than once — the second kill is a no-op.
sudo_keepalive_stop() {
  [ -n "$_SUDO_KEEPALIVE_PID" ] && kill "$_SUDO_KEEPALIVE_PID" 2>/dev/null
  _SUDO_KEEPALIVE_PID=""
}
