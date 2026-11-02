#!/bin/bash
# Integration tests for scripts/health-check.sh.
#
# Strategy: run the real script as a subprocess against a fake DOTFILES_DIR and
# a fake HOME, and read its output. It resolves lib/io.sh from its own location
# rather than from DOTFILES_DIR, so pointing DOTFILES_DIR at a sandbox is
# enough to control everything it inspects.
#
# This suite exists because health-check.sh had no tests and two things rotted
# where nothing could see them. Its per-item config list named four configs the
# repo had stopped tracking and warned about seven the work profile leaves out
# on purpose — invisible because the list is only reached on a work machine,
# and the machine this was written on is personal. And `set -e` meant a bare
# check_symlink returning 1 killed the script at its first finding, so the one
# run with something to report stopped after reporting one thing. Both are the
# same failure: a reporter nobody ever watched report.
#
# Usage:
#   bash test-health-check.sh          # quiet
#   bash test-health-check.sh -v       # verbose

set -uo pipefail

VERBOSE=0
[ "${1:-}" = "-v" ] && VERBOSE=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HEALTH_SCRIPT="$SCRIPT_DIR/health-check.sh"
INSTALL_SCRIPT="$SCRIPT_DIR/install.sh"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -t 1 ]; then
  GREEN='\033[0;32m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
else
  GREEN=''; RED=''; BLUE=''; NC=''
fi

PASS=0
FAIL=0

TESTROOT="$(mktemp -d -t health-check-test-XXXXXX)"
FAKE_DOTFILES="$TESTROOT/dotfiles"
FAKE_HOME="$TESTROOT/home"
STUB_BIN="$TESTROOT/bin"

cleanup() {
  if [ -n "${TESTROOT:-}" ] && [ -d "$TESTROOT" ]; then
    chmod -R u+w "$TESTROOT" 2>/dev/null
    rm -rf "$TESTROOT"
  fi
}
trap cleanup EXIT

pass() { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS + 1)); }
fail() {
  echo -e "  ${RED}✗${NC} $1"
  [ "$VERBOSE" -eq 1 ] && [ -n "${2:-}" ] && echo "      $2"
  FAIL=$((FAIL + 1))
}

heading() { echo ""; echo "── $1 ──"; }

echo -e "${BLUE}━━━ health-check.sh tests ━━━${NC}"
echo "Test workspace: $TESTROOT"

# A DOTFILES_DIR shaped like the real one. `faketool` and `docsonly` stand in
# for a tracked config whose app is installed: real names would tie the suite
# to whatever happens to be on the machine running it.
mkdir -p "$FAKE_DOTFILES/config/faketool" \
         "$FAKE_DOTFILES/config/docsonly" \
         "$FAKE_HOME" "$STUB_BIN"
echo "settings" > "$FAKE_DOTFILES/config/faketool/config.toml"
echo "# prose, nothing to link" > "$FAKE_DOTFILES/config/docsonly/README.md"

for stub in faketool docsonly; do
  printf '#!/bin/bash\nexit 0\n' > "$STUB_BIN/$stub"
  chmod +x "$STUB_BIN/$stub"
done

# PATH, not DOTFILES_DIR, is what the 3.6 probe reads, and the stubs have to
# win over anything real by the same name.
run_health_check() {
  DOTFILES_DIR="$FAKE_DOTFILES" HOME="$FAKE_HOME" PATH="$STUB_BIN:$PATH" \
    bash "$HEALTH_SCRIPT" 2>&1
}

# ─── TEST 1: a finding does not end the run ────────────────────────────
# The fake HOME has no symlinks at all, so section 2 reports on its first line
# and every check after it has something to say. Under set -e the script exited
# there: no summary, no exit code of its own, and no sign that nine checks had
# never run. Asserted on the summary because that is the part the user reads.
heading "TEST 1: every check runs even when the first one fails"
rm -rf "$FAKE_HOME"
mkdir -p "$FAKE_HOME/.config"
output=$(run_health_check)

for section in "2. Core Configuration Symlinks" "3.6. Installed Apps" \
               "8. Broken Symlinks Check" "Summary"; do
  if echo "$output" | grep -q "$section"; then
    pass "reached: $section"
  else
    fail "reached: $section" "the run stopped before it"
  fi
done

# The tally, not just the heading. A missing symlink is a warning rather than
# an error here, so the number to read is the warning count — and it has to be
# well above one, which is the whole property: under set -e the script died on
# the first finding, so a run that ought to report a dozen reported one.
finding_count=$(echo "$output" | grep -oE '[0-9]+ warning\(s\)' | grep -oE '^[0-9]+')

if [ -n "$finding_count" ] && [ "$finding_count" -gt 1 ]; then
  pass "the summary tallies all $finding_count findings, not just the first"
else
  fail "the summary tallies every finding" "counted '${finding_count:-nothing}'"
fi

