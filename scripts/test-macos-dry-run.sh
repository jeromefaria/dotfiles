#!/bin/bash
# Tests for the dry-run mode of the macOS configuration scripts.
#
# scripts/macos/ applies 192 `defaults write` calls plus systemsetup, pmset,
# scutil, nvram and friends, and had neither tests nor a dry run — the one part
# of this repo that rewrites system preferences with no undo was also the only
# part you could not preview. docs/TESTING.md called it "hard to mock, low
# return", which was true of asserting what each of 192 settings should be, but
# not of asserting that a dry run writes nothing.
#
# Strategy: the mutating commands are shadowed by shell functions in
# helpers.sh, which fall through to `command <name>` when not dry-running. So
# put a recording stub for each on $PATH: if a mutation reaches it, the shadow
# leaked. Nothing here touches the real defaults database.
#
# Usage:
#   bash test-macos-dry-run.sh          # quiet
#   bash test-macos-dry-run.sh -v       # verbose

set -uo pipefail

VERBOSE=0
[ "${1:-}" = "-v" ] && VERBOSE=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELPERS="$SCRIPT_DIR/macos/helpers.sh"
SETUP="$SCRIPT_DIR/macos-setup.sh"

if [ -t 1 ]; then
  GREEN='\033[0;32m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
else
  GREEN=''; RED=''; BLUE=''; NC=''
fi

PASS=0
FAIL=0

TESTROOT="$(mktemp -d -t macos-dry-run-test-XXXXXX)"
STUB_BIN="$TESTROOT/bin"
CALLS="$TESTROOT/calls.log"
TALLY="$TESTROOT/tally.log"

cleanup() { [ -n "${TESTROOT:-}" ] && rm -rf "$TESTROOT"; }
trap cleanup EXIT

echo -e "${BLUE}━━━ macOS dry-run tests ━━━${NC}"
echo "Test workspace: $TESTROOT"
echo ""

mkdir -p "$STUB_BIN"

# Recording stubs. Reaching one of these means a mutation was NOT intercepted.
for cmd in defaults scutil systemsetup pmset nvram killall mdutil chflags spctl diskutil sudo; do
  cat > "$STUB_BIN/$cmd" <<STUB
#!/bin/bash
echo "$cmd \$*" >> "$CALLS"
# Reads have to return something plausible so caller logic still works.
case "\$1" in
  read|--get|-get*) echo "stub-value" ;;
esac
exit 0
STUB
  chmod +x "$STUB_BIN/$cmd"
done

pass() { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS + 1)); }
fail() {
  echo -e "  ${RED}✗${NC} $1"
  [ "$VERBOSE" -eq 1 ] && [ -n "${2:-}" ] && echo "      $2"
  FAIL=$((FAIL + 1))
}

# Run a snippet with helpers.sh sourced, the stubs first on PATH, and the
# given dry-run setting. Returns the snippet's output; side effects land in
# $CALLS (a stub was reached) and $TALLY (a mutation was reported).
run_snippet() {
  local dry="$1" snippet="$2"
  : > "$CALLS"
  : > "$TALLY"
  PATH="$STUB_BIN:$PATH" \
  MACOS_DRY_RUN="$dry" \
  MACOS_DRY_RUN_TALLY="$TALLY" \
  HELPERS="$HELPERS" \
    bash -c "source \"\$HELPERS\" >/dev/null 2>&1; $snippet" 2>&1
}

calls_made()  { [ -s "$CALLS" ]; }
tally_count() { wc -l < "$TALLY" 2>/dev/null | tr -d ' '; }

# ─── TEST 1: a dry run reaches no mutating binary ──────────────────────
echo "── TEST 1: dry run writes nothing ──"
run_snippet 1 '
  defaults write com.example.one Key -bool true
  defaults delete com.example.one Key
  sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
  systemsetup -setremotelogin off
  scutil --set ComputerName "Nope"
  pmset -a displaysleep 5
  nvram SystemAudioVolume=%80
  killall Finder
  mdutil -i off /
  chflags hidden /tmp/nothing
' >/dev/null

if ! calls_made; then
  pass "no mutating command reached its binary"
else
  fail "no mutating command reached its binary" "$(cat "$CALLS")"
fi

if [ "$(tally_count)" -eq 10 ]; then
  pass "all ten mutations were reported"
else
  fail "all ten mutations were reported" "tally=$(tally_count): $(cat "$TALLY")"
fi

