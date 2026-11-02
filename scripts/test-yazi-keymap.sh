#!/bin/bash
# Tests for config/yazi/keymap.toml.
#
# Two things rotted here at once and neither could announce itself. yazi
# ignores a binding whose command it cannot parse — no error, no log line, the
# key simply stops doing anything — so `peek`, `search fd`, `tasks_show`,
# `copy dirname`, `--dir_first`, `--confirm` and `--state=true` all survived
# their renames as dead config. And the file used `keymap = [ ... ]`, which
# replaces the default keymap outright, so 102 default bindings nobody had
# listed were silently unavailable while 63 identical restatements sat in the
# file. The section names [select] and [completion] had been renamed upstream
# to [pick] and [cmp], which made those 17 bindings dead too.
#
# What this suite can check is the shape: that the file parses, that it only
# ever prepends, that the variables it names are ones zshrc actually exports,
# and that the specific commands we know were renamed do not come back. It
# cannot check a command against the installed yazi, because yazi offers no
# way to ask — which is the reason the file needs a gate at all.
#
# Usage:
#   bash test-yazi-keymap.sh          # quiet
#   bash test-yazi-keymap.sh -v       # verbose

set -uo pipefail

VERBOSE=0
[ "${1:-}" = "-v" ] && VERBOSE=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
KEYMAP="$REPO_ROOT/config/yazi/keymap.toml"
ZSHRC="$REPO_ROOT/terminal/zsh/zshrc"

if [ -t 1 ]; then
  GREEN='\033[0;32m'; RED='\033[0;31m'; BLUE='\033[0;34m'; NC='\033[0m'
else
  GREEN=''; RED=''; BLUE=''; NC=''
fi

PASS=0
FAIL=0

pass() { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS + 1)); }
fail() {
  echo -e "  ${RED}✗${NC} $1"
  [ "$VERBOSE" -eq 1 ] && [ -n "${2:-}" ] && echo "      $2"
  FAIL=$((FAIL + 1))
}

heading() { echo ""; echo "── $1 ──"; }

echo -e "${BLUE}━━━ yazi keymap tests ━━━${NC}"

