#!/bin/bash
# Integration tests for tm-backup-staleness-check.sh.
#
# Strategy: mktemp sandbox, mock `tmutil` and `terminal-notifier` as stubs on
# an isolated $PATH, override the config path to point at a fixture, and
# drive the check through fresh / stale / destination-unreachable / cooldown
# paths. Real ~/.ssh, real launchd, real tmutil are never touched.
#
# Usage:
#   bash test-tm-backup-staleness.sh          # quiet
#   bash test-tm-backup-staleness.sh -v       # verbose

set -uo pipefail

VERBOSE=0
[ "${1:-}" = "-v" ] && VERBOSE=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHECK_SCRIPT="$SCRIPT_DIR/tm-backup-staleness-check.sh"

if [ -t 1 ]; then
  GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
else
  GREEN=''; RED=''; YELLOW=''; BLUE=''; NC=''
fi

PASS=0
FAIL=0

TESTROOT="$(mktemp -d -t tm-staleness-test-XXXXXX)"
BIN_DIR="$TESTROOT/bin"
LOG_DIR="$TESTROOT/logs"
STATE_DIR="$TESTROOT/state"
CONFIG_FILE="$TESTROOT/tm-backup.conf"
NOTIFY_CAPTURE="$TESTROOT/notify.log"
TMUTIL_MODE_FILE="$TESTROOT/tmutil.mode"

cleanup() {
  if [ -n "${TESTROOT:-}" ] && [ -d "$TESTROOT" ]; then
    rm -rf "$TESTROOT"
  fi
}
trap cleanup EXIT

mkdir -p "$BIN_DIR" "$LOG_DIR" "$STATE_DIR"

# ─── Mock: tmutil ──────────────────────────────────────────────────────
# Behaviour is driven by the mode file so tests can flip between fresh,
# stale, and destination-unreachable without redefining the mock.
cat > "$BIN_DIR/tmutil" <<'MOCK'
#!/bin/bash
# Reads mode from TMUTIL_MODE_FILE. Modes:
#   fresh:<epoch>   - print a backup path with the given epoch as the date
#   error           - exit non-zero (destination unmountable)
mode_file="${TMUTIL_MODE_FILE:-/tmp/tmutil.mode}"
mode="$(cat "$mode_file" 2>/dev/null || echo error)"

if [ "$1" = "latestbackup" ]; then
  case "$mode" in
    fresh:*)
      epoch="${mode#fresh:}"
      # Format epoch into YYYY-MM-DD-HHMMSS (BSD date syntax).
      stamp="$(date -r "$epoch" '+%Y-%m-%d-%H%M%S')"
      echo "/Volumes/.timemachine/00000000-0000-0000-0000-000000000000/${stamp}.backup/${stamp}.backup"
      exit 0
      ;;
    error|*)
      echo "Failed to mount backup destination" >&2
      exit 1
      ;;
  esac
fi
exit 0
MOCK

# ─── Mock: terminal-notifier ───────────────────────────────────────────
# Captures the notification title + message so tests can assert on them.
cat > "$BIN_DIR/terminal-notifier" <<MOCK
#!/bin/bash
title=""
message=""
group=""
while [ \$# -gt 0 ]; do
  case "\$1" in
    -title)   title="\$2"; shift 2 ;;
    -message) message="\$2"; shift 2 ;;
    -group)   group="\$2"; shift 2 ;;
    *)        shift ;;
  esac
done
printf 'title=%s\nmessage=%s\ngroup=%s\n---\n' "\$title" "\$message" "\$group" >> "$NOTIFY_CAPTURE"
exit 0
MOCK

chmod +x "$BIN_DIR/tmutil" "$BIN_DIR/terminal-notifier"

