#!/bin/bash
# Integration tests for mail/scripts/manage-sync.sh.
#
# Mirrors test-audio-backup.sh's pattern: tmpdir + fake $HOME + mocked
# `launchctl` on PATH so start/stop/restart/status are exercised against
# a fake plist without touching the user's real LaunchAgents.
#
# Usage:
#   bash test-manage-sync.sh           # quiet
#   bash test-manage-sync.sh -v        # verbose

set -uo pipefail

VERBOSE=0
[ "${1:-}" = "-v" ] && VERBOSE=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANAGE="$SCRIPT_DIR/manage-sync.sh"

# ─── Colors ────────────────────────────────────────────────────────────
if [ -t 1 ]; then
  GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
else
  GREEN=''; RED=''; YELLOW=''; BLUE=''; NC=''
fi

PASS=0
FAIL=0

# ─── Setup ─────────────────────────────────────────────────────────────
TESTROOT="$(mktemp -d -t mail-manage-sync-test-XXXXXX)"
FAKE_HOME="$TESTROOT/home"
PLIST_PATH="$FAKE_HOME/Library/LaunchAgents/com.jeromefaria.mailsync.plist"
SYNC_LOG="$FAKE_HOME/.local/share/mail/sync.log"
ERR_LOG="$FAKE_HOME/.local/share/mail/sync-error.log"

cleanup() {
  if [ -n "${TESTROOT:-}" ] && [ -d "$TESTROOT" ]; then
    rm -rf "$TESTROOT"
  fi
}
trap cleanup EXIT

echo -e "${BLUE}━━━ mail/scripts/manage-sync.sh tests ━━━${NC}"
echo "Test workspace: $TESTROOT"
echo ""

mkdir -p "$FAKE_HOME/Library/LaunchAgents" "$FAKE_HOME/.local/share/mail"

# Mock launchctl (same shape as test-audio-backup.sh).
TESTROOT_BIN="$TESTROOT/bin"
mkdir -p "$TESTROOT_BIN"
LAUNCHCTL_STATE_DIR="$TESTROOT/launchctl-state"
mkdir -p "$LAUNCHCTL_STATE_DIR"
export LAUNCHCTL_STATE_DIR

cat > "$TESTROOT_BIN/launchctl" <<'MOCKEOF'
#!/bin/bash
STATE="$LAUNCHCTL_STATE_DIR"
[ -z "$STATE" ] && { echo "TEST MOCK ERROR: LAUNCHCTL_STATE_DIR not set" >&2; exit 1; }
case "$1" in
  load)
    plist="$2"
    [ -f "$plist" ] || exit 1
    label=$(grep -A1 '<key>Label</key>' "$plist" | tail -1 | sed 's|.*<string>\([^<]*\).*|\1|')
    touch "$STATE/$label"
    exit 0 ;;
  unload)
    plist="$2"
    if [ -f "$plist" ]; then
      label=$(grep -A1 '<key>Label</key>' "$plist" | tail -1 | sed 's|.*<string>\([^<]*\).*|\1|')
      rm -f "$STATE/$label"
    fi
    exit 0 ;;
  list)
    ls "$STATE" 2>/dev/null
    exit 0 ;;
esac
exit 0
MOCKEOF
chmod +x "$TESTROOT_BIN/launchctl"
export PATH="$TESTROOT_BIN:$PATH"
export HOME="$FAKE_HOME"

# ─── Test helpers ──────────────────────────────────────────────────────
heading() {
  echo ""
  echo -e "${BLUE}── $1 ──${NC}"
}

# ─── Tests ─────────────────────────────────────────────────────────────

