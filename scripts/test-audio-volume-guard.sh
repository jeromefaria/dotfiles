#!/bin/bash
# Integration tests for audio-volume-guard.sh.
#
# Strategy: mktemp sandbox, mock `terminal-notifier` and `osascript` as stubs
# on an isolated $PATH, and point AUDIO_VOLUME_MOUNT at a sandbox path driven
# through every state — mounted / unverified / empty squatter / populated
# squatter / absent. The mounted cases attach a throwaway disk image so the
# st_dev comparison at the heart of the guard is exercised against a real
# mount, not a simulation. Real /Volumes, real launchd, real notifications are
# never touched.
#
# Usage:
#   bash test-audio-volume-guard.sh          # quiet
#   bash test-audio-volume-guard.sh -v       # verbose

set -uo pipefail

VERBOSE=0
[ "${1:-}" = "-v" ] && VERBOSE=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUARD_SCRIPT="$SCRIPT_DIR/audio-volume-guard.sh"

if [ -t 1 ]; then
  GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
else
  GREEN=''; RED=''; YELLOW=''; BLUE=''; NC=''
fi

PASS=0
FAIL=0

# Resolved with `pwd -P`: mktemp returns a /var/... path, but /var is a symlink
# to /private/var and `mount` reports the resolved form. Comparing an
# unresolved path against `mount` output silently never matches, which would
# make a successful attach look like no mount at all.
TESTROOT="$(cd "$(mktemp -d -t audio-guard-test-XXXXXX)" && pwd -P)"
BIN_DIR="$TESTROOT/bin"
LOG_DIR="$TESTROOT/logs"
STATE_DIR="$TESTROOT/state"
MOUNT_ROOT="$TESTROOT/Volumes"
MOUNT_POINT="$MOUNT_ROOT/Audio"
NOTIFY_CAPTURE="$TESTROOT/notify.log"
NOTIFIER_MODE_FILE="$TESTROOT/notifier.mode"
DISK_IMAGE="$TESTROOT/mounted.dmg"
ATTACHED_DEVICE=""

is_mounted() { mount | grep -q " on ${MOUNT_POINT} "; }

# Never rm -rf a tree that still has a disk image mounted inside it: the
# recursion would walk into the live mount. A detach that will not succeed
# leaves the sandbox on disk to be cleaned up by hand instead.
cleanup() {
  if [ -n "$ATTACHED_DEVICE" ]; then
    if ! hdiutil detach "$ATTACHED_DEVICE" -force >/dev/null 2>&1; then
      echo "WARNING: could not detach $ATTACHED_DEVICE — leaving $TESTROOT in place" >&2
      return
    fi
    ATTACHED_DEVICE=""
  fi

  if is_mounted; then
    echo "WARNING: $MOUNT_POINT still mounted — leaving $TESTROOT in place" >&2
    return
  fi

  if [ -n "${TESTROOT:-}" ] && [ -d "$TESTROOT" ]; then
    rm -rf "$TESTROOT"
  fi
}
trap cleanup EXIT

mkdir -p "$BIN_DIR" "$LOG_DIR" "$STATE_DIR" "$MOUNT_ROOT"
echo "ok" > "$NOTIFIER_MODE_FILE"

# ─── Mock: terminal-notifier ───────────────────────────────────────────
# Captures what would have been posted so assertions can read it back. In
# "fail" mode it exits non-zero, standing in for the real failure modes of a
# launchd agent: no GUI session, or notification permission denied.
cat > "$BIN_DIR/terminal-notifier" <<MOCK
#!/bin/bash
[ "\$(cat "$NOTIFIER_MODE_FILE" 2>/dev/null)" = "fail" ] && exit 1
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

# ─── Mock: osascript ───────────────────────────────────────────────────
# The guard's fallback path. Mocked so "fail" mode can make *both* delivery
# routes fail, which is the only way to exercise a genuine delivery failure.
cat > "$BIN_DIR/osascript" <<MOCK
#!/bin/bash
[ "\$(cat "$NOTIFIER_MODE_FILE" 2>/dev/null)" = "fail" ] && exit 1
printf 'title=osascript-fallback\nmessage=%s\ngroup=\n---\n' "\$*" >> "$NOTIFY_CAPTURE"
exit 0
MOCK

chmod +x "$BIN_DIR/terminal-notifier" "$BIN_DIR/osascript"

export PATH="$BIN_DIR:$PATH"
export AUDIO_VOLUME_MOUNT="$MOUNT_POINT"
export AUDIO_VOLUME_SENTINEL="$MOUNT_POINT/.audio-volume-guard"
export AUDIO_VOLUME_LOG_DIR="$LOG_DIR"
export AUDIO_VOLUME_STATE_DIR="$STATE_DIR"
export AUDIO_VOLUME_NOTIFY_ENABLED=1
export AUDIO_VOLUME_NOTIFIER_GROUP="audio-volume-guard-test"
export AUDIO_VOLUME_NOTIFY_COOLDOWN_HOURS=1

