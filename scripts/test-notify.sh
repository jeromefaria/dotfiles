#!/bin/bash
# Tests for scripts/lib/bounded.sh and scripts/lib/notify.sh.
#
# Strategy: mktemp sandbox with stub `terminal-notifier` and `osascript` on
# $PATH. Each stub's behaviour (succeed / fail / hang) is chosen per test by an
# env var, so the same stub covers every branch. The hang stubs are what the
# suite exists for: a real terminal-notifier blocks forever when there is no
# Aqua session, and the bound is the only thing standing between that and a
# launchd agent parked on its lock until the next login.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -t 1 ]; then
  GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
else
  GREEN=''; RED=''; YELLOW=''; BLUE=''; NC=''
fi

PASS=0
FAIL=0

TESTROOT="$(mktemp -d -t notify-test-XXXXXX)"
STUB_BIN="$TESTROOT/bin"
CALLS="$TESTROOT/calls"

cleanup() {
  [ -n "${TESTROOT:-}" ] && [ -d "$TESTROOT" ] && rm -rf "$TESTROOT"
}
trap cleanup EXIT

echo -e "${BLUE}━━━ bounded + notify tests ━━━${NC}"
echo "Test workspace: $TESTROOT"
echo ""

mkdir -p "$STUB_BIN"

pass() { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS + 1)); }
fail() {
  echo -e "  ${RED}✗${NC} $1"
  [ -n "${2:-}" ] && echo -e "    ${YELLOW}$2${NC}"
  FAIL=$((FAIL + 1))
}
heading() { echo; echo -e "${BLUE}── $1 ──${NC}"; }

# ─── Stubs ─────────────────────────────────────────────────────────────
# Each records its argv, then behaves per ${NAME}_MODE: ok | fail | hang.
for stub in terminal-notifier osascript; do
  cat > "$STUB_BIN/$stub" <<STUB
#!/bin/bash
echo "$stub \$*" >> "\$CALLS"
case "\${STUB_MODE_${stub//-/_}:-ok}" in
  hang) sleep "${STUB_HANG_SECONDS:-20}" ;;
  fail) exit 1 ;;
esac
exit 0
STUB
  chmod +x "$STUB_BIN/$stub"
done

export CALLS

# coreutils installs `timeout` into Homebrew's bin. A PATH of just the system
# directories therefore has no `timeout` at all, which is exactly the machine
# the bash fallback exists for — no shadowing games needed.
SYSTEM_PATH="/usr/bin:/bin:/usr/sbin:/sbin"

# Run a snippet with the libs loaded and the stubs in front of $PATH.
run_snippet() {
  local snippet="$1"
  : > "$CALLS"
  env PATH="$STUB_BIN:$PATH" \
      LIBDIR="$SCRIPT_DIR/lib" \
      bash -c 'source "$LIBDIR/notify.sh"; '"$snippet" 2>&1
}

# Same, but with coreutils' timeout hidden so run_bounded takes the bash path.
run_snippet_no_timeout() {
  local snippet="$1"
  : > "$CALLS"
  env PATH="$STUB_BIN:$SYSTEM_PATH" \
      LIBDIR="$SCRIPT_DIR/lib" \
      bash -c 'source "$LIBDIR/notify.sh"; '"$snippet" 2>&1
}

# Wall-clock cost of a snippet. The stubs cap their own wedge (STUB_HANG_SECONDS)
# rather than sleeping indefinitely, so a regression in the bound shows up as a
# timing assertion that fails instead of a suite that hangs — which is the whole
# failure mode under test.
elapsed_of() {
  local start end
  start=$(date +%s)
  eval "$1" >/dev/null 2>&1
  end=$(date +%s)
  echo $(( end - start ))
}

# ─── TEST 1: run_bounded passes the command's exit status through ──────
heading "TEST 1: run_bounded is transparent for a command that finishes"
out=$(run_snippet 'run_bounded 5 true; echo "status=$?"')
echo "$out" | grep -q "status=0" \
  && pass "a success returns 0" \
  || fail "success not passed through" "$out"
out=$(run_snippet 'run_bounded 5 bash -c "exit 3"; echo "status=$?"')
echo "$out" | grep -q "status=3" \
  && pass "an exit code is returned verbatim (3)" \
  || fail "exit code not passed through" "$out"

# ─── TEST 2: stdout is capturable, so $(run_bounded ...) works ─────────
heading "TEST 2: output passes through for capture"
out=$(run_snippet 'listing="$(run_bounded 5 echo hello)"; echo "got=[$listing]"')
echo "$out" | grep -q "got=\[hello\]" \
  && pass "stdout reaches the caller's command substitution" \
  || fail "stdout was swallowed" "$out"
