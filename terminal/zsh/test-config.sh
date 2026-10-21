#!/usr/bin/env zsh
# Test script for the refactored shell configuration
# Usage: zsh test-config.sh
#
# Simulates a normal interactive user shell: aliases in aliases/*.sh are
# gated on CLAUDECODE being unset (they shadow POSIX commands with
# eza/bat/fd/sd/zoxide, which break automation subshells). Clear the
# variable up front so the suite exercises the full alias set even when
# invoked from a Claude Code tool subshell.
unset CLAUDECODE

echo "==================================="
echo "Shell Configuration Test Suite"
echo "==================================="
echo

# Set DOTFILES if not set
# Repo root from this script's own location, so the suite works from any
# checkout — a CI runner clones to a workspace path, not ~/dotfiles. Same
# reason the zshrc resolves it this way.
: "${DOTFILES:=${${(%):-%N}:A:h:h:h}}"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass_count=0
fail_count=0

test_pass() {
  echo -e "${GREEN}✓${NC} $1"
  ((pass_count++))
}

test_fail() {
  echo -e "${RED}✗${NC} $1"
  ((fail_count++))
}

test_info() {
  echo -e "${YELLOW}ℹ${NC} $1"
}

echo "1. Testing Alias Files"
echo "----------------------"
for alias_file in "$DOTFILES/terminal/zsh/aliases"/*.sh; do
  if [[ -f "$alias_file" ]]; then
    if source "$alias_file" 2>/dev/null; then
      test_pass "$(basename "$alias_file") loads successfully"
    else
      test_fail "$(basename "$alias_file") failed to load"
    fi
  fi
done
echo

echo "2. Testing Function Files"
echo "-------------------------"
for func_file in "$DOTFILES/terminal/zsh/functions"/*.sh; do
  if [[ -f "$func_file" ]]; then
    if source "$func_file" 2>/dev/null; then
      test_pass "$(basename "$func_file") loads successfully"
    else
      test_fail "$(basename "$func_file") failed to load"
    fi
  fi
done
echo

echo "3. Testing Key Aliases"
echo "----------------------"
# Source all aliases first
for alias_file in "$DOTFILES/terminal/zsh/aliases"/*.sh; do
  source "$alias_file" 2>/dev/null
done

aliases_to_test=("ls" "cat" "grep" "vim" "ll" "la")
for cmd in "${aliases_to_test[@]}"; do
  if alias "$cmd" &>/dev/null; then
    test_pass "Alias '$cmd' is defined"
  else
    test_fail "Alias '$cmd' is NOT defined"
  fi
done
echo

echo "4. Testing Key Functions"
echo "------------------------"
# Source all functions first
for func_file in "$DOTFILES/terminal/zsh/functions"/*.sh; do
  source "$func_file" 2>/dev/null
done

functions_to_test=("mkd" "enc" "dec" "fs" "server" "flac2mp3")
for func in "${functions_to_test[@]}"; do
  if typeset -f "$func" &>/dev/null; then
    test_pass "Function '$func' is defined"
  else
    test_fail "Function '$func' is NOT defined"
  fi
done
echo

echo "5. Testing Dependencies"
echo "-----------------------"
deps=("eza" "bat" "fd" "zoxide" "fzf" "nvim")
for dep in "${deps[@]}"; do
  if command -v "$dep" &>/dev/null; then
    test_pass "$dep is installed"
  else
    test_info "$dep is not installed (optional)"
  fi
done
echo

echo "6. Testing zoxide Integration"
echo "------------------------------"
if command -v zoxide &>/dev/null; then
  test_pass "zoxide is installed"

  # Check if zoxide init is in zshrc
  if grep -q "zoxide init" "$DOTFILES/terminal/zsh/zshrc"; then
    test_pass "zoxide init found in zshrc"
  else
    test_fail "zoxide init NOT found in zshrc"
  fi

  # Check if cd is aliased to z
  if alias cd 2>/dev/null | grep -q "z"; then
    test_pass "cd is aliased to z (zoxide)"
  else
    test_info "cd alias to z not active in this session (will work after reload)"
  fi
else
  test_fail "zoxide is not installed"
  test_info "Install with: brew install zoxide"
fi
echo

echo "7. Testing File Structure"
echo "--------------------------"
required_dirs=("$DOTFILES/terminal/zsh/aliases" "$DOTFILES/terminal/zsh/functions")
for dir in "${required_dirs[@]}"; do
  if [[ -d "$dir" ]]; then
    test_pass "Directory exists: $dir"
  else
    test_fail "Directory missing: $dir"
  fi
done

required_files=("$DOTFILES/terminal/zsh/zshrc" "$DOTFILES/terminal/zsh/README.md")
for file in "${required_files[@]}"; do
  if [[ -f "$file" ]]; then
    test_pass "File exists: $(basename "$file")"
  else
    test_fail "File missing: $(basename "$file")"
  fi
done
echo

echo "8. Testing Backup Files"
echo "-----------------------"
if [[ -f "$DOTFILES/terminal/zsh/aliases.sh.backup" ]]; then
  test_pass "Backup found: aliases.sh.backup"
else
  test_info "No backup: aliases.sh.backup (may have been deleted)"
fi

if [[ -f "$DOTFILES/terminal/zsh/functions.sh.backup" ]]; then
  test_pass "Backup found: functions.sh.backup"
else
  test_info "No backup: functions.sh.backup (may have been deleted)"
fi
echo

echo "9. Testing Profile Gating"
echo "-------------------------"
# Each probe runs a login shell against a throwaway $HOME holding nothing but
# a .zshrc symlink into this checkout. That makes the result independent of
# whether THIS machine has a ~/.dotfiles-profile — the first version of these
# tests asserted "undeclared means personal" and passed here only because no
# marker file existed, then failed the moment it ran after a work install.
#
# Resolving $DOTFILES through that symlink is also part of what is under test,
# so it is deliberately not passed in.
_profile_probe() {
  local marker="$1" profile_env="$2" expr="$3"
  local probe_home
  probe_home="$(mktemp -d -t zprofile-XXXXXX)"
  ln -s "$DOTFILES/terminal/zsh/zshrc" "$probe_home/.zshrc"
  [[ -n "$marker" ]] && print -r -- "$marker" > "$probe_home/.dotfiles-profile"

  if [[ -n "$profile_env" ]]; then
    env -i HOME="$probe_home" PATH="$PATH" TERM=dumb DOTFILES_PROFILE="$profile_env" \
      zsh -i -c "$expr" 2>/dev/null
  else
    env -i HOME="$probe_home" PATH="$PATH" TERM=dumb \
      zsh -i -c "$expr" 2>/dev/null
  fi

  rm -rf "$probe_home"
}

# Precedence: environment variable, then marker file, then the default.
if [[ "$(_profile_probe "" "" 'echo $DOTFILES_PROFILE')" == "personal" ]]; then
  test_pass "no marker and no env var defaults to personal"
else
  test_fail "no marker and no env var defaults to personal"
fi

if [[ "$(_profile_probe work "" 'echo $DOTFILES_PROFILE')" == "work" ]]; then
  test_pass "a work marker file is honoured"
else
  test_fail "a work marker file is honoured"
fi

if [[ "$(_profile_probe work personal 'echo $DOTFILES_PROFILE')" == "personal" ]]; then
  test_pass "the env var overrides the marker file"
else
  test_fail "the env var overrides the marker file"
fi

if [[ "$(_profile_probe "" work 'echo $DOTFILES_PROFILE')" == "work" ]]; then
  test_pass "the env var alone is honoured"
else
  test_fail "the env var alone is honoured"
fi

if [[ "$(_profile_probe nonsense "" 'echo $DOTFILES_PROFILE')" == "personal" ]]; then
  test_pass "an unrecognised marker falls back to personal"
else
  test_fail "an unrecognised marker falls back to personal"
fi

# What the profile actually gates.
if [[ -z "$(_profile_probe work "" 'echo $AUDIO')" ]]; then
  test_pass "work leaves the volume shortcuts unset"
else
  test_fail "work leaves the volume shortcuts unset"
fi

if [[ -n "$(_profile_probe personal "" 'echo $AUDIO')" ]]; then
  test_pass "personal exports the volume shortcuts"
else
  test_fail "personal exports the volume shortcuts"
fi

if [[ "$(_profile_probe work "" 'type -w plex 2>/dev/null | cut -d: -f2')" != *function* ]]; then
  test_pass "work does not define plex"
else
  test_fail "work does not define plex"
fi

if [[ "$(_profile_probe personal "" 'type -w plex 2>/dev/null | cut -d: -f2')" == *function* ]]; then
  test_pass "personal defines plex"
else
  test_fail "personal defines plex"
fi

# $DOTFILES must resolve from the zshrc's own location, or the alias and
# function loops have nothing to iterate when the checkout is not ~/dotfiles.
if [[ "$(_profile_probe "" "" 'echo $DOTFILES')" == "$DOTFILES" ]]; then
  test_pass "\$DOTFILES self-resolves to the checkout"
else
  test_fail "\$DOTFILES self-resolves to the checkout"
fi
echo

echo "==================================="
echo "Test Summary"
echo "==================================="
echo -e "${GREEN}Passed:${NC} $pass_count"
echo -e "${RED}Failed:${NC} $fail_count"
echo

if [[ $fail_count -eq 0 ]]; then
  echo -e "${GREEN}All tests passed!${NC}"
  echo
  echo "Your shell configuration is ready to use."
  echo "Run 'source $DOTFILES/terminal/zsh/zshrc' or 'reload' to activate."
  exit 0
else
  echo -e "${RED}Some tests failed.${NC}"
  echo
  echo "Please review the failures above and fix any issues."
  echo "See README.md for troubleshooting help."
  exit 1
fi