NOTIFY_MARKER="$STATE_DIR/.last-squatter-notify"

echo -e "${BLUE}━━━ audio-volume-guard tests ━━━${NC}"
echo "Test workspace: $TESTROOT"
echo ""

pass() { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS + 1)); }
fail() {
  echo -e "  ${RED}✗${NC} $1"
  [ -n "${2:-}" ] && echo -e "    ${YELLOW}$2${NC}"
  FAIL=$((FAIL + 1))
}
skip() { echo -e "  ${YELLOW}⊘${NC} $1"; }
heading() { echo; echo -e "${BLUE}── $1 ──${NC}"; }

run_guard() {
  if [ "$VERBOSE" -eq 1 ]; then
    "$GUARD_SCRIPT" "$@"
  else
    "$GUARD_SCRIPT" "$@" > /dev/null 2>&1
  fi
}

# Always captures, regardless of -v, for assertions about rendered output.
capture_guard() { "$GUARD_SCRIPT" "$@" 2>&1; }

set_notifier_mode() { echo "$1" > "$NOTIFIER_MODE_FILE"; }

reset_notifications() {
  : > "$NOTIFY_CAPTURE" 2>/dev/null || true
  rm -f "$NOTIFY_MARKER" "$LOG_DIR/guard.log"
  set_notifier_mode "ok"
}

reset_state() {
  reset_notifications
  if is_mounted; then
    echo "REFUSING to clear $MOUNT_POINT — still mounted" >&2
    return 1
  fi
  rm -rf "$MOUNT_POINT"
}

make_empty_squatter()     { mkdir -p "$MOUNT_POINT"; }
make_populated_squatter() {
  mkdir -p "$MOUNT_POINT/Audio/Libraries/Arturia"
  dd if=/dev/zero of="$MOUNT_POINT/Audio/Libraries/Arturia/payload.bin" bs=1024 count=64 2>/dev/null
}

notify_count() { grep -c "^title=" "$NOTIFY_CAPTURE" 2>/dev/null || true; }

# ─── TEST 1: absent volume → --check fails ────────────────────────────
heading "TEST 1: absent volume, --check refuses"
reset_state
if run_guard --check; then
  fail "--check passed with the volume absent"
else
  pass "absent volume → --check exits non-zero"
fi

# ─── TEST 2: absent volume → watcher stays silent ─────────────────────
# An unplugged drive is an ordinary daily state. Notifying on it would train
# the user to dismiss the alert that actually matters.
heading "TEST 2: absent volume, watcher does not notify"
reset_state
run_guard
[ ! -s "$NOTIFY_CAPTURE" ] \
  && pass "no notification for an ordinary unplugged drive" \
  || fail "watcher cried wolf on absent volume" "$(cat "$NOTIFY_CAPTURE")"

# ─── TEST 3: empty squatter → --check fails ───────────────────────────
heading "TEST 3: empty squatter, --check refuses"
reset_state
make_empty_squatter
if run_guard --check; then
  fail "--check passed with a squatter directory present"
else
  pass "empty squatter → --check exits non-zero"
fi

# ─── TEST 4: empty squatter → --repair removes it ─────────────────────
heading "TEST 4: empty squatter, --repair removes it"
reset_state
make_empty_squatter
if run_guard --repair; then
  [ ! -e "$MOUNT_POINT" ] \
    && pass "empty squatter removed, mount point freed" \
    || fail "--repair reported success but the directory survived"
else
  fail "--repair failed on an empty squatter"
fi

# ─── TEST 5: populated squatter → --repair refuses, payload survives ──
# The payload exists only here; deleting it would destroy an installer's work.
heading "TEST 5: populated squatter, --repair refuses to delete"
reset_state
make_populated_squatter
if run_guard --repair; then
  fail "--repair deleted or accepted a populated squatter"
else
  [ -f "$MOUNT_POINT/Audio/Libraries/Arturia/payload.bin" ] \
    && pass "--repair refused and the payload survived" \
    || fail "payload was destroyed by --repair"
fi

# ─── TEST 6: populated squatter → watcher notifies ────────────────────
heading "TEST 6: populated squatter, watcher notifies"
reset_state
make_populated_squatter
run_guard
grep -q "^title=Audio volume mount blocked$" "$NOTIFY_CAPTURE" \
  && pass "notification title matches" \
  || fail "notification title missing" "$(cat "$NOTIFY_CAPTURE")"
grep -q "on the boot disk instead of the Audio volume" "$NOTIFY_CAPTURE" \
  && pass "notification body names the boot-disk write" \
  || fail "notification body missing boot-disk phrasing" "$(cat "$NOTIFY_CAPTURE")"