out=$(run_snippet 'listing="$(run_bounded 5 bash -c "echo oops >&2" 2>&1)"; echo "got=[$listing]"')
echo "$out" | grep -q "got=\[oops\]" \
  && pass "stderr is capturable with 2>&1 (the probe's contract)" \
  || fail "stderr was swallowed" "$out"

# ─── TEST 3: a hanging command is killed, and 124 is returned ─────────
heading "TEST 3: run_bounded kills a command that outlives its bound"
secs=$(elapsed_of 'run_snippet "run_bounded 1 sleep 60"')
[ "$secs" -le 5 ] \
  && pass "returned in ${secs}s, not 60" \
  || fail "did not bound the hang" "took ${secs}s"
out=$(run_snippet 'run_bounded 1 sleep 60; echo "status=$?"')
echo "$out" | grep -q "status=124" \
  && pass "timeout reports 124" \
  || fail "wrong status on timeout" "$out"

# ─── TEST 4: the gtimeout + bash-fallback paths ───────────────────────
# The whole point of the fallback: a machine whose setup never finished is the
# one most likely to hang, so an absent coreutils must not mean unbounded.
heading "TEST 4: bounding when coreutils' timeout is not on the PATH"
secs=$(elapsed_of 'run_snippet_no_timeout "run_bounded 1 sleep 60"')
[ "$secs" -le 5 ] \
  && pass "fallback returned in ${secs}s, not 60" \
  || fail "fallback ran unbounded" "took ${secs}s"
out=$(run_snippet_no_timeout 'run_bounded 1 sleep 60; echo "status=$?"')
echo "$out" | grep -q "status=124" \
  && pass "fallback reports 124" \
  || fail "fallback status wrong" "$out"
out=$(run_snippet_no_timeout 'run_bounded 5 bash -c "exit 3"; echo "status=$?"')
echo "$out" | grep -q "status=3" \
  && pass "fallback passes an exit code through (3)" \
  || fail "fallback lost the exit code" "$out"

# Older coreutils installs the command prefixed. With `timeout` off the PATH
# but `gtimeout` on it, the prefixed name must be used rather than the bash
# fallback — otherwise a machine with coreutils still pays for polling.
cat > "$STUB_BIN/gtimeout" <<'STUB'
#!/bin/bash
echo "gtimeout $*" >> "$CALLS"
exit 0
STUB
chmod +x "$STUB_BIN/gtimeout"
out=$(run_snippet_no_timeout 'run_bounded 7 true; cat "$CALLS"')
echo "$out" | grep -q "^gtimeout 7 true" \
  && pass "gtimeout is used when timeout is absent" \
  || fail "gtimeout branch not taken" "$out"
rm -f "$STUB_BIN/gtimeout"

# ─── TEST 5: a killed child does not leak shell noise into output ─────
# `wait` on a signalled job makes bash announce "Terminated" on its own
# stderr. The pre-flight probe captures 2>&1 and greps it for a permission
# denial, so that announcement would be read as command output.
heading "TEST 5: a killed child leaves no 'Terminated' in captured output"
out=$(run_snippet_no_timeout 'listing="$(run_bounded 1 sleep 60 2>&1)"; echo "got=[$listing]"')
echo "$out" | grep -qi "terminated" \
  && fail "shell job noise leaked into the capture" "$out" \
  || pass "capture stayed clean"

# ─── TEST 6: notify_post prefers terminal-notifier ───────────────────
heading "TEST 6: notify_post prefers terminal-notifier and reports delivery"
out=$(run_snippet 'notify_post "T" "M"; echo "status=$?"; cat "$CALLS"')
echo "$out" | grep -q "status=0" \
  && pass "reports NOTIFY_DELIVERED (0)" \
  || fail "did not report delivery" "$out"
echo "$out" | grep -q "^terminal-notifier .*-title T" \
  && pass "terminal-notifier was invoked with the title" \
  || fail "terminal-notifier not invoked" "$out"
echo "$out" | grep -q "osascript" \
  && fail "fell back to osascript despite success" "$out" \
  || pass "osascript not touched when the first notifier works"

# ─── TEST 7: the group id reaches terminal-notifier ──────────────────
heading "TEST 7: NOTIFIER_GROUP is passed through"
out=$(run_snippet 'export NOTIFIER_GROUP=mygroup; notify_post "T" "M"; cat "$CALLS"')
echo "$out" | grep -q -- "-group mygroup" \
  && pass "caller's group id used" \
  || fail "group id not forwarded" "$out"
out=$(run_snippet 'notify_post "T" "M"; cat "$CALLS"')
echo "$out" | grep -q -- "-group dotfiles" \
  && pass "defaults to the 'dotfiles' group" \
  || fail "default group wrong" "$out"

