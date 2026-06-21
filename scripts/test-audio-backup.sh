#!/bin/bash
# Integration tests for audio-backup pull / push.
#
# Sets up a self-contained test environment in /tmp with:
#   - fake Audio drive (with sentinel)
#   - fake Drive remote (via rclone's `local:` backend)
#   - test audio-backup.conf pointing at both
#
# No real Drive calls. No external dependencies beyond rclone + rsync (both
# required by the script anyway).
#
# Usage:
#   bash test-audio-backup.sh           # run all tests
#   bash test-audio-backup.sh -v        # verbose (show subcommand output)

set -uo pipefail

VERBOSE=0
[ "${1:-}" = "-v" ] && VERBOSE=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANAGE="$SCRIPT_DIR/audio-backup-manage.sh"

# ─── Colors ────────────────────────────────────────────────────────────
if [ -t 1 ]; then
  GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
else
  GREEN=''; RED=''; YELLOW=''; BLUE=''; NC=''
fi

PASS=0
FAIL=0

# ─── Setup ─────────────────────────────────────────────────────────────
TESTROOT="$(mktemp -d -t audio-backup-test-XXXXXX)"
FAKE_AUDIO="$TESTROOT/audio"
FAKE_DRIVE="$TESTROOT/drive"
FAKE_LOCAL="$TESTROOT/local"
TEST_LOGDIR="$TESTROOT/logs"
TEST_RCLONE_CONFIG="$TESTROOT/rclone.conf"
TEST_BACKUP_CONFIG="$TESTROOT/audio-backup.conf"

cleanup() {
  if [ -n "${TESTROOT:-}" ] && [ -d "$TESTROOT" ]; then
    rm -rf "$TESTROOT"
  fi
}
trap cleanup EXIT

echo -e "${BLUE}━━━ Audio Backup integration tests ━━━${NC}"
echo "Test workspace: $TESTROOT"
echo ""

# Fake Audio drive: must have sentinel for push to work
mkdir -p "$FAKE_AUDIO/Documents" "$FAKE_DRIVE/Backup/Audio" "$FAKE_LOCAL" "$TEST_LOGDIR"
touch "$FAKE_AUDIO/SYSTEM.md"

# Pre-populate fake Drive with starter content
mkdir -p "$FAKE_DRIVE/Backup/Audio/Projects/TestProject"
echo "original session data" > "$FAKE_DRIVE/Backup/Audio/Projects/TestProject/session.als"
mkdir -p "$FAKE_DRIVE/Backup/Audio/Documents"
echo "# INDEX" > "$FAKE_DRIVE/Backup/Audio/Documents/INDEX.md"

# Rclone test config — local backend pointing at the fake Drive
cat > "$TEST_RCLONE_CONFIG" <<EOF
[testdrive]
type = local
EOF
export RCLONE_CONFIG="$TEST_RCLONE_CONFIG"

# Audio-backup test config — overrides paths to point at the fake dirs
cat > "$TEST_BACKUP_CONFIG" <<EOF
SOURCE="$FAKE_AUDIO"
SENTINEL="\${SOURCE}/SYSTEM.md"
RCLONE_REMOTE="testdrive"
RCLONE_DEST_PATH="$FAKE_DRIVE/Backup/Audio"
RCLONE_VERSIONS_PATH="$FAKE_DRIVE/Backup/Audio-versions"
TRUSTED_ROUTER_ALLOWLIST=("0.0.0.0")
HOTSPOT_GATEWAY_PATTERN="172.20.10."
BWLIMIT_DEFAULT="100M"
BWLIMIT_FORCE="20M"
SCHEDULE_HOUR=3
SCHEDULE_MINUTE=0
DOTFILES_SCRIPTS_DIR="$SCRIPT_DIR"
FILTERS_FILE="$SCRIPT_DIR/audio-backup-filters.txt"
LOG_DIR="$TEST_LOGDIR"
LOG_FILE_PATTERN="audio-backup-%Y-%m-%d.log"
LIVE_JUNK_DIRS=("Analysis Files" "Autosaves" "Backup" "Undo" "Freeze")
LIVE_JUNK_GLOBS=("*.asd" ".DS_Store" "._*")
LAUNCHD_LABEL="com.test.audiobackup"
LAUNCHD_PLIST="$TESTROOT/test.plist"
EOF
export AUDIO_BACKUP_CONFIG="$TEST_BACKUP_CONFIG"

# Mock launchctl so start/stop/restart tests don't touch the real launchd.
# State (loaded labels) lives in a per-test tmp dir.
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

# ─── Test helpers ──────────────────────────────────────────────────────
run_manage() {
  if [ "$VERBOSE" -eq 1 ]; then
    "$MANAGE" "$@"
  else
    "$MANAGE" "$@" >/dev/null 2>&1
  fi
}

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