# ─── TEST 7: cooldown suppresses a second notification ────────────────
heading "TEST 7: cooldown suppresses re-notify within window"
reset_state
make_populated_squatter
run_guard
first_count="$(notify_count)"
run_guard
second_count="$(notify_count)"
[ "$first_count" = "1" ] && [ "$second_count" = "1" ] \
  && pass "second run within cooldown produced no new notification" \
  || fail "cooldown gate leaked: first=$first_count second=$second_count"
[ -f "$NOTIFY_MARKER" ] \
  && pass "cooldown marker lands in STATE_DIR (cleaners can't wipe it)" \
  || fail "cooldown marker not written to STATE_DIR"

# ─── TEST 8: cooldown expired → notifies again ────────────────────────
heading "TEST 8: cooldown expired, second run notifies again"
reset_state
make_populated_squatter
run_guard
echo $(( $(date +%s) - 100 * 3600 )) > "$NOTIFY_MARKER"
run_guard
count="$(notify_count)"
[ "$count" = "2" ] \
  && pass "cooldown-expired run produced a second notification" \
  || fail "expected 2 notifications, got $count"

# ─── TEST 9: NOTIFY_ENABLED=0 silences, and does NOT arm the cooldown ─
# A marker written while notifications are off would swallow the next window
# of real alerts the moment they are re-enabled.
heading "TEST 9: NOTIFY_ENABLED=0 silences without arming the cooldown"
reset_state
make_populated_squatter
AUDIO_VOLUME_NOTIFY_ENABLED=0 run_guard
[ ! -s "$NOTIFY_CAPTURE" ] \
  && pass "no notification when AUDIO_VOLUME_NOTIFY_ENABLED=0" \
  || fail "notification leaked despite NOTIFY_ENABLED=0"
[ ! -f "$NOTIFY_MARKER" ] \
  && pass "cooldown not armed by a silenced run" \
  || fail "silenced run stamped the cooldown marker"
run_guard
[ "$(notify_count)" = "1" ] \
  && pass "re-enabled run notifies immediately (not suppressed)" \
  || fail "re-enabled run was suppressed by a phantom cooldown"

# ─── TEST 10: failed delivery must not arm the cooldown ───────────────
# A launchd agent with no GUI session fails every delivery. Arming the cooldown
# there means the log claims the user was warned when nothing was posted.
heading "TEST 10: failed delivery does not arm the cooldown"
reset_state
make_populated_squatter
set_notifier_mode "fail"
run_guard
[ ! -f "$NOTIFY_MARKER" ] \
  && pass "cooldown not armed when both delivery routes fail" \
  || fail "failed delivery stamped the cooldown marker"
grep -q "delivery FAILED" "$LOG_DIR/guard.log" \
  && pass "log records the delivery failure rather than claiming success" \
  || fail "log does not record the failure" "$(cat "$LOG_DIR/guard.log")"
set_notifier_mode "ok"
run_guard
[ "$(notify_count)" = "1" ] \
  && pass "next run delivers once notification works again" \
  || fail "recovery run was suppressed by a phantom cooldown"

# ─── TEST 11: an unreadable squatter counts as non-empty ──────────────
# The squatter is created by a root installer, so it can easily be unreadable
# to this user. `find` then exits non-zero having printed nothing; reading that
# as "empty" would have the watcher announce an empty directory while
# gigabytes sit inside it.
heading "TEST 11: unreadable squatter is treated as non-empty"
reset_state
make_populated_squatter
chmod 000 "$MOUNT_POINT"
run_guard
repair_output="$(capture_guard --repair)"
repair_status=$?
chmod 755 "$MOUNT_POINT"

grep -q "An empty directory is blocking" "$NOTIFY_CAPTURE" \
  && fail "watcher called an unreadable squatter empty" "$(cat "$NOTIFY_CAPTURE")" \
  || pass "watcher did not claim the unreadable squatter was empty"
# The original defect: failing closed made the probe report "occupied", and the
# message then asserted a write the guard had never observed. An unreadable
# directory must report uncertainty, not a quantity.
grep -q "was written to" "$NOTIFY_CAPTURE" \
  && fail "watcher asserted a write it could not observe" "$(cat "$NOTIFY_CAPTURE")" \
  || pass "watcher did not assert an unobserved write"
grep -q "could not be read" "$NOTIFY_CAPTURE" \
  && pass "watcher reports the contents as unreadable" \
  || fail "watcher did not report unreadability" "$(cat "$NOTIFY_CAPTURE")"
[ "$repair_status" -ne 0 ] \
  && pass "--repair refused the unreadable squatter" \
  || fail "--repair accepted an unreadable squatter"
printf '%s' "$repair_output" | grep -q "Refusing to delete" \
  && pass "--repair explains why it refused" \
  || fail "--repair did not explain the refusal" "$repair_output"
