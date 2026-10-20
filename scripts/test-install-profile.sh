#!/bin/bash
# Integration tests for scripts/install.sh's profile gating.
#
# Strategy: source install.sh under its BASH_SOURCE guard (so main() does not
# run), then drive the profile-aware phases — link_dotfiles, seed_templates's
# git-identity step, persist_profile and install_packages — against a fake
# DOTFILES_DIR and HOME. Nothing under the real $HOME is touched and no
# package manager is invoked: brew and install-packages.sh are stubbed.
#
# Covers install_packages, which had no suite at all. That gap is how a bare
# `brew bundle install` survived in a directory holding no file named
# `Brewfile` — the step only ever ran on the dry-run path during testing,
# which short-circuits before the command.
#
# Usage:
#   bash test-install-profile.sh          # quiet
#   bash test-install-profile.sh -v       # verbose

# shellcheck disable=SC2034
# DOTFILES_DIR, BACKUP_DIR, INTERACTIVE, DRY_RUN and PROFILE are inputs to the
# install.sh functions sourced below, not locals of this script.

set -uo pipefail

VERBOSE=0
[ "${1:-}" = "-v" ] && VERBOSE=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_SCRIPT="$SCRIPT_DIR/install.sh"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -t 1 ]; then
  GREEN='\033[0;32m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
else
  GREEN=''; RED=''; BLUE=''; NC=''
fi

PASS=0
FAIL=0

TESTROOT="$(mktemp -d -t install-profile-test-XXXXXX)"
FAKE_DOTFILES="$TESTROOT/dotfiles"
FAKE_HOME="$TESTROOT/home"
FAKE_BACKUP="$TESTROOT/backup"
STUB_BIN="$TESTROOT/bin"
PKG_CALLS="$TESTROOT/pkg-calls.log"

cleanup() {
  if [ -n "${TESTROOT:-}" ] && [ -d "$TESTROOT" ]; then
    chmod -R u+w "$TESTROOT" 2>/dev/null
    rm -rf "$TESTROOT"
  fi
}
trap cleanup EXIT

echo -e "${BLUE}━━━ install.sh profile tests ━━━${NC}"
echo "Test workspace: $TESTROOT"
echo ""

mkdir -p "$FAKE_HOME" "$FAKE_BACKUP" "$STUB_BIN" \
         "$FAKE_DOTFILES"/{config,mail,terminal/tmux,editors,git,packages}

# A DOTFILES_DIR shaped like the real one, so link_dotfiles has sources to
# point at. Contents are irrelevant; only presence is checked.
for d in nvim bat gh aria2 beets mpv musikcube skhd yabai; do
  mkdir -p "$FAKE_DOTFILES/config/$d"
done
: > "$FAKE_DOTFILES/config/starship.toml"
mkdir -p "$FAKE_DOTFILES/mail/mutt" "$FAKE_DOTFILES/terminal/tmux/tmuxinator"
mkdir -p "$FAKE_DOTFILES/editors/vim" "$FAKE_DOTFILES/terminal/zsh"
: > "$FAKE_DOTFILES/terminal/zsh/zshrc"
: > "$FAKE_DOTFILES/editors/vim/vimrc"
: > "$FAKE_DOTFILES/terminal/tmux/tmux.conf"
: > "$FAKE_DOTFILES/git/gitconfig"

# Stub install-packages.sh so the package phase records its arguments instead
# of talking to Homebrew.
cat > "$FAKE_DOTFILES/packages/install-packages.sh" <<STUB
#!/bin/bash
echo "\$@" >> "$PKG_CALLS"
exit 0
STUB
chmod +x "$FAKE_DOTFILES/packages/install-packages.sh"

cat > "$STUB_BIN/brew" <<'STUB'
#!/bin/bash
echo "brew $*" >&2
exit 0
STUB
chmod +x "$STUB_BIN/brew"
PATH="$STUB_BIN:$PATH"