# ─── Fixture config ────────────────────────────────────────────────────
cat > "$CONFIG_FILE" <<EOF
TM_STALE_ALERT_HOURS=48
TM_STALE_NOTIFY_COOLDOWN_HOURS=12
TM_NOTIFY_ENABLED=1
TM_NOTIFIER_GROUP="tm-backup-test"
TM_STALENESS_LOG_DIR="$LOG_DIR"
TM_STALENESS_STATE_DIR="$STATE_DIR"
EOF

export TM_BACKUP_CONFIG="$CONFIG_FILE"
export TMUTIL_MODE_FILE
export PATH="$BIN_DIR:$PATH"

echo -e "${BLUE}━━━ tm-backup-staleness-check tests ━━━${NC}"
echo "Test workspace: $TESTROOT"
echo ""

pass() { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS + 1)); }
fail() {
  echo -e "  ${RED}✗${NC} $1"
  [ -n "${2:-}" ] && echo -e "    ${YELLOW}$2${NC}"
  FAIL=$((FAIL + 1))
}
heading() { echo; echo -e "${BLUE}── $1 ──${NC}"; }

set_mode()  { echo "$1" > "$TMUTIL_MODE_FILE"; }
reset_state() {
  : > "$NOTIFY_CAPTURE" 2>/dev/null || true
  rm -f "$STATE_DIR/.last-stale-notify" "$LOG_DIR/.last-stale-notify" "$LOG_DIR/staleness-check.log"
}

run_check() {
  if [ "$VERBOSE" -eq 1 ]; then
    "$CHECK_SCRIPT" "$@"
  else
    "$CHECK_SCRIPT" "$@" > /dev/null 2>&1
  fi
}

# ─── TEST 1: fresh backup within threshold → no notification ──────────
heading "TEST 1: fresh backup within threshold, no notify"
reset_state
set_mode "fresh:$(( $(date +%s) - 3600 ))"   # 1h ago, well under 48h
run_check
[ ! -s "$NOTIFY_CAPTURE" ] \
  && pass "no notification fired" \
  || fail "unexpected notification: $(cat "$NOTIFY_CAPTURE")"

# ─── TEST 2: stale backup beyond threshold → notification fires ──────
heading "TEST 2: stale backup beyond threshold, notify fires"
reset_state
set_mode "fresh:$(( $(date +%s) - 200 * 3600 ))"   # 200h ago, well past 48h
run_check
grep -q "^title=Time Machine backup stale$" "$NOTIFY_CAPTURE" \
  && pass "notification title matches" \
  || fail "notification title missing" "$(cat "$NOTIFY_CAPTURE")"
grep -q "No successful backup in " "$NOTIFY_CAPTURE" \
  && pass "notification body names the gap" \
  || fail "notification body missing gap phrasing"

# ─── TEST 3: destination unreachable (tmutil errors) → notification ──
heading "TEST 3: destination unreachable, notify fires"
reset_state
set_mode "error"
run_check
grep -q "Backup destination is not reachable" "$NOTIFY_CAPTURE" \
  && pass "unreachable-destination notification fired" \
  || fail "unreachable notification missing" "$(cat "$NOTIFY_CAPTURE")"

# ─── TEST 4: cooldown suppresses second notification ──────────────────
heading "TEST 4: cooldown suppresses re-notify within window"
reset_state
set_mode "fresh:$(( $(date +%s) - 200 * 3600 ))"
run_check                                     # first — fires
first_count=$(grep -c "^title=" "$NOTIFY_CAPTURE" 2>/dev/null || echo 0)
run_check                                     # second — should be suppressed
second_count=$(grep -c "^title=" "$NOTIFY_CAPTURE" 2>/dev/null || echo 0)
[ "$first_count" = "1" ] && [ "$second_count" = "1" ] \
  && pass "second run within cooldown produced no new notification (count stayed at 1)" \
  || fail "cooldown gate leaked: first=$first_count second=$second_count"