# ─── TEST 2: an installed app with an unlinked config is named ─────────
# The case this check was added for. config/faketool is tracked, faketool is on
# PATH, and nothing links the two — which until now produced no output from any
# tool in this repo, on any profile, ever.
heading "TEST 2: an installed app whose config is not linked is reported"
if echo "$output" | grep -q "faketool is installed but config/faketool is not linked"; then
  pass "faketool is named"
else
  fail "faketool is named" "$(echo "$output" | sed -n '/3.6./,/^$/p')"
fi

# ─── TEST 3: documentation-only directories are not reported ───────────
# config/starship holds a README and nothing else, so on a real machine with a
# prompt installed it would be reported on every single run. A directory with
# nothing to link is not a finding.
heading "TEST 3: a config directory holding only documentation is skipped"
if echo "$output" | grep -q "docsonly is installed"; then
  fail "docsonly is not reported" "a prose-only directory was treated as linkable"
else
  pass "docsonly is not reported"
fi

# ─── TEST 4: linking it silences the report ────────────────────────────
heading "TEST 4: the report clears once the config is linked"
ln -s "$FAKE_DOTFILES/config/faketool" "$FAKE_HOME/.config/faketool"
output=$(run_health_check)

if echo "$output" | grep -q "faketool is installed but"; then
  fail "faketool is no longer reported" "still reported after being linked"
else
  pass "faketool is no longer reported"
fi

if echo "$output" | grep -q "Every installed app with a config in this repo has it linked"; then
  pass "the check reports itself clean"
else
  fail "the check reports itself clean" "$(echo "$output" | sed -n '/3.6./,/^$/p')"
fi

# ─── TEST 5: the whole-directory link short-circuits the check ─────────
# Under one link every tracked config is live by definition, so there is
# nothing a probe could find and a warning there would always be wrong.
heading "TEST 5: nothing is reported under the whole-directory link"
rm -rf "$FAKE_HOME"
mkdir -p "$FAKE_HOME"
ln -s "$FAKE_DOTFILES/config" "$FAKE_HOME/.config"
output=$(run_health_check)

if echo "$output" | grep -q "Whole-directory link in use"; then
  pass "the check says why it has nothing to do"
else
  fail "the check says why it has nothing to do" "$(echo "$output" | sed -n '/3.6./,/^$/p')"
fi

if echo "$output" | grep -q "is installed but config/"; then
  fail "no app is reported as unlinked" "reported a config reachable through the link"
else
  pass "no app is reported as unlinked"
fi

# ─── TEST 6: the two per-item lists still agree ────────────────────────
# Against the real repo, not the sandbox. health-check's required_items is the
# set link_dotfiles links for the work profile, and the two are written out
# separately — a health check that sourced the installer to read one array
# would be worse than this. tmuxinator is added by hand because install.sh
# links it outside the array: its source lives under terminal/tmux/ and is a
# relative symlink inside config/, which create_symlink refuses as a source.
heading "TEST 6: health-check's required set matches what install.sh links"
install_set=$(
  { sed -n '/local config_items=(/,/^    )$/p' "$INSTALL_SCRIPT" \
      | grep -o '"[^"]*"' | tr -d '"'; echo tmuxinator; } | sort
)
health_set=$(
  sed -n '/^    required_items=(/,/^    )$/p' "$HEALTH_SCRIPT" \
    | grep -o '"[^"]*"' | tr -d '"' | cut -d: -f1 | sort
)

if [ -n "$install_set" ] && [ -n "$health_set" ]; then
  pass "both lists were found in source"
else
  fail "both lists were found in source" "one extraction came back empty"
fi

if [ "$install_set" = "$health_set" ]; then
  pass "the two lists name the same configs"
else
  fail "the two lists name the same configs" \
       "$(diff <(echo "$install_set") <(echo "$health_set") | tr '\n' ' ')"
fi

# ─── TEST 7: every required source exists in the tree ──────────────────
# The rot this suite was written for: the old list named ncmpcpp, neofetch,
# ranger and yarn long after the repo stopped tracking them, and the
# `[ -e ]` guard around each check meant four dead entries passed in silence.
heading "TEST 7: every required config still exists in the repo"
missing=""
required_sources=$(
  sed -n '/^    required_items=(/,/^    )$/p' "$HEALTH_SCRIPT" \
    | grep -o '"[^"]*"' | tr -d '"' | cut -d: -f2
)

for source in $required_sources; do
  [ -e "$REPO_ROOT/$source" ] || missing="$missing $source"
done

if [ -z "$missing" ]; then
  pass "all $(echo "$required_sources" | wc -l | tr -d ' ') sources are present"
else
  fail "a required config no longer exists" "dead entries:$missing"
fi

# ─── Summary ───────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}━━━ Summary ━━━${NC}"
echo -e "  Passed: $PASS"
echo -e "  Failed: $FAIL"
echo ""
if [ "$FAIL" -eq 0 ]; then
  echo -e "${GREEN}✓ All tests passed${NC}"
  exit 0
else
  echo -e "${RED}✗ $FAIL test(s) failed${NC}"
  exit 1
fi