# ─── TEST 8: osascript is the fallback when terminal-notifier fails ──
heading "TEST 8: a failing terminal-notifier falls back to osascript"
out=$(run_snippet 'export STUB_MODE_terminal_notifier=fail; notify_post "T" "M"; echo "status=$?"; cat "$CALLS"')
echo "$out" | grep -q "status=0" \
  && pass "still reports delivery via the fallback" \
  || fail "fallback did not deliver" "$out"
echo "$out" | grep -q "^osascript .*display notification" \
  && pass "osascript was invoked" \
  || fail "osascript not invoked" "$out"

# ─── TEST 9: a HANGING terminal-notifier does not hang notify_post ───
# This is the regression. A full-install CI run sat for 81 minutes inside a
# notification call and was killed by the job timeout; the orphan the runner
# reaped was named terminal-notifi.
heading "TEST 9: a hanging terminal-notifier is abandoned, not awaited"
secs=$(elapsed_of 'run_snippet "export STUB_MODE_terminal_notifier=hang NOTIFY_TIMEOUT_SECONDS=1; notify_post T M"')
[ "$secs" -le 8 ] \
  && pass "notify_post returned in ${secs}s, not 20" \
  || fail "notify_post hung" "took ${secs}s"
out=$(run_snippet 'export STUB_MODE_terminal_notifier=hang NOTIFY_TIMEOUT_SECONDS=1; notify_post "T" "M"; echo "status=$?"; cat "$CALLS"')
echo "$out" | grep -q "^osascript" \
  && pass "fell through to osascript after the bound" \
  || fail "did not fall through" "$out"
echo "$out" | grep -q "status=0" \
  && pass "the fallback's delivery is still reported" \
  || fail "status wrong after a hang" "$out"

# ─── TEST 10: both notifiers hanging still returns ───────────────────
heading "TEST 10: both notifiers hanging still returns, as failed"
secs=$(elapsed_of 'run_snippet "export STUB_MODE_terminal_notifier=hang STUB_MODE_osascript=hang NOTIFY_TIMEOUT_SECONDS=1; notify_post T M"')
[ "$secs" -le 10 ] \
  && pass "returned in ${secs}s with both notifiers wedged" \
  || fail "hung with both wedged" "took ${secs}s"
out=$(run_snippet 'export STUB_MODE_terminal_notifier=hang STUB_MODE_osascript=hang NOTIFY_TIMEOUT_SECONDS=1; notify_post "T" "M"; echo "status=$?"')
echo "$out" | grep -q "status=1" \
  && pass "reports NOTIFY_FAILED (1), not delivery" \
  || fail "wrong status with both wedged" "$out"

# ─── TEST 11: both failing reports NOTIFY_FAILED ─────────────────────
heading "TEST 11: both notifiers failing reports NOTIFY_FAILED"
out=$(run_snippet 'export STUB_MODE_terminal_notifier=fail STUB_MODE_osascript=fail; notify_post "T" "M"; echo "status=$?"')
echo "$out" | grep -q "status=1" \
  && pass "reports NOTIFY_FAILED (1)" \
  || fail "a total failure was not reported as failed" "$out"

# ─── TEST 12: NOTIFY_ENABLED=0 silences everything ───────────────────
heading "TEST 12: NOTIFY_ENABLED=0 is a silent no-op"
out=$(run_snippet 'export NOTIFY_ENABLED=0; notify_post "T" "M"; echo "status=$?"; echo "calls=[$(cat "$CALLS")]"')
echo "$out" | grep -q "status=2" \
  && pass "reports NOTIFY_DISABLED (2)" \
  || fail "kill switch status wrong" "$out"
echo "$out" | grep -q "calls=\[\]" \
  && pass "no notifier was invoked at all" \
  || fail "the kill switch still invoked a notifier" "$out"

# ─── TEST 13: a quoted message does not break the osascript script ───
heading "TEST 13: quotes in the message survive the osascript fallback"
out=$(run_snippet 'export STUB_MODE_terminal_notifier=fail; notify_post "say \"hi\"" "it\x27s \"quoted\""; echo "status=$?"; cat "$CALLS"')
echo "$out" | grep -q "status=0" \
  && pass "delivery reported with quotes in the text" \
  || fail "quoting broke the fallback" "$out"

# ─── TEST 14: sourcing twice is a no-op (readonly constants) ──────────
# notify.sh declares readonly constants; a second `readonly` on the same name
# is an error, so the load guard is what lets two scripts source it safely.
heading "TEST 14: double-sourcing is safe"
out=$(run_snippet 'source "$LIBDIR/notify.sh"; source "$LIBDIR/bounded.sh"; echo "ok=$?"')
echo "$out" | grep -q "ok=0" \
  && pass "re-sourcing both libs is clean" \
  || fail "re-sourcing errored" "$out"
echo "$out" | grep -qi "readonly" \
  && fail "readonly collision on re-source" "$out" \
  || pass "no readonly collision"

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