# ─── Tests ─────────────────────────────────────────────────────────────

heading "TEST 1: Pull a single file from Drive"
run_manage pull "Documents/INDEX.md" "$FAKE_LOCAL/INDEX.md"
assert "file exists after pull"     "[ -f \"$FAKE_LOCAL/INDEX.md\" ]"
assert "file content matches Drive" "grep -q '# INDEX' \"$FAKE_LOCAL/INDEX.md\""

heading "TEST 2: Pull a folder from Drive"
run_manage pull "Projects/TestProject" "$FAKE_LOCAL/TestProject"
assert "folder created"             "[ -d \"$FAKE_LOCAL/TestProject\" ]"
assert "folder contents pulled"     "[ -f \"$FAKE_LOCAL/TestProject/session.als\" ]"
assert "content matches Drive"      "grep -q 'original session data' \"$FAKE_LOCAL/TestProject/session.als\""

heading "TEST 3: Push modified file back to Audio drive"
echo "modified session data" > "$FAKE_LOCAL/TestProject/session.als"
run_manage push --yes "$FAKE_LOCAL/TestProject" "Projects/TestProject"
assert "target folder created on Audio drive" "[ -d \"$FAKE_AUDIO/Projects/TestProject\" ]"
assert "modified content landed"              "grep -q 'modified session data' \"$FAKE_AUDIO/Projects/TestProject/session.als\""

heading "TEST 4: Push to a new path that doesn't exist yet"
mkdir -p "$FAKE_LOCAL/BrandNewSession"
echo "fresh content" > "$FAKE_LOCAL/BrandNewSession/new.als"
run_manage push --yes "$FAKE_LOCAL/BrandNewSession" "Projects/BrandNewSession"
assert "new path created on Audio drive"  "[ -d \"$FAKE_AUDIO/Projects/BrandNewSession\" ]"
assert "new file content landed"          "grep -q 'fresh content' \"$FAKE_AUDIO/Projects/BrandNewSession/new.als\""

heading "TEST 5: Push refuses when Audio drive not mounted (no sentinel)"
rm -f "$FAKE_AUDIO/SYSTEM.md"
if "$MANAGE" push --yes "$FAKE_LOCAL/BrandNewSession" "Projects/Other" > /dev/null 2>&1; then
  echo -e "  ${RED}✗${NC} push should have failed with no sentinel"
  FAIL=$((FAIL + 1))
else
  echo -e "  ${GREEN}✓${NC} push correctly refused without sentinel"
  PASS=$((PASS + 1))
fi
touch "$FAKE_AUDIO/SYSTEM.md"  # restore

heading "TEST 6: Push respects rsync excludes (Live regeneratables)"
mkdir -p "$FAKE_LOCAL/SessionWithJunk/Analysis Files"
mkdir -p "$FAKE_LOCAL/SessionWithJunk/Autosaves"
echo "important.als" > "$FAKE_LOCAL/SessionWithJunk/important.als"
echo "junk1" > "$FAKE_LOCAL/SessionWithJunk/Analysis Files/cached.asd"
echo "junk2" > "$FAKE_LOCAL/SessionWithJunk/Autosaves/old.als"
echo "trash" > "$FAKE_LOCAL/SessionWithJunk/.DS_Store"
run_manage push --yes "$FAKE_LOCAL/SessionWithJunk" "Projects/SessionWithJunk"
assert "important file landed"        "[ -f \"$FAKE_AUDIO/Projects/SessionWithJunk/important.als\" ]"
assert "Analysis Files excluded"      "[ ! -d \"$FAKE_AUDIO/Projects/SessionWithJunk/Analysis Files\" ]"
assert "Autosaves excluded"           "[ ! -d \"$FAKE_AUDIO/Projects/SessionWithJunk/Autosaves\" ]"
assert ".DS_Store excluded"           "[ ! -f \"$FAKE_AUDIO/Projects/SessionWithJunk/.DS_Store\" ]"

heading "TEST 7: Pull missing args returns error"
if "$MANAGE" pull > /dev/null 2>&1; then
  echo -e "  ${RED}✗${NC} pull with no args should fail"
  FAIL=$((FAIL + 1))
else
  echo -e "  ${GREEN}✓${NC} pull with no args returns error"
  PASS=$((PASS + 1))
fi

heading "TEST 8: Push from non-existent local source fails cleanly"
if "$MANAGE" push --yes "/nope/does/not/exist" "Projects/Anything" > /dev/null 2>&1; then
  echo -e "  ${RED}✗${NC} push from missing source should fail"
  FAIL=$((FAIL + 1))