# ─── TEST 5: cooldown-expired second notification does fire ───────────
heading "TEST 5: cooldown-expired, second run notifies again"
reset_state
set_mode "fresh:$(( $(date +%s) - 200 * 3600 ))"
run_check                                     # first
[ -f "$STATE_DIR/.last-stale-notify" ] \
  && pass "cooldown marker lands in STATE_DIR (not LOG_DIR, so cleaners can't wipe it)" \
  || fail "cooldown marker not written to STATE_DIR" "$(ls -la "$STATE_DIR" "$LOG_DIR")"
# Rewind the notify-marker so cooldown looks expired.
echo $(( $(date +%s) - 100 * 3600 )) > "$STATE_DIR/.last-stale-notify"
run_check                                     # second
count=$(grep -c "^title=" "$NOTIFY_CAPTURE" 2>/dev/null || echo 0)
[ "$count" = "2" ] \
  && pass "cooldown-expired run produced a second notification" \
  || fail "expected 2 notifications, got $count"

# ─── TEST 6: --check mode never notifies, exits by freshness ─────────
heading "TEST 6: --check mode: no notify, exit code reflects state"
reset_state
set_mode "fresh:$(( $(date +%s) - 3600 ))"
if run_check --check; then
  pass "fresh state → --check exits 0"
else
  fail "fresh state → --check should have exited 0"
fi
reset_state
set_mode "fresh:$(( $(date +%s) - 200 * 3600 ))"
if run_check --check; then
  fail "stale state → --check should have exited non-zero"
else
  pass "stale state → --check exits non-zero"
fi
[ ! -s "$NOTIFY_CAPTURE" ] \
  && pass "--check never triggers a notification" \
  || fail "--check leaked a notification"

# ─── TEST 7: one-time migration moves the marker from LOG_DIR → STATE_DIR
heading "TEST 7: pre-relocation marker in LOG_DIR migrates to STATE_DIR"
reset_state
set_mode "fresh:$(( $(date +%s) - 200 * 3600 ))"
# Seed the old-location marker with a fresh timestamp — if migration works,
# it becomes STATE_DIR's marker and cooldown suppresses the notify.
now_ts=$(date +%s)
echo "$now_ts" > "$LOG_DIR/.last-stale-notify"
run_check
[ ! -f "$LOG_DIR/.last-stale-notify" ] \
  && pass "old-location marker removed from LOG_DIR" \
  || fail "old marker still in LOG_DIR — migration didn't fire"
if [ -f "$STATE_DIR/.last-stale-notify" ] && [ "$(cat "$STATE_DIR/.last-stale-notify")" = "$now_ts" ]; then
  pass "marker relocated to STATE_DIR with original timestamp preserved"
else
  fail "marker missing from STATE_DIR or timestamp lost"
fi
# Use `wc -l` on filtered lines instead of `grep -c || echo 0` — grep prints
# `0` AND exits non-zero when there are no matches, doubling the fallback.
count=$(grep -c "^title=" "$NOTIFY_CAPTURE" 2>/dev/null; true)
count=${count:-0}
if [ "$count" = "0" ]; then
  pass "cooldown honoured post-migration (no fresh notify fired)"
else
  fail "migration lost the cooldown timestamp — expected 0 notifications, got $count"
fi

# ─── TEST 8: NOTIFY_ENABLED=0 silences everything ─────────────────────
heading "TEST 8: TM_NOTIFY_ENABLED=0 silences notifications"
reset_state
# Rewrite fixture to disable notifications.
sed -i.bak 's/^TM_NOTIFY_ENABLED=.*/TM_NOTIFY_ENABLED=0/' "$CONFIG_FILE"
set_mode "fresh:$(( $(date +%s) - 200 * 3600 ))"
run_check
[ ! -s "$NOTIFY_CAPTURE" ] \
  && pass "no notification when TM_NOTIFY_ENABLED=0" \
  || fail "notification leaked despite NOTIFY_ENABLED=0"
mv "$CONFIG_FILE.bak" "$CONFIG_FILE"          # restore fixture

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