# ─── TEST 1: the file is valid TOML ────────────────────────────────────
# yazi falls back to its defaults for a keymap it cannot parse, so a broken
# file costs every custom binding at once and says nothing about it.
heading "TEST 1: the keymap parses"
if parse_error=$(python3 -c "
import sys, tomllib
try:
    tomllib.load(open('$KEYMAP', 'rb'))
except Exception as exc:
    sys.exit(str(exc))
" 2>&1); then
  pass "keymap.toml is valid TOML"
else
  fail "keymap.toml is valid TOML" "$parse_error"
fi

# ─── TEST 2: it only ever prepends ─────────────────────────────────────
heading "TEST 2: no section replaces the default keymap"
if grep -qE '^\s*keymap\s*=' "$KEYMAP"; then
  fail "every section uses prepend_keymap" \
       "a bare 'keymap =' replaces the defaults: $(grep -nE '^\s*keymap\s*=' "$KEYMAP" | tr '\n' ' ')"
else
  pass "every section uses prepend_keymap"
fi

sections=$(grep -cE '^\[' "$KEYMAP")
prepends=$(grep -cE '^\s*prepend_keymap\s*=' "$KEYMAP")
if [ "$sections" -gt 0 ] && [ "$sections" -eq "$prepends" ]; then
  pass "all $sections sections declare a prepend_keymap"
else
  fail "all sections declare a prepend_keymap" "$sections sections, $prepends prepend_keymap"
fi

# ─── TEST 3: the section names are the current ones ────────────────────
# [select] became [pick] and [completion] became [cmp]. A section yazi does
# not recognise is not an error either; it is simply never consulted.
heading "TEST 3: no renamed section names remain"
stale_sections=""
for section in select completion manager; do
  grep -qE "^\[$section\]" "$KEYMAP" && stale_sections="$stale_sections [$section]"
done

if [ -z "$stale_sections" ]; then
  pass "no [select], [completion] or [manager] section"
else
  fail "no renamed section names" "found:$stale_sections"
fi

# ─── TEST 4: no command this yazi has renamed away ─────────────────────
# Each of these was in the file and doing nothing. The list is the record of
# what broke silently, so a copy-paste from an old config cannot bring one
# back unnoticed.
heading "TEST 4: no command that was renamed upstream"
BINDINGS=$(mktemp -t yazi-keymap-bindings-XXXXXX)
trap 'rm -f "$BINDINGS"' EXIT
grep -vE '^[[:space:]]*#' "$KEYMAP" > "$BINDINGS"
declare -a renamed=(
  "peek:seek"
  "tasks_show:tasks:show"
  "copy dirname:copy dirpath"
  "search fd:search --via=fd"
  "search rg:search --via=rg"
  "search none:escape --search"
  "--dir_first:--dir-first, or drop it and let yazi.toml's sort_dir_first apply"
  "--confirm:--interactive, or just --block"
  "--state=true:--state=on"
  "sort created:sort btime"
  "sort modified:sort mtime"
)
found=""
for pair in "${renamed[@]}"; do
  needle=${pair%%:*}
  grep -qF -- "$needle" "$BINDINGS" && found="$found '$needle' (use ${pair#*:})"
done

if [ -z "$found" ]; then
  pass "none of the ${#renamed[@]} renamed commands appear"
else
  fail "a renamed command is back" "$found"
fi

# ─── TEST 5: every variable it names is exported by zshrc ──────────────
# This is the point of wiring the shortcuts to variables rather than literals:
# one place defines a path. It only holds while both halves agree, and the
# keymap half is in a file nothing else here reads.
heading "TEST 5: every \$VAR in the keymap is exported by zshrc"
missing=""
vars=$(grep -oE '\$\{?[A-Z_][A-Z0-9_]*\}?' "$BINDINGS" | tr -d '${}' | sort -u)

for name in $vars; do
  # $SHELL is the login shell, not ours to export.
  [ "$name" = "SHELL" ] && continue

  grep -qE "^\s*export $name=" "$ZSHRC" || missing="$missing \$$name"
done

if [ -n "$vars" ]; then
  pass "found $(echo "$vars" | wc -l | tr -d ' ') variables to check"
else
  fail "found variables to check" "none — the check would pass vacuously"
fi

if [ -z "$missing" ]; then
  pass "all of them are exported by zshrc"
else
  fail "a variable is not exported by zshrc" "missing:$missing"
fi

# ─── TEST 6: the shell aliases use the variables too ───────────────────
# folders.sh rebuilt $SHARED by hand as "$DRIVE/Shared", so one path had two
# expressions and the move that invalidated it only showed up in one of them.
heading "TEST 6: folders.sh builds no path a variable already names"
FOLDERS="$REPO_ROOT/terminal/zsh/aliases/folders.sh"
rebuilt=""
composites=0

while IFS= read -r export_line; do
  name=${export_line%%=*}
  value=${export_line#*=}

  # Only the ones built on another variable can be rebuilt by hand.
  case "$value" in '$'*/*) ;; *) continue ;; esac
  composites=$((composites + 1))

  grep -qF "cd $value\"" "$FOLDERS" && rebuilt="$rebuilt $value (use \$$name)"
done < <(sed -nE 's/^[[:space:]]*export ([A-Z_]+)="([^"]+)"/\1=\2/p' "$ZSHRC")

if [ "$composites" -gt 0 ]; then
  pass "zshrc names $composites composite paths to check against"
else
  fail "zshrc names composite paths" "none found — the check would pass vacuously"
fi

if [ -z "$rebuilt" ]; then
  pass "no alias spells out a path zshrc already names"
else
  fail "an alias spells out a path zshrc already names" "$rebuilt"
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
