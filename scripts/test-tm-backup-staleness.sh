#!/bin/bash
# Integration tests for tm-backup-staleness-check.sh.
#
# Strategy: mktemp sandbox, mock `tmutil` and `terminal-notifier` as stubs on
# an isolated $PATH, override the config path to point at a fixture, and
# drive the check through fresh / stale / destination-unreachable / cooldown
# paths. Real ~/.ssh, real launchd, real tmutil are never touched.
#
# `defaults` and `plutil` are NOT stubbed — they are deterministic readers, and
# TM_PREFS_PATH aims them at a sandbox plist, so the preferences source is
# driven by fixture content rather than by a mock. That matters because the
# check falls back to preferences whenever tmutil is unavailable: without the
# override, the unreachable-destination tests would silently read the host's
# real Time Machine state and pass or fail according to whoever ran them.
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
PREFS_FILE="$TESTROOT/TimeMachine.plist"

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
#   nofda           - reproduce the real no-Full-Disk-Access refusal
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
    nofda)
      # Verbatim shape of what a launchd agent actually gets, down to exit 80.
      echo "tmutil: latestbackup requires Full Disk Access privileges." >&2
      exit 80
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
TM_PREFS_PATH="$PREFS_FILE"
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

# Writes a preferences fixture whose newest *completed* backup sits at $1.
# AttemptDates is seeded deliberately newer than SnapshotDates, so any test
# that reads the wrong array reports a fresh backup and fails loudly.
# `set_prefs none` removes the file: `defaults export` on a missing path yields
# an empty dict, the Destinations extract then fails, and the check sees no
# preferences source at all.
set_prefs() {
  if [ "$1" = "none" ]; then
    rm -f "$PREFS_FILE"
    return
  fi

  local snapshot_iso attempt_iso
  snapshot_iso="$(date -u -r "$1" '+%Y-%m-%dT%H:%M:%SZ')"
  attempt_iso="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

  cat > "$PREFS_FILE" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Destinations</key>
  <array>
    <dict>
      <key>AttemptDates</key>
      <array><date>${attempt_iso}</date></array>
      <key>SnapshotDates</key>
      <array>
        <date>2026-01-01T00:00:00Z</date>
        <date>${snapshot_iso}</date>
      </array>
    </dict>
  </array>
</dict>
</plist>
PLIST
}

# Two destinations, newest completed backup at $1 and $2 respectively. Used to
# prove the check reports the most recent success across docks rather than
# whichever destination preferences happen to list first.
set_prefs_multi() {
  local first_iso second_iso
  first_iso="$(date -u -r "$1" '+%Y-%m-%dT%H:%M:%SZ')"
  second_iso="$(date -u -r "$2" '+%Y-%m-%dT%H:%M:%SZ')"

  cat > "$PREFS_FILE" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Destinations</key>
  <array>
    <dict>
      <key>SnapshotDates</key>
      <array><date>${first_iso}</date></array>
    </dict>
    <dict>
      <key>SnapshotDates</key>
      <array><date>${second_iso}</date></array>
    </dict>
  </array>
</dict>
</plist>
PLIST
}

reset_state() {
  : > "$NOTIFY_CAPTURE" 2>/dev/null || true
  rm -f "$STATE_DIR/.last-stale-notify" "$LOG_DIR/.last-stale-notify" "$LOG_DIR/staleness-check.log"
  # Default to no preferences source, so every test that relies on one says so.
  set_prefs none
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

# ─── TEST 3: destination unreachable (both sources dry) → notification ──
heading "TEST 3: destination unreachable, notify fires"
reset_state
set_mode "error"
set_prefs none            # neither tmutil nor preferences can answer
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

# ─── TEST 9: no Full Disk Access → preferences answer, no false alarm ──
# The regression. `tmutil latestbackup` needs Full Disk Access, which a launchd
# agent does not have, so every scheduled run used to take the
# destination-unreachable branch and alert on a healthy backup — while also
# never obtaining a date, leaving real staleness undetectable.
heading "TEST 9: tmutil lacks Full Disk Access, preferences carry the date"
reset_state
set_mode "nofda"
set_prefs "$(( $(date +%s) - 3600 ))"   # 1h ago, well under 48h
run_check
[ ! -s "$NOTIFY_CAPTURE" ] \
  && pass "no false alarm when tmutil is refused but the backup is fresh" \
  || fail "false alarm on a healthy backup" "$(cat "$NOTIFY_CAPTURE")"
grep -q "Source: Time Machine preferences" "$LOG_DIR/staleness-check.log" \
  && pass "log records that the fallback source answered" \
  || fail "fallback source not recorded" "$(cat "$LOG_DIR/staleness-check.log" 2>/dev/null)"

# ─── TEST 10: no FDA + genuinely stale → the alert still fires ─────────
# The other half of the regression: the fallback must be able to detect real
# staleness, not merely avoid false alarms. The fixture's AttemptDates is newer
# than its SnapshotDates, so reading the wrong array would report "fresh" here.
heading "TEST 10: tmutil lacks Full Disk Access, stale backup still detected"
reset_state
set_mode "nofda"
set_prefs "$(( $(date +%s) - 200 * 3600 ))"   # 200h ago, well past 48h
run_check
grep -q "^title=Time Machine backup stale$" "$NOTIFY_CAPTURE" \
  && pass "staleness detected through the preferences fallback" \
  || fail "stale backup went undetected via fallback" "$(cat "$NOTIFY_CAPTURE")"
grep -q "No successful backup in " "$NOTIFY_CAPTURE" \
  && pass "completed backups drive the verdict, not the newer AttemptDates" \
  || fail "wrong date array read — reported fresh when SnapshotDates was stale"

# ─── TEST 11: tmutil wins when both sources are available ─────────────
heading "TEST 11: tmutil preferred over preferences when permitted"
reset_state
set_mode "fresh:$(( $(date +%s) - 3600 ))"       # authoritative source: fresh
set_prefs "$(( $(date +%s) - 200 * 3600 ))"      # fallback would say stale
run_check
[ ! -s "$NOTIFY_CAPTURE" ] \
  && pass "authoritative source takes precedence over the fallback" \
  || fail "fallback overrode tmutil" "$(cat "$NOTIFY_CAPTURE")"

# ─── TEST 12: newest completed backup across destinations wins ────────
heading "TEST 12: newest success across destinations, not the first listed"
reset_state
set_mode "nofda"
set_prefs_multi "$(( $(date +%s) - 200 * 3600 ))" "$(( $(date +%s) - 3600 ))"
run_check
[ ! -s "$NOTIFY_CAPTURE" ] \
  && pass "a fresh second destination is not masked by a stale first one" \
  || fail "only the first destination was considered" "$(cat "$NOTIFY_CAPTURE")"

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