# ─── Source install.sh under the BASH_SOURCE guard ─────────────────────
set +e
DOTFILES_DIR="$FAKE_DOTFILES"
HOME="$FAKE_HOME"

# shellcheck source=/dev/null
source "$INSTALL_SCRIPT"
trap - ERR INT TERM
set +e

BACKUP_DIR="$FAKE_BACKUP"
INTERACTIVE=false
DRY_RUN=false

pass() { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS + 1)); }
fail() {
  echo -e "  ${RED}✗${NC} $1"
  [ "$VERBOSE" -eq 1 ] && [ -n "${2:-}" ] && echo "      $2"
  FAIL=$((FAIL + 1))
}

reset_home() {
  rm -rf "$FAKE_HOME"
  mkdir -p "$FAKE_HOME"
  : > "$PKG_CALLS"
}

# ─── TEST 1: the default profile is personal ───────────────────────────
echo "── TEST 1: default profile ──"
if [ "$PROFILE" = "personal" ]; then
  pass "PROFILE defaults to personal"
else
  fail "PROFILE defaults to personal" "got '$PROFILE'"
fi

if is_personal_profile; then
  pass "is_personal_profile true by default"
else
  fail "is_personal_profile true by default"
fi

# ─── TEST 2: persist_profile records the choice ────────────────────────
echo "── TEST 2: the profile is recorded for the shell ──"
reset_home
PROFILE="work"
persist_profile > /dev/null 2>&1
if [ "$(cat "$FAKE_HOME/.dotfiles-profile" 2>/dev/null)" = "work" ]; then
  pass "work written to ~/.dotfiles-profile"
else
  fail "work written to ~/.dotfiles-profile" "got '$(cat "$FAKE_HOME/.dotfiles-profile" 2>/dev/null)'"
fi

reset_home
DRY_RUN=true
persist_profile > /dev/null 2>&1
if [ ! -e "$FAKE_HOME/.dotfiles-profile" ]; then
  pass "dry run records nothing"
else
  fail "dry run records nothing"
fi
DRY_RUN=false

# ─── TEST 3: work leaves out the personal configs ──────────────────────
echo "── TEST 3: work skips media and window-manager configs ──"
reset_home
PROFILE="work"
link_dotfiles > "$TESTROOT/work-link.log" 2>&1

work_has() { [ -e "$FAKE_HOME/.config/$1" ] || [ -L "$FAKE_HOME/.config/$1" ]; }

missing=""
for item in beets mpv musikcube aria2 skhd yabai; do
  work_has "$item" && missing="$missing $item"
done
if [ -z "$missing" ]; then
  pass "none of beets/mpv/musikcube/aria2/skhd/yabai linked"
else
  fail "none of beets/mpv/musikcube/aria2/skhd/yabai linked" "linked anyway:$missing"
fi

present=""
for item in nvim bat gh starship.toml; do
  work_has "$item" || present="$present $item"
done
if [ -z "$present" ]; then
  pass "the dev configs are still linked"
else
  fail "the dev configs are still linked" "absent:$present"
fi

if ! work_has neomutt; then
  pass "the neomutt mail config is not linked"
else
  fail "the neomutt mail config is not linked"
fi

if work_has tmuxinator; then
  pass "tmuxinator is still linked (dev tooling)"
else
  fail "tmuxinator is still linked (dev tooling)"
fi

# ─── TEST 4: personal links everything ─────────────────────────────────
echo "── TEST 4: personal links the full set ──"
reset_home
PROFILE="personal"
link_dotfiles > "$TESTROOT/personal-link.log" 2>&1

absent=""
for item in nvim bat gh starship.toml beets mpv musikcube aria2 skhd yabai neomutt tmuxinator; do
  work_has "$item" || absent="$absent $item"
done
if [ -z "$absent" ]; then
  pass "all twelve configs linked"
else
  fail "all twelve configs linked" "absent:$absent"
fi

