#!/bin/bash
# Integration tests for scripts/install.sh's create_symlink + backup_file.
#
# Strategy: source install.sh (under a BASH_SOURCE guard, so main() does not
# run), then exercise create_symlink directly against a tmpdir fake $HOME.
# No real $HOME files are touched.
#
# Usage:
#   bash test-install-symlink.sh           # quiet
#   bash test-install-symlink.sh -v        # verbose

set -uo pipefail

VERBOSE=0
[ "${1:-}" = "-v" ] && VERBOSE=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_SCRIPT="$SCRIPT_DIR/install.sh"

# ─── Colors ────────────────────────────────────────────────────────────
if [ -t 1 ]; then
  GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
else
  GREEN=''; RED=''; YELLOW=''; BLUE=''; NC=''
fi

PASS=0
FAIL=0

# ─── Setup ─────────────────────────────────────────────────────────────
TESTROOT="$(mktemp -d -t install-symlink-test-XXXXXX)"
FAKE_HOME="$TESTROOT/home"
FAKE_DOTFILES="$TESTROOT/dotfiles"
FAKE_BACKUP="$TESTROOT/backup"

cleanup() {
  if [ -n "${TESTROOT:-}" ] && [ -d "$TESTROOT" ]; then
    rm -rf "$TESTROOT"
  fi
}
trap cleanup EXIT

echo -e "${BLUE}━━━ install.sh create_symlink tests ━━━${NC}"
echo "Test workspace: $TESTROOT"
echo ""

mkdir -p "$FAKE_HOME" "$FAKE_DOTFILES" "$FAKE_BACKUP"
# Source content the symlinks will point at
echo "real zshrc content" > "$FAKE_DOTFILES/zshrc"
echo "real gitconfig content" > "$FAKE_DOTFILES/gitconfig"

# ─── Source install.sh under the BASH_SOURCE guard ─────────────────────
# install.sh's strict mode + ERR trap would abort the test runner on the
# first non-zero return, so neutralise both before exercising functions.
# DOTFILES_DIR honours `${VAR:-default}` so we set it before sourcing.
# BACKUP_DIR, DRY_RUN, INTERACTIVE etc are unconditionally reassigned at
# top level of install.sh, so we override them AFTER sourcing.
set +e
DOTFILES_DIR="$FAKE_DOTFILES"
HOME="$FAKE_HOME"

# shellcheck source=/dev/null
source "$INSTALL_SCRIPT"
trap - ERR INT TERM
set +e

# Post-source overrides for the variables install.sh unconditionally sets
BACKUP_DIR="$FAKE_BACKUP"
INTERACTIVE=false
DRY_RUN=false

# ─── Test helpers ──────────────────────────────────────────────────────
assert() {
  local desc="$1"; shift
  if eval "$@" > /dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} $desc"
    PASS=$((PASS + 1))
  else
    echo -e "  ${RED}✗${NC} $desc"
    echo -e "    ${YELLOW}cmd:${NC} $*"
    FAIL=$((FAIL + 1))
  fi
}

heading() {
  echo ""
  echo -e "${BLUE}── $1 ──${NC}"
}

# Wrap create_symlink so its print_* output is hidden unless -v.
do_link() {
  if [ "$VERBOSE" -eq 1 ]; then
    create_symlink "$@"
  else
    create_symlink "$@" > /dev/null 2>&1
  fi
}

# ─── Tests ─────────────────────────────────────────────────────────────

heading "TEST 1: first-time symlink to non-existent target"
do_link "$FAKE_DOTFILES/zshrc" "$FAKE_HOME/.zshrc"
assert "symlink created"                  "[ -L \"$FAKE_HOME/.zshrc\" ]"
assert "symlink points at source"         "[ \"\$(readlink \"$FAKE_HOME/.zshrc\")\" = \"$FAKE_DOTFILES/zshrc\" ]"
assert "content reads through symlink"    "grep -q 'real zshrc content' \"$FAKE_HOME/.zshrc\""

heading "TEST 2: idempotent — re-linking the same correct symlink is a no-op"
# Capture mtime BEFORE re-link; if create_symlink no-ops, mtime stays the same.
mtime_before=$(stat -f %m "$FAKE_HOME/.zshrc" 2>/dev/null || stat -c %Y "$FAKE_HOME/.zshrc")
sleep 1
do_link "$FAKE_DOTFILES/zshrc" "$FAKE_HOME/.zshrc"
mtime_after=$(stat -f %m "$FAKE_HOME/.zshrc" 2>/dev/null || stat -c %Y "$FAKE_HOME/.zshrc")
assert "symlink still present"            "[ -L \"$FAKE_HOME/.zshrc\" ]"
assert "mtime unchanged (no rewrite)"     "[ \"$mtime_before\" = \"$mtime_after\" ]"