heading "TEST 1: status with no service loaded"
rm -rf "$LAUNCHCTL_STATE_DIR"/*
output=$("$MANAGE" status 2>&1); status=$?
if [ "$status" -eq 0 ] && echo "$output" | grep -qi "Stopped"; then
  echo -e "  ${GREEN}✓${NC} status reports 'Stopped' when not loaded"; PASS=$((PASS+1))
else
  echo -e "  ${RED}✗${NC} status=$status, output: $output"; FAIL=$((FAIL+1))
fi

heading "TEST 2: start fails when plist file doesn't exist"
output=$("$MANAGE" start 2>&1); status=$?
if [ "$status" -ne 0 ] && echo "$output" | grep -qi "Failed to start"; then
  echo -e "  ${GREEN}✓${NC} start errors when plist missing"; PASS=$((PASS+1))
else
  echo -e "  ${RED}✗${NC} status=$status, output: $output"; FAIL=$((FAIL+1))
fi

# Generate a minimal plist for the lifecycle tests.
cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.jeromefaria.mailsync</string>
    <key>ProgramArguments</key>
    <array><string>/bin/true</string></array>
</dict>
</plist>
EOF

heading "TEST 3: start loads the service via mock launchctl"
output=$("$MANAGE" start 2>&1); status=$?
loaded=$(ls "$LAUNCHCTL_STATE_DIR" 2>/dev/null | grep -c "com.jeromefaria.mailsync" || true)
if [ "$status" -eq 0 ] && [ "$loaded" -eq 1 ] && echo "$output" | grep -qi "started successfully"; then
  echo -e "  ${GREEN}✓${NC} start loaded the service"; PASS=$((PASS+1))
else
  echo -e "  ${RED}✗${NC} status=$status, loaded=$loaded"; FAIL=$((FAIL+1))
fi

heading "TEST 4: status with service loaded reports Running"
output=$("$MANAGE" status 2>&1); status=$?
if [ "$status" -eq 0 ] && echo "$output" | grep -qi "Running"; then
  echo -e "  ${GREEN}✓${NC} status reports 'Running' when loaded"; PASS=$((PASS+1))
else
  echo -e "  ${RED}✗${NC} status=$status, output: $output"; FAIL=$((FAIL+1))
fi

heading "TEST 5: status with no sync.log reports 'No logs yet'"
rm -f "$SYNC_LOG"
output=$("$MANAGE" status 2>&1); status=$?
if [ "$status" -eq 0 ] && echo "$output" | grep -qi "No logs yet"; then
  echo -e "  ${GREEN}✓${NC} status names missing log file"; PASS=$((PASS+1))
else
  echo -e "  ${RED}✗${NC} status=$status, output: $output"; FAIL=$((FAIL+1))
fi

heading "TEST 6: restart cycles unload + load via mock launchctl"
output=$("$MANAGE" restart 2>&1); status=$?
loaded=$(ls "$LAUNCHCTL_STATE_DIR" 2>/dev/null | grep -c "com.jeromefaria.mailsync" || true)
if [ "$status" -eq 0 ] && [ "$loaded" -eq 1 ] && echo "$output" | grep -qi "restarted"; then
  echo -e "  ${GREEN}✓${NC} restart succeeded and service still loaded"; PASS=$((PASS+1))
else
  echo -e "  ${RED}✗${NC} status=$status, loaded=$loaded"; FAIL=$((FAIL+1))
fi

heading "TEST 7: stop unloads the service"
output=$("$MANAGE" stop 2>&1); status=$?
loaded_after=$(ls "$LAUNCHCTL_STATE_DIR" 2>/dev/null | grep -c "com.jeromefaria.mailsync" || true)
if [ "$status" -eq 0 ] && [ "$loaded_after" -eq 0 ] && echo "$output" | grep -qi "Service stopped"; then
  echo -e "  ${GREEN}✓${NC} stop unloaded the service"; PASS=$((PASS+1))
else
  echo -e "  ${RED}✗${NC} status=$status, loaded_after=$loaded_after"; FAIL=$((FAIL+1))
fi

heading "TEST 8: logs without sync.log reports 'No logs found'"
output=$("$MANAGE" logs 2>&1); status=$?
if [ "$status" -eq 0 ] && echo "$output" | grep -qi "No logs found"; then
  echo -e "  ${GREEN}✓${NC} logs names missing log file"; PASS=$((PASS+1))
else
  echo -e "  ${RED}✗${NC} status=$status"; FAIL=$((FAIL+1))
fi

heading "TEST 9: logs with both sync.log and error.log tails both"
{
  for i in $(seq 1 40); do echo "sync line $i"; done
} > "$SYNC_LOG"
{
  for i in $(seq 1 15); do echo "error line $i"; done
} > "$ERR_LOG"
output=$("$MANAGE" logs 2>&1); status=$?
if [ "$status" -eq 0 ] \
   && echo "$output" | grep -q "sync line 40" \
   && echo "$output" | grep -qi "Errors (if any)" \
   && echo "$output" | grep -q "error line 15"; then
  echo -e "  ${GREEN}✓${NC} logs shows both sync tail and error tail"; PASS=$((PASS+1))
else
  echo -e "  ${RED}✗${NC} status=$status"; FAIL=$((FAIL+1))
fi

heading "TEST 10: unknown subcommand exits non-zero with usage"
output=$("$MANAGE" gibberish 2>&1); status=$?
if [ "$status" -ne 0 ] && echo "$output" | grep -qi "Usage:"; then
  echo -e "  ${GREEN}✓${NC} unknown subcommand rejected with usage"; PASS=$((PASS+1))
else
  echo -e "  ${RED}✗${NC} status=$status"; FAIL=$((FAIL+1))
fi

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
