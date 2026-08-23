#!/usr/bin/env zsh
# Test suite for the `plex` media-stack command (aliases/media-stack.sh).
# Usage: zsh test-media-stack.sh
#
# Hermetic: docker/colima/brew/open/sleep/python3 are stubbed to record their
# invocations to a call-log file instead of running for real, so no container,
# VM, or VPN is ever touched. Tests assert the dispatcher routes each subcommand
# to the right underlying command with the right arguments.
unset CLAUDECODE
: "${DOTFILES:=$HOME/dotfiles}"

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'
pass_count=0; fail_count=0
test_pass() { echo -e "${GREEN}✓${NC} $1"; ((pass_count++)); }
test_fail() { echo -e "${RED}✗${NC} $1"; ((fail_count++)); }
test_info() { echo -e "${YELLOW}ℹ${NC} $1"; }

# --- stubs: record calls to a file (subshells from `( … )` can append to it) ---
CALL_LOG=$(mktemp)
reset_calls() { : > "$CALL_LOG"; }
docker() {
  echo "docker $*" >> "$CALL_LOG"
  case "$1" in
    info)    return 0 ;;                       # boot's readiness poll passes immediately
    inspect) echo "healthy" ;;                 # boot's gluetun health poll passes immediately
    ps)      echo "radarr Up 1m" ;;
  esac
}
colima()  { echo "colima $*"  >> "$CALL_LOG"; [ "$1" = status ] && return 0; }
brew()    { echo "brew $*"    >> "$CALL_LOG"; }
open()    { echo "open $*"    >> "$CALL_LOG"; }
sleep()   { : ; }                              # no-op so poll loops don't wait
python3() { cat >/dev/null 2>&1; echo "python3 $*" >> "$CALL_LOG"; }  # swallow heredoc stdin

echo "==================================="
echo "plex media-stack command test suite"
echo "==================================="
echo

# --- load the command under test ---
if source "$DOTFILES/terminal/zsh/aliases/media-stack.sh" 2>/dev/null; then
  test_pass "media-stack.sh sources without error"
else
  test_fail "media-stack.sh failed to source"; echo; echo "aborting"; exit 1
fi
whence -w plex >/dev/null 2>&1 && test_pass "plex function is defined" || test_fail "plex function missing"
whence -w _plex_complete >/dev/null 2>&1 && test_pass "tab-completion function defined" || test_fail "completion missing"

echo; echo "1. Help & unknown commands"; echo "--------------------------"
out=$(plex help)
[[ "$out" == *"plex — media automation stack"* ]] && test_pass "plex help prints the header" || test_fail "help header missing"
[[ "$out" == *"plex boot"* && "$out" == *"plex fix"* && "$out" == *"plex web"* ]] && test_pass "help lists key subcommands" || test_fail "help missing subcommands"
[[ "$(plex)" == *"media automation stack"* ]] && test_pass "bare 'plex' shows help" || test_fail "bare plex should show help"
[[ "$(plex bogus 2>&1)" == *"unknown command 'bogus'"* ]] && test_pass "unknown command is reported" || test_fail "unknown command not handled"

echo; echo "2. web routing"; echo "--------------"
reset_calls; plex web radarr;    grep -qF "open http://localhost:7878" "$CALL_LOG" && test_pass "web radarr → :7878" || test_fail "web radarr routing"
reset_calls; plex web plex;      grep -qF "open http://localhost:32400/web" "$CALL_LOG" && test_pass "web plex → :32400/web" || test_fail "web plex routing"
[[ "$(plex web 2>&1)" == *"usage: plex web"* ]] && test_pass "web with no arg → usage" || test_fail "web usage missing"
[[ "$(plex web nope 2>&1)" == *"usage: plex web"* ]] && test_pass "web with bad arg → usage" || test_fail "web bad-arg usage missing"

echo; echo "3. fix routing (runbooks)"; echo "-------------------------"
reset_calls; plex fix qb;     grep -qF "docker restart qbittorrent" "$CALL_LOG" && test_pass "fix qb → restart qbittorrent" || test_fail "fix qb routing"
reset_calls; plex fix sonarr; grep -qF "docker restart sonarr" "$CALL_LOG" && test_pass "fix sonarr → restart sonarr" || test_fail "fix sonarr routing"
[[ "$(plex fix 2>&1)" == *"usage: plex fix"* ]] && test_pass "fix with no arg → usage" || test_fail "fix usage missing"
[[ "$(plex fix nope 2>&1)" == *"usage: plex fix"* ]] && test_pass "fix bad arg → usage" || test_fail "fix bad-arg usage missing"

echo; echo "4. lifecycle routing"; echo "--------------------"
reset_calls; plex up;             grep -qF "docker compose up -d" "$CALL_LOG" && test_pass "up → compose up -d" || test_fail "up routing"
reset_calls; plex down;           grep -qF "docker compose down" "$CALL_LOG" && test_pass "down → compose down" || test_fail "down routing"
reset_calls; plex restart radarr; grep -qF "docker restart radarr" "$CALL_LOG" && test_pass "restart <svc> → restart svc" || test_fail "restart routing"
reset_calls; plex update;         grep -qF "docker compose pull" "$CALL_LOG" && test_pass "update → compose pull" || test_fail "update routing"
reset_calls; plex status;         grep -qF "docker ps" "$CALL_LOG" && test_pass "status → docker ps" || test_fail "status routing"

echo; echo "5. boot / halt sequences"; echo "------------------------"
reset_calls; plex boot >/dev/null 2>&1
grep -qF "brew services start colima" "$CALL_LOG" && test_pass "boot starts Colima service" || test_fail "boot missing colima start"
grep -qF "docker compose up -d" "$CALL_LOG"        && test_pass "boot brings up the stack" || test_fail "boot missing compose up"
grep -qF "docker restart qbittorrent" "$CALL_LOG"  && test_pass "boot reconnects qBittorrent" || test_fail "boot missing qb reconnect"
reset_calls; plex halt >/dev/null 2>&1
grep -qF "docker compose stop" "$CALL_LOG"     && test_pass "halt stops the stack gracefully" || test_fail "halt missing compose stop"
grep -qF "brew services stop colima" "$CALL_LOG" && test_pass "halt stops the Colima service" || test_fail "halt missing brew stop"
grep -qF "colima stop" "$CALL_LOG"             && test_pass "halt stops the VM (agent-safe)" || test_fail "halt missing colima stop"

echo; echo "6. autostart"; echo "------------"
[[ "$(plex autostart bogus 2>&1)" == *"usage: plex autostart"* ]] && test_pass "autostart bad arg → usage" || test_fail "autostart usage missing"
reset_calls; plex autostart on;  grep -qF "brew services start colima" "$CALL_LOG" && test_pass "autostart on → brew start" || test_fail "autostart on routing"
reset_calls; plex autostart off; grep -qF "brew services stop colima" "$CALL_LOG" && test_pass "autostart off → brew stop" || test_fail "autostart off routing"

echo; echo "==================================="
echo -e "Passed: ${GREEN}${pass_count}${NC}   Failed: ${RED}${fail_count}${NC}"
echo "==================================="
rm -f "$CALL_LOG"
[ "$fail_count" -eq 0 ]