heading "TEST 3: existing regular file is backed up before being replaced"
rm -f "$FAKE_HOME/.gitconfig" "$FAKE_BACKUP"/.gitconfig "$FAKE_BACKUP"/gitconfig
echo "user's pre-existing gitconfig" > "$FAKE_HOME/.gitconfig"
do_link "$FAKE_DOTFILES/gitconfig" "$FAKE_HOME/.gitconfig"
assert "symlink now points at source"     "[ \"\$(readlink \"$FAKE_HOME/.gitconfig\")\" = \"$FAKE_DOTFILES/gitconfig\" ]"
assert "original file backed up"          "grep -q 'pre-existing gitconfig' \"$FAKE_BACKUP/.gitconfig\""

heading "TEST 4: --dry-run skips writes entirely"
DRY_RUN=true
rm -f "$FAKE_HOME/.bashrc"
do_link "$FAKE_DOTFILES/zshrc" "$FAKE_HOME/.bashrc"
assert "no symlink created during dry-run" "[ ! -e \"$FAKE_HOME/.bashrc\" ]"
DRY_RUN=false

heading "TEST 5: source-is-a-symlink is rejected (circular-symlink guard)"
ln -sf "$FAKE_DOTFILES/zshrc" "$FAKE_DOTFILES/zshrc.alias"
if create_symlink "$FAKE_DOTFILES/zshrc.alias" "$FAKE_HOME/.zshrc-from-alias" > /dev/null 2>&1; then
  echo -e "  ${RED}✗${NC} create_symlink should refuse a symlink as source"
  FAIL=$((FAIL + 1))
else
  echo -e "  ${GREEN}✓${NC} create_symlink refused symlink-as-source"
  PASS=$((PASS + 1))
fi
assert "no symlink created"               "[ ! -e \"$FAKE_HOME/.zshrc-from-alias\" ]"

heading "TEST 6: missing source is rejected"
if create_symlink "$FAKE_DOTFILES/does-not-exist" "$FAKE_HOME/.nope" > /dev/null 2>&1; then
  echo -e "  ${RED}✗${NC} create_symlink should refuse a missing source"
  FAIL=$((FAIL + 1))
else
  echo -e "  ${GREEN}✓${NC} create_symlink refused missing source"
  PASS=$((PASS + 1))
fi
assert "no symlink created"               "[ ! -e \"$FAKE_HOME/.nope\" ]"

heading "TEST 7: existing symlink to a different source is replaced (KNOWN: not backed up)"
# Documents the audit's flagged risk: a pre-existing symlink (e.g. from a
# previous dotfiles install pointing elsewhere) is rm -rf'd without backup.
# backup_file() skips symlinks (it would `cp -r` and dereference, copying
# the target rather than the link). The test asserts current behaviour so
# any future change forces a deliberate update.
rm -f "$FAKE_HOME/.zshrc-alt"
mkdir -p "$TESTROOT/other-dotfiles"
echo "OTHER repo zshrc" > "$TESTROOT/other-dotfiles/zshrc"
ln -s "$TESTROOT/other-dotfiles/zshrc" "$FAKE_HOME/.zshrc-alt"
rm -f "$FAKE_BACKUP/.zshrc-alt"
do_link "$FAKE_DOTFILES/zshrc" "$FAKE_HOME/.zshrc-alt"
assert "new symlink points at our source" "[ \"\$(readlink \"$FAKE_HOME/.zshrc-alt\")\" = \"$FAKE_DOTFILES/zshrc\" ]"
assert "the original symlink target was NOT backed up (known gap)" "[ ! -e \"$FAKE_BACKUP/.zshrc-alt\" ]"

# ─── Summary ───────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}━━━ Summary ━━━${NC}"
echo -e "  Passed: ${GREEN}$PASS${NC}"
echo -e "  Failed: ${RED}$FAIL${NC}"
echo ""
if [ "$FAIL" -eq 0 ]; then
  echo -e "${GREEN}✓ All tests passed${NC}"
  exit 0
else
  echo -e "${RED}✗ $FAIL test(s) failed${NC}"
  exit 1
fi
