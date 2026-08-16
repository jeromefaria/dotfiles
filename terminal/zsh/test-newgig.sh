#!/usr/bin/env zsh
# Integration tests for newgig — the client-gig scaffolder in functions/dev.sh.
#
# Strategy: source dev.sh to load newgig, sandbox via mktemp -d, override
# WORK to point at the sandbox, exercise scenarios, assert on shape and
# file contents. No real ~/Work is touched.
#
# Usage: zsh test-newgig.sh

emulate zsh
setopt no_err_return err_exit no_unset pipe_fail

SCRIPT_DIR="${${(%):-%N}:A:h}"
DEV_FUNCTIONS="$SCRIPT_DIR/functions/dev.sh"

if [[ -t 1 ]]; then
  GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; BLUE=$'\033[0;34m'; NC=$'\033[0m'
else
  GREEN=''; RED=''; YELLOW=''; BLUE=''; NC=''
fi

PASS=0
FAIL=0
TESTROOT="$(mktemp -d -t newgig-test-XXXXXX)"

cleanup() {
  if [[ -n "${TESTROOT:-}" && -d "$TESTROOT" ]]; then
    chmod -R u+w "$TESTROOT" 2>/dev/null
    rm -rf "$TESTROOT"
  fi
}
trap cleanup EXIT

print -P "${BLUE}━━━ newgig tests ━━━${NC}"
print "Test workspace: $TESTROOT"
print ""

# Source the function under test.
setopt no_err_exit
source "$DEV_FUNCTIONS"
setopt err_exit

pass() { print -P "  ${GREEN}✓${NC} $1"; PASS=$((PASS + 1)); }
fail() {
  print -P "  ${RED}✗${NC} $1"
  [[ -n "${2:-}" ]] && print -P "    ${YELLOW}$2${NC}"
  FAIL=$((FAIL + 1))
}

# Fresh WORK sandbox for each test — nuke and recreate.
setup_test() {
  W="$TESTROOT/work"
  rm -rf "$W"
  mkdir -p "$W"
  export WORK="$W"
}

# Run newgig quietly with err_exit off so a return 1 doesn't kill the runner.
run_newgig() {
  setopt no_err_exit
  newgig "$@" >/dev/null 2>&1
  local rc=$?
  setopt err_exit
  return $rc
}

# ─── TEST 1: shape WITHOUT project ─────────────────────────────────────────
setup_test
print "TEST 1: fresh scaffold without project arg creates expected shape"
run_newgig acme
if [[ -f "$W/acme/README.md" \
   && -f "$W/acme/CLAUDE.md" \
   && -f "$W/acme/doc/README.md" \
   && -f "$W/acme/doc/active_tasks.md" \
   && -d "$W/acme/doc/archive" \
   && ! -e "$W/acme/src" ]]; then
  pass "shape: README + CLAUDE + doc/{README,active_tasks,archive} + no src/"
else
  fail "shape mismatch" "expected 4 files + doc/archive; got $(find "$W/acme" 2>/dev/null | wc -l | tr -d ' ') entries"
fi
print ""

# ─── TEST 2: shape WITH project ────────────────────────────────────────────
setup_test
print "TEST 2: fresh scaffold with project arg adds src/<project>/"
run_newgig acme frontend
if [[ -d "$W/acme/src/frontend" && -z "$(ls -A "$W/acme/src/frontend" 2>/dev/null)" ]]; then
  pass "src/frontend/ exists and is empty"
else
  fail "src/frontend/ missing or non-empty" "$(ls -la "$W/acme/src/" 2>&1)"
fi
print ""

# ─── TEST 3: refuses when client dir exists ────────────────────────────────
setup_test
print "TEST 3: refuses when client dir already exists"
run_newgig acme
if run_newgig acme; then
  fail "second newgig acme should have failed but returned 0"
else
  pass "second invocation refused (exit non-zero)"
fi
print ""

# ─── TEST 4: rejects invalid client names ─────────────────────────────────
print "TEST 4: rejects invalid client names"
for bad in "../evil" ".hidden" "" "foo/bar"; do
  setup_test
  if run_newgig "$bad"; then
    fail "should have rejected client='$bad' but succeeded"
  elif [[ -n "$(ls -A "$W" 2>/dev/null)" ]]; then
    fail "rejected client='$bad' but left files in \$WORK"
  else
    pass "rejected client='$bad' cleanly"
  fi
done
print ""

# ─── TEST 5: rejects invalid project names ────────────────────────────────
print "TEST 5: rejects invalid project names"
for bad in "../evil" ".hidden" "foo/bar"; do
  setup_test
  if run_newgig acme "$bad"; then
    fail "should have rejected project='$bad' but succeeded"
  elif [[ -e "$W/acme" ]]; then
    fail "rejected project='$bad' but scaffolded \$W/acme anyway"
  else
    pass "rejected project='$bad' cleanly"
  fi
done
print ""

# ─── TEST 6: template interpolation ────────────────────────────────────────
setup_test
print "TEST 6: template interpolation is correct"
run_newgig acme
today=$(date +%Y-%m-%d)
claude_ok=0
tasks_ok=0
readme_ok=0
grep -q "^# CLAUDE.md — acme$" "$W/acme/CLAUDE.md" && grep -q "^- Started: $today$" "$W/acme/CLAUDE.md" && claude_ok=1
grep -q "^# Active tasks — acme$" "$W/acme/doc/active_tasks.md" && tasks_ok=1
grep -q "^# acme$" "$W/acme/README.md" && readme_ok=1

(( claude_ok )) && pass "CLAUDE.md interpolates \$client and today's date" || fail "CLAUDE.md interpolation broken"
(( tasks_ok )) && pass "doc/active_tasks.md interpolates \$client" || fail "active_tasks.md interpolation broken"
(( readme_ok )) && pass "README.md interpolates \$client" || fail "README.md interpolation broken"
print ""

# ─── TEST 7: rollback on mid-scaffold failure ──────────────────────────────
setup_test
print "TEST 7: rollback wipes partial scaffold on mid-write failure"
# Mock cat to fail on 2nd invocation (the CLAUDE.md write); function's
# err_return + trap should catch and rm -rf the client root.
setopt no_err_exit
cat_calls=0
cat() {
  cat_calls=$((cat_calls + 1))
  if (( cat_calls == 2 )); then
    return 1
  fi
  command cat "$@"
}
newgig acme >/dev/null 2>&1
rc=$?
unset -f cat
setopt err_exit

if (( rc == 0 )); then
  fail "newgig returned 0 despite mocked cat failure (mock did not trigger?)"
elif [[ -e "$W/acme" ]]; then
  fail "rollback did not run — \$W/acme still exists after failure" \
       "$(ls -la "$W/acme" 2>&1)"
else
  pass "rollback wiped partial scaffold (exit=$rc, no leftover)"
fi
print ""

# ─── Summary ───────────────────────────────────────────────────────────────
print -P "${BLUE}━━━ Summary ━━━${NC}"
print -P "${GREEN}Passed:${NC} $PASS"
print -P "${RED}Failed:${NC} $FAIL"
print ""

if (( FAIL == 0 )); then
  print -P "${GREEN}All tests passed.${NC}"
  exit 0
else
  print -P "${RED}Some tests failed.${NC}"
  exit 1
fi