# ─── TEST 5: the work git identity ─────────────────────────────────────
echo "── TEST 5: work seeds a placeholder git identity ──"
reset_home
PROFILE="work"
seed_work_git_identity > /dev/null 2>&1
if [ -f "$FAKE_HOME/.gitconfig.local" ]; then
  pass "~/.gitconfig.local seeded"
else
  fail "~/.gitconfig.local seeded"
fi

if grep -q '@invalid' "$FAKE_HOME/.gitconfig.local" 2>/dev/null; then
  pass "the placeholder address is in the reserved .invalid TLD"
else
  fail "the placeholder address is in the reserved .invalid TLD"
fi

# The whole point is that a personal address cannot survive onto a work box.
if ! grep -qE '@(gmail|googlemail|icloud|me|hotmail)\.com' "$FAKE_HOME/.gitconfig.local" 2>/dev/null; then
  pass "no personal address written"
else
  fail "no personal address written"
fi

# An existing file is the user's own work and must not be clobbered.
echo "# hand-written" > "$FAKE_HOME/.gitconfig.local"
seed_work_git_identity > /dev/null 2>&1
if [ "$(head -1 "$FAKE_HOME/.gitconfig.local")" = "# hand-written" ]; then
  pass "an existing ~/.gitconfig.local is left alone"
else
  fail "an existing ~/.gitconfig.local is left alone"
fi

echo "── TEST 6: personal does not seed one ──"
reset_home
PROFILE="personal"
seed_work_git_identity > /dev/null 2>&1
if [ ! -e "$FAKE_HOME/.gitconfig.local" ]; then
  pass "personal leaves ~/.gitconfig.local alone"
else
  fail "personal leaves ~/.gitconfig.local alone"
fi

# ─── TEST 7: the package phase picks a profile and actually runs ───────
echo "── TEST 7: install_packages routes through install-packages.sh ──"
reset_home
PROFILE="work"
SKIP_PACKAGES=false
install_packages > "$TESTROOT/work-pkg.log" 2>&1
if grep -q -- "--profile work" "$PKG_CALLS" 2>/dev/null; then
  pass "work asks for the work package profile"
else
  fail "work asks for the work package profile" "calls: $(cat "$PKG_CALLS" 2>/dev/null)"
fi

reset_home
PROFILE="personal"
install_packages > "$TESTROOT/personal-pkg.log" 2>&1
if grep -q -- "--profile full" "$PKG_CALLS" 2>/dev/null; then
  pass "personal asks for the full package profile"
else
  fail "personal asks for the full package profile" "calls: $(cat "$PKG_CALLS" 2>/dev/null)"
fi

# The regression guard: the old code ran `brew bundle` in packages/, which
# holds no file called Brewfile. Assert we invoke the wrapper instead.
if ! grep -q 'bundle' "$TESTROOT/personal-pkg.log" 2>/dev/null; then
  pass "no bare 'brew bundle' is attempted"
else
  fail "no bare 'brew bundle' is attempted" "$(grep bundle "$TESTROOT/personal-pkg.log" | head -1)"
fi

reset_home
DRY_RUN=true
install_packages > "$TESTROOT/dry-pkg.log" 2>&1
if [ ! -s "$PKG_CALLS" ]; then
  pass "a dry run installs nothing"
else
  fail "a dry run installs nothing" "calls: $(cat "$PKG_CALLS")"
fi
DRY_RUN=false

# ─── TEST 8: the --profile flag is validated ───────────────────────────
echo "── TEST 8: --profile validation ──"
out=$(cd "$REPO_ROOT" && bash scripts/install.sh --profile nonsense 2>&1)
if [ $? -ne 0 ] && echo "$out" | grep -qi "unknown profile"; then
  pass "an unknown profile is rejected by name"
else
  fail "an unknown profile is rejected by name" "$out"
fi

for p in personal work; do
  out=$(cd "$REPO_ROOT" && bash scripts/install.sh --profile "$p" --help 2>&1)
  if [ $? -eq 0 ]; then
    pass "--profile $p is accepted"
  else
    fail "--profile $p is accepted" "$out"
  fi
done

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
