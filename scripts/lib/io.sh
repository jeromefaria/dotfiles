#!/bin/bash
# ============================================================================
# scripts/lib/io.sh — Shared color + print helpers
# ============================================================================
# Source from any script. Path is relative to this file's location, not the
# caller's CWD, so `source "$(dirname "${BASH_SOURCE[0]}")/lib/io.sh"` works
# from anywhere under scripts/. From elsewhere (mail/scripts/, bootstrap/),
# adjust the relative path accordingly.
#
# TTY-aware: ANSI escapes only when stdout is a terminal; empty strings when
# piped, so output is clean in files, less, CI logs.
# ============================================================================

# Idempotency: sourcing twice is a no-op.
[ -n "${_DOTFILES_IO_LOADED:-}" ] && return 0
_DOTFILES_IO_LOADED=1

if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  MAGENTA='\033[0;35m'
  CYAN='\033[0;36m'
  NC='\033[0m'
else
  RED=''; GREEN=''; YELLOW=''; BLUE=''; MAGENTA=''; CYAN=''; NC=''
fi

print_header() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error()   { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_info()    { echo -e "${BLUE}ℹ${NC} $1"; }
print_step()    { echo -e "${CYAN}→${NC} $1"; }