else
  echo -e "  ${GREEN}✓${NC} push from missing source returns error"
  PASS=$((PASS + 1))
fi

# ─── Sync gates (audio-backup-sync.sh, invoked via `audio-backup now`) ─

heading "TEST 9: Sync gate — mount sentinel missing → silent skip (exit 0)"
rm -f "$FAKE_AUDIO/SYSTEM.md"
output=$("$MANAGE" now 2>&1); status=$?
touch "$FAKE_AUDIO/SYSTEM.md"   # restore
if [ "$status" -eq 0 ] && echo "$output" | grep -qi "not mounted"; then
  echo -e "  ${GREEN}✓${NC} exits 0 with 'not mounted' message"; PASS=$((PASS+1))
else
  echo -e "  ${RED}✗${NC} status=$status, output: $output"; FAIL=$((FAIL+1))
fi

heading "TEST 10: Sync gate — router not in trusted allowlist → silent skip (exit 0)"
# Base test config sets TRUSTED_ROUTER_ALLOWLIST=("0.0.0.0") which never matches
# a real router, so any unforced `now` should fail this gate.
output=$("$MANAGE" now 2>&1); status=$?
if [ "$status" -eq 0 ] && echo "$output" | grep -qi "not in trusted allowlist"; then
  echo -e "  ${GREEN}✓${NC} exits 0 with 'not in trusted allowlist'"; PASS=$((PASS+1))
else
  echo -e "  ${RED}✗${NC} status=$status, output: $output"; FAIL=$((FAIL+1))
fi

heading "TEST 11: Sync gate — filters file missing → fatal (exit 1)"
ORIG_FILTERS="$SCRIPT_DIR/audio-backup-filters.txt"
# Point the test config at a non-existent filters file
sed -i.bak "s|^FILTERS_FILE=.*|FILTERS_FILE=\"/nope/does/not/exist.txt\"|" "$TEST_BACKUP_CONFIG"
output=$("$MANAGE" now --force --dry-run 2>&1); status=$?
mv "$TEST_BACKUP_CONFIG.bak" "$TEST_BACKUP_CONFIG"   # restore
if [ "$status" -ne 0 ] && echo "$output" | grep -qi "filters file not found"; then
  echo -e "  ${GREEN}✓${NC} exits non-zero with 'Filters file not found'"; PASS=$((PASS+1))
else
  echo -e "  ${RED}✗${NC} status=$status, output: $output"; FAIL=$((FAIL+1))
fi

heading "TEST 12: Sync gate — rclone remote not configured → fatal (exit 1)"
sed -i.bak "s|^RCLONE_REMOTE=.*|RCLONE_REMOTE=\"nonexistent-remote\"|" "$TEST_BACKUP_CONFIG"
output=$("$MANAGE" now --force --dry-run 2>&1); status=$?
mv "$TEST_BACKUP_CONFIG.bak" "$TEST_BACKUP_CONFIG"
if [ "$status" -ne 0 ] && echo "$output" | grep -qi "not configured"; then
  echo -e "  ${GREEN}✓${NC} exits non-zero with 'not configured'"; PASS=$((PASS+1))
else
  echo -e "  ${RED}✗${NC} status=$status, output: $output"; FAIL=$((FAIL+1))
fi

# ─── Sync end-to-end ───────────────────────────────────────────────────

heading "TEST 13: now --force --dry-run runs cleanly, no writes"
# Snapshot fake Drive state to verify no writes happened
DRIVE_SNAPSHOT_BEFORE=$(find "$FAKE_DRIVE/Backup/Audio" -type f | sort | sha256sum)
output=$("$MANAGE" now --force --dry-run 2>&1); status=$?
DRIVE_SNAPSHOT_AFTER=$(find "$FAKE_DRIVE/Backup/Audio" -type f | sort | sha256sum)
if [ "$status" -eq 0 ] && [ "$DRIVE_SNAPSHOT_BEFORE" = "$DRIVE_SNAPSHOT_AFTER" ] && echo "$output" | grep -qi "DRY-RUN"; then
  echo -e "  ${GREEN}✓${NC} dry-run completed, Drive unchanged"; PASS=$((PASS+1))
else
  echo -e "  ${RED}✗${NC} status=$status, Drive changed=$([ "$DRIVE_SNAPSHOT_BEFORE" = "$DRIVE_SNAPSHOT_AFTER" ] && echo no || echo yes)"; FAIL=$((FAIL+1))
fi