printf '%s' "$repair_output" | grep -q "holds  of data" \
  && fail "unknown size rendered as an empty string" "$repair_output" \
  || pass "unknown size renders as readable text, not a gap"
printf '%s' "$repair_output" | grep -q "contents are unknown" \
  && pass "--repair names unreadability as the reason, not a phantom size" \
  || fail "--repair did not explain unreadability" "$repair_output"

# ─── TEST 12: --status is honest while a squatter is present ──────────
# `-e` resolves *through* a squatter, so a naive link check reports every
# dependent symlink healthy in exactly the state the tool exists to detect.
heading "TEST 12: --status does not report symlinks healthy during a squatter"
reset_state
make_populated_squatter
status_output="$(capture_guard --status)"
printf '%s' "$status_output" | grep -q "Squatter directory at" \
  && pass "status reports the squatter" \
  || fail "status did not report the squatter" "$status_output"
printf '%s' "$status_output" | grep -q "resolving onto the boot disk" \
  && pass "dependent symlinks reported as resolving onto the boot disk" \
  || fail "symlinks not flagged during squatter state" "$status_output"
printf '%s' "$status_output" | grep -qE '✓ +/Library/' \
  && fail "a dependent symlink was marked healthy during a squatter" "$status_output" \
  || pass "no dependent symlink marked healthy during a squatter"

# ─── TEST 13: unknown option prints usage without a stray rule ────────
heading "TEST 13: usage dump has no trailing separator rule"
usage_output="$(capture_guard --bogus || true)"
printf '%s' "$usage_output" | grep -q "audio-volume-guard.sh --check" \
  && pass "usage block is printed" \
  || fail "usage block missing" "$usage_output"
printf '%s' "$usage_output" | grep -qE '^=+$' \
  && fail "usage dump trails a bare separator rule" "$usage_output" \
  || pass "no stray separator rule in the usage dump"

# ─── TEST 14: real mount — unverified without sentinel, healthy with ──
# A matching st_dev only proves *something* is mounted. Only a genuine mount
# exercises that comparison, so attach a throwaway disk image rather than
# simulate one. The device handle is taken from `attach`'s own output so it is
# never lost to a failing downstream pipeline.
heading "TEST 14: real mount, unverified until the sentinel is written"
reset_state
mkdir -p "$MOUNT_POINT"
if hdiutil create -size 8m -fs HFS+ -volname AudioGuardTest -quiet "$DISK_IMAGE" 2>/dev/null; then
  attach_output="$(hdiutil attach "$DISK_IMAGE" -mountpoint "$MOUNT_POINT" -nobrowse 2>/dev/null)"
  ATTACHED_DEVICE="$(printf '%s\n' "$attach_output" | awk '$NF ~ /^\// && $1 ~ /^\/dev\// {print $1; exit}')"
  [ -n "$ATTACHED_DEVICE" ] \
    || ATTACHED_DEVICE="$(printf '%s\n' "$attach_output" | awk '$1 ~ /^\/dev\// {print $1; exit}')"
fi

if [ -n "$ATTACHED_DEVICE" ] && is_mounted; then
  reset_notifications

  if run_guard --check; then
    fail "--check accepted a mounted volume with no sentinel"
  else
    pass "unverified mount → --check fails closed"
  fi

  run_guard
  grep -q "unidentified volume is mounted" "$NOTIFY_CAPTURE" \
    && pass "watcher notifies about the unidentified volume" \
    || fail "no notification for an unidentified mount" "$(cat "$NOTIFY_CAPTURE")"

  reset_notifications
  if run_guard --init; then
    pass "--init writes the sentinel"
  else
    fail "--init failed on a mounted volume"
  fi

  if run_guard --check; then
    pass "sentinel present → --check exits 0"
  else
    fail "--check rejected the volume after --init"
  fi

  run_guard
  [ ! -s "$NOTIFY_CAPTURE" ] \
    && pass "healthy mount produces no notification" \
    || fail "watcher notified on a healthy mount" "$(cat "$NOTIFY_CAPTURE")"

  run_guard --repair \
    && pass "--repair is a no-op on a mounted volume" \
    || fail "--repair errored on a mounted volume"

  status_output="$(capture_guard --status)"
  printf '%s' "$status_output" | grep -q "volume mounted at" \
    && pass "status reports the mount as healthy" \
    || fail "status did not report a healthy mount" "$status_output"

  if hdiutil detach "$ATTACHED_DEVICE" -force >/dev/null 2>&1; then
    ATTACHED_DEVICE=""
  else
    fail "could not detach the test disk image"
  fi
else
  # ATTACHED_DEVICE is deliberately left as-is: if the attach partly succeeded,
  # cleanup still has to detach it. Clearing it here is what leaks a live mount.
  skip "disk image could not be attached — mounted-state assertions skipped"
fi

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