# ─── TEST 2: without dry run the same calls go through ─────────────────
echo "── TEST 2: a real run is unaffected ──"
run_snippet 0 '
  defaults write com.example.two Key -bool true
  systemsetup -setremotelogin off
  killall Finder
' >/dev/null

if [ "$(grep -c . "$CALLS")" -eq 3 ]; then
  pass "all three reached their binary"
else
  fail "all three reached their binary" "$(cat "$CALLS")"
fi

if [ "$(tally_count)" -eq 0 ]; then
  pass "nothing reported as skipped"
else
  fail "nothing reported as skipped" "$(cat "$TALLY")"
fi

# ─── TEST 3: reads still work during a dry run ─────────────────────────
echo "── TEST 3: reads pass through ──"
out=$(run_snippet 1 'defaults read com.example.three Key')
if echo "$out" | grep -q 'stub-value'; then
  pass "defaults read reaches the binary"
else
  fail "defaults read reaches the binary" "$out"
fi

# scutil --get feeds the summary's hostname lines; swallowing it made the
# dry run misreport the machine's current name rather than a pending change.
out=$(run_snippet 1 'scutil --get ComputerName')
if echo "$out" | grep -q 'stub-value'; then
  pass "scutil --get reaches the binary"
else
  fail "scutil --get reaches the binary" "$out"
fi

out=$(run_snippet 1 'systemsetup -getremotelogin')
if echo "$out" | grep -q 'stub-value'; then
  pass "systemsetup -get* reaches the binary"
else
  fail "systemsetup -get* reaches the binary" "$out"
fi

# ─── TEST 4: sudo is intercepted, not just `defaults` ──────────────────
echo "── TEST 4: sudo cannot slip a write past the shadow ──"
# sudo execs the real binary, so a function named `defaults` can never see
# `sudo defaults write`. Four such calls exist in base.sh and personal.sh.
run_snippet 1 'sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false' >/dev/null
if ! calls_made; then
  pass "sudo itself is shadowed"
else
  fail "sudo itself is shadowed" "$(cat "$CALLS")"
fi

# ─── TEST 5: the count survives a subprocess ───────────────────────────
echo "── TEST 5: mutations in a child process are counted ──"
# The modules run as separate bash processes, so a shell variable cannot carry
# the count back. An early version reported 4 skips out of 95 for that reason.
run_snippet 1 '
  defaults write com.example.five A -bool true
  bash -c "source \"\$HELPERS\" >/dev/null 2>&1; defaults write com.example.five B -bool true"
' >/dev/null
if [ "$(tally_count)" -eq 2 ]; then
  pass "both parent and child mutations counted"
else
  fail "both parent and child mutations counted" "tally=$(tally_count)"
fi

# ─── TEST 6: macos-setup.sh honours and exports the flag ───────────────
echo "── TEST 6: macos-setup.sh --dry-run ──"
if grep -q -- '--dry-run' "$SETUP"; then
  pass "--dry-run is a documented flag"
else
  fail "--dry-run is a documented flag"
fi

if grep -q 'export MACOS_DRY_RUN' "$SETUP"; then
  pass "the flag is exported to the modules"
else
  fail "the flag is exported to the modules"
fi

# Neither is needed when nothing will be written, and prompting for a password
# to change nothing teaches people to type it without reading.
if grep -q 'if ! macos_dry_run; then' "$SETUP" && grep -q 'request_sudo' "$SETUP"; then
  pass "the sudo prompt is skipped in a dry run"
else
  fail "the sudo prompt is skipped in a dry run"
fi

if grep -q '! \$SKIP_BACKUP && ! macos_dry_run' "$SETUP"; then
  pass "the pre-apply backup is skipped in a dry run"
else
  fail "the pre-apply backup is skipped in a dry run"
fi

# ─── TEST 7: every mutating command in the modules is shadowed ──────────
echo "── TEST 7: no mutating command is left unshadowed ──"
# Guards against a module gaining a new mutation that the dry run would miss.
unshadowed=""
for cmd in defaults scutil systemsetup pmset nvram killall mdutil chflags spctl diskutil sudo; do
  if grep -qE "^${cmd}\(\)|^    ${cmd}\(\)|^${cmd}\(\) \{" "$HELPERS" \
     || grep -q "for _macos_cmd in.*\b${cmd}\b" "$HELPERS"; then
    continue
  fi
  unshadowed="$unshadowed $cmd"
done
if [ -z "$unshadowed" ]; then
  pass "all eleven mutating commands have a shadow"
else
  fail "all eleven mutating commands have a shadow" "missing:$unshadowed"
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
