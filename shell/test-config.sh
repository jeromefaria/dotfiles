#!/usr/bin/env zsh
# Test script for the refactored shell configuration
# Usage: zsh test-config.sh

echo "==================================="
echo "Shell Configuration Test Suite"
echo "==================================="
echo

# Set DOTFILES if not set
: ${DOTFILES:="$HOME/dotfiles"}

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
for alias_file in "$DOTFILES/shell/aliases"/*.sh; do
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
for func_file in "$DOTFILES/shell/functions"/*.sh; do
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
for alias_file in "$DOTFILES/shell/aliases"/*.sh; do
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
for func_file in "$DOTFILES/shell/functions"/*.sh; do
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
  if grep -q "zoxide init" "$DOTFILES/shell/zshrc"; then
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
required_dirs=("$DOTFILES/shell/aliases" "$DOTFILES/shell/functions")
for dir in "${required_dirs[@]}"; do
  if [[ -d "$dir" ]]; then
    test_pass "Directory exists: $dir"
  else
    test_fail "Directory missing: $dir"
  fi
done

required_files=("$DOTFILES/shell/zshrc" "$DOTFILES/shell/README.md")
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
if [[ -f "$DOTFILES/shell/aliases.sh.backup" ]]; then
  test_pass "Backup found: aliases.sh.backup"
else
  test_info "No backup: aliases.sh.backup (may have been deleted)"
fi

if [[ -f "$DOTFILES/shell/functions.sh.backup" ]]; then
  test_pass "Backup found: functions.sh.backup"
else
  test_info "No backup: functions.sh.backup (may have been deleted)"
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
  echo "Run 'source $DOTFILES/shell/zshrc' or 'reload' to activate."
  exit 0
else
  echo -e "${RED}Some tests failed.${NC}"
  echo
  echo "Please review the failures above and fix any issues."
  echo "See README.md for troubleshooting help."
  exit 1
fi
