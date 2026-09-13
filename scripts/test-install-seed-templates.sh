#!/bin/bash
# Integration tests for scripts/install.sh's seed_templates phase.
#
# Strategy: source install.sh under a BASH_SOURCE guard (so main() does not
# run), populate a fake DOTFILES_DIR with a `config/` tree of *.template
# files, then drive seed_templates through the destination-exists / DRY_RUN /
# happy-path / cp-failure branches. No real ~/.config files are touched.
#
# Usage:
#   bash test-install-seed-templates.sh          # quiet
#   bash test-install-seed-templates.sh -v       # verbose

set -uo pipefail

VERBOSE=0
[ "${1:-}" = "-v" ] && VERBOSE=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_SCRIPT="$SCRIPT_DIR/install.sh"

if [ -t 1 ]; then
  GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
else
  GREEN=''; RED=''; YELLOW=''; BLUE=''; NC=''
fi

PASS=0
FAIL=0

TESTROOT="$(mktemp -d -t install-seed-templates-test-XXXXXX)"
FAKE_DOTFILES="$TESTROOT/dotfiles"
FAKE_HOME="$TESTROOT/home"
FAKE_BACKUP="$TESTROOT/backup"

cleanup() {
  if [ -n "${TESTROOT:-}" ] && [ -d "$TESTROOT" ]; then
    chmod -R u+w "$TESTROOT" 2>/dev/null
    rm -rf "$TESTROOT"
  fi
}
trap cleanup EXIT

echo -e "${BLUE}━━━ install.sh seed_templates tests ━━━${NC}"
echo "Test workspace: $TESTROOT"
echo ""

mkdir -p "$FAKE_DOTFILES/config" "$FAKE_HOME" "$FAKE_BACKUP"

# ─── Source install.sh under the BASH_SOURCE guard ─────────────────────
set +e
DOTFILES_DIR="$FAKE_DOTFILES"
HOME="$FAKE_HOME"

# shellcheck source=/dev/null
source "$INSTALL_SCRIPT"
trap - ERR INT TERM
set +e

BACKUP_DIR="$FAKE_BACKUP"
INTERACTIVE=false
DRY_RUN=false

pass() { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS + 1)); }
fail() {
  echo -e "  ${RED}✗${NC} $1"
  [ -n "${2:-}" ] && echo -e "    ${YELLOW}$2${NC}"
  FAIL=$((FAIL + 1))
}

heading() { echo; echo -e "${BLUE}── $1 ──${NC}"; }

# Fresh config/ tree for each test — nuke and repopulate.
setup_templates() {
  rm -rf "$FAKE_DOTFILES/config"
  mkdir -p "$FAKE_DOTFILES/config/foo" "$FAKE_DOTFILES/config/bar/nested"
  echo "foo template content"    > "$FAKE_DOTFILES/config/foo/settings.template"
  echo "nested template content" > "$FAKE_DOTFILES/config/bar/nested/deep.template"
  echo "top-level template"      > "$FAKE_DOTFILES/config/top.template"
}

run_seed() {
  if [ "$VERBOSE" -eq 1 ]; then
    seed_templates
  else
    seed_templates > /dev/null 2>&1
  fi
}

# ─── TEST 1: new destinations get seeded with correct content ──────────
heading "TEST 1: fresh install seeds every template"
setup_templates
DRY_RUN=false
run_seed
[ -f "$FAKE_DOTFILES/config/foo/settings" ] \
  && pass "foo/settings created" \
  || fail "foo/settings missing" "$(ls "$FAKE_DOTFILES/config/foo/")"
[ -f "$FAKE_DOTFILES/config/bar/nested/deep" ] \
  && pass "bar/nested/deep created (nested subdir)" \
  || fail "bar/nested/deep missing"
[ -f "$FAKE_DOTFILES/config/top" ] \
  && pass "top-level template seeded" \
  || fail "top missing"