heading "TEST 14: now --force (real run) actually writes to Drive"
# Add a fresh file on the fake Audio drive that doesn't exist on Drive yet
echo "post-backup-test" > "$FAKE_AUDIO/Documents/POSTBACKUP.md"
output=$("$MANAGE" now --force 2>&1); status=$?
if [ "$status" -eq 0 ] && [ -f "$FAKE_DRIVE/Backup/Audio/Documents/POSTBACKUP.md" ]; then
  echo -e "  ${GREEN}✓${NC} sync ran, new file reflected to Drive"; PASS=$((PASS+1))
else
  echo -e "  ${RED}✗${NC} status=$status, file on Drive=$([ -f "$FAKE_DRIVE/Backup/Audio/Documents/POSTBACKUP.md" ] && echo yes || echo no)"; FAIL=$((FAIL+1))
fi
rm -f "$FAKE_AUDIO/Documents/POSTBACKUP.md"

# ─── launchctl lifecycle (uses mocked launchctl) ───────────────────────

heading "TEST 15: status — service not loaded (clean state)"
rm -rf "$LAUNCHCTL_STATE_DIR"/*  # ensure no loaded services
output=$("$MANAGE" status 2>&1); status=$?
if [ "$status" -eq 0 ] && echo "$output" | grep -qi "not loaded"; then
  echo -e "  ${GREEN}✓${NC} status reports 'not loaded' when stopped"; PASS=$((PASS+1))
else
  echo -e "  ${RED}✗${NC} status=$status, output: $output"; FAIL=$((FAIL+1))
fi

heading "TEST 16: start — fails when plist doesn't exist"
output=$("$MANAGE" start 2>&1); status=$?
if [ "$status" -ne 0 ] && echo "$output" | grep -qi "plist not found"; then
  echo -e "  ${GREEN}✓${NC} start errors when plist missing"; PASS=$((PASS+1))
else
  echo -e "  ${RED}✗${NC} status=$status, output: $output"; FAIL=$((FAIL+1))
fi

heading "TEST 17: start / stop lifecycle with mock launchctl"
# Generate a plist by hand (wizard --setup would do this; we replicate minimally)
cat > "$TESTROOT/test.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.test.audiobackup</string>
    <key>ProgramArguments</key>
    <array><string>/bin/true</string></array>
</dict>
</plist>
EOF
output=$("$MANAGE" start 2>&1); start_status=$?
loaded=$(ls "$LAUNCHCTL_STATE_DIR" 2>/dev/null | grep -c "com.test.audiobackup")
if [ "$start_status" -eq 0 ] && [ "$loaded" -eq 1 ]; then
  echo -e "  ${GREEN}✓${NC} start loaded the service via mock launchctl"; PASS=$((PASS+1))
else
  echo -e "  ${RED}✗${NC} start_status=$start_status, loaded count=$loaded"; FAIL=$((FAIL+1))
fi

output=$("$MANAGE" stop 2>&1); stop_status=$?
loaded_after=$(ls "$LAUNCHCTL_STATE_DIR" 2>/dev/null | grep -c "com.test.audiobackup")
if [ "$stop_status" -eq 0 ] && [ "$loaded_after" -eq 0 ]; then
  echo -e "  ${GREEN}✓${NC} stop unloaded the service via mock launchctl"; PASS=$((PASS+1))
else
  echo -e "  ${RED}✗${NC} stop_status=$stop_status, loaded count=$loaded_after"; FAIL=$((FAIL+1))
fi

# ─── Help / usage ──────────────────────────────────────────────────────

heading "TEST 18: no-args prints usage and exits 0"
output=$("$MANAGE" 2>&1); status=$?
if [ "$status" -eq 0 ] && echo "$output" | grep -qi "audio-backup start"; then
  echo -e "  ${GREEN}✓${NC} usage shown on no args"; PASS=$((PASS+1))
else
  echo -e "  ${RED}✗${NC} status=$status, output sample: $(echo "$output" | head -3)"; FAIL=$((FAIL+1))
fi

heading "TEST 19: --help prints usage and exits 0"
output=$("$MANAGE" --help 2>&1); status=$?
if [ "$status" -eq 0 ] && echo "$output" | grep -qi "wizard --setup"; then
  echo -e "  ${GREEN}✓${NC} --help shows wizard command"; PASS=$((PASS+1))
else
  echo -e "  ${RED}✗${NC} status=$status"; FAIL=$((FAIL+1))
fi

heading "TEST 20: unknown subcommand exits non-zero"
output=$("$MANAGE" gibberish 2>&1); status=$?
if [ "$status" -ne 0 ] && echo "$output" | grep -qi "unknown"; then
  echo -e "  ${GREEN}✓${NC} unknown command rejected"; PASS=$((PASS+1))
else
  echo -e "  ${RED}✗${NC} status=$status, output: $output"; FAIL=$((FAIL+1))
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