grep -q "foo template content" "$FAKE_DOTFILES/config/foo/settings" \
  && pass "content copied verbatim" \
  || fail "content mismatch"

# ─── TEST 2: existing destinations are left alone ─────────────────────
heading "TEST 2: existing destination is preserved, not overwritten"
setup_templates
echo "PRE-EXISTING USER CONTENT" > "$FAKE_DOTFILES/config/foo/settings"
DRY_RUN=false
run_seed
grep -q "PRE-EXISTING USER CONTENT" "$FAKE_DOTFILES/config/foo/settings" \
  && pass "pre-existing file preserved" \
  || fail "pre-existing file was clobbered"

# ─── TEST 3: DRY_RUN writes nothing ────────────────────────────────────
heading "TEST 3: DRY_RUN=true writes nothing"
setup_templates
DRY_RUN=true
run_seed
DRY_RUN=false
[ ! -e "$FAKE_DOTFILES/config/foo/settings" ] \
  && pass "foo/settings not created under dry-run" \
  || fail "dry-run created a file"
[ ! -e "$FAKE_DOTFILES/config/top" ] \
  && pass "top not created under dry-run" \
  || fail "dry-run created a file"

# ─── TEST 4: mixed state (some seeded, some skipped) counts correctly ─
heading "TEST 4: mix of new + existing reports each correctly"
setup_templates
echo "already there" > "$FAKE_DOTFILES/config/top"
DRY_RUN=false
output=$(seed_templates 2>&1)
echo "$output" | grep -q "Already present: config/top" \
  && pass "existing dest reported as Already present" \
  || fail "top not reported as Already present" "$output"
echo "$output" | grep -q "Seeded: config/foo/settings" \
  && pass "new dest reported as Seeded" \
  || fail "foo/settings not reported as Seeded" "$output"
echo "$output" | grep -qE "Templates: 2 seeded, 1 already present" \
  && pass "summary line counts match (2 seeded, 1 already)" \
  || fail "summary miscount" "$(echo "$output" | tail -1)"

# ─── TEST 5: filenames with spaces round-trip cleanly ─────────────────
heading "TEST 5: templates in paths with spaces are handled"
setup_templates
mkdir -p "$FAKE_DOTFILES/config/with space"
echo "spaced template" > "$FAKE_DOTFILES/config/with space/file.template"
DRY_RUN=false
run_seed
[ -f "$FAKE_DOTFILES/config/with space/file" ] \
  && pass "template under a path with a space seeded" \
  || fail "spaced-path template missed" "$(ls "$FAKE_DOTFILES/config/with space/")"

# ─── TEST 6: cp failure leaves counts intact ──────────────────────────
# Force cp to fail by making the destination directory read-only. seed_templates
# should print `Failed to seed:` on stderr and not increment the seeded count
# for that entry.
heading "TEST 6: cp failure is surfaced, other templates still complete"
setup_templates
chmod a-w "$FAKE_DOTFILES/config/foo"
DRY_RUN=false
output=$(seed_templates 2>&1)
echo "$output" | grep -q "Failed to seed: config/foo/settings" \
  && pass "cp failure surfaced with 'Failed to seed'" \
  || fail "cp failure not reported" "$output"
[ -f "$FAKE_DOTFILES/config/top" ] \
  && pass "other templates still seeded despite one failure" \
  || fail "one failure aborted the loop"
chmod u+w "$FAKE_DOTFILES/config/foo"

# ─── Summary ─────────────────────────────────────────────────────────
echo
echo -e "${BLUE}━━━ Summary ━━━${NC}"
echo -e "  Passed: ${GREEN}$PASS${NC}"
echo -e "  Failed: ${RED}$FAIL${NC}"
echo
if [ "$FAIL" -eq 0 ]; then
  echo -e "${GREEN}✓ All tests passed${NC}"
  exit 0
else
  echo -e "${RED}✗ $FAIL test(s) failed${NC}"
  exit 1
fi
