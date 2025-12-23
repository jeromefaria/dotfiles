#!/usr/bin/env zsh
# Vim-like text manipulation commands and widgets for zsh

# ============================================================================
# INSERT MODE TEXT MANIPULATION
# ============================================================================

# Insert fat arrow (like nvim classic mode Ctrl-L)
# Keybinding: Ctrl-L in insert mode
insert-fat-arrow() {
  LBUFFER+=' => '
}
zle -N insert-fat-arrow

# Insert pipe operator
# Keybinding: Can be bound to Alt-|
insert-pipe() {
  LBUFFER+=' | '
}
zle -N insert-pipe

# Insert AND operator
# Keybinding: Can be bound to Alt-&
insert-and() {
  LBUFFER+=' && '
}
zle -N insert-and

# Insert OR operator
# Keybinding: Can be bound to Alt-||
insert-or() {
  LBUFFER+=' || '
}
zle -N insert-or

# ============================================================================
# LINE MANIPULATION (vim-inspired)
# ============================================================================

# Clear current line (like vim cc or S)
# Keybinding: Ctrl-K in insert mode
clear-line() {
  BUFFER=""
  CURSOR=0
}
zle -N clear-line

# Delete to end of line (like vim D)
# Keybinding: Can be used in normal mode
delete-to-eol() {
  BUFFER="${BUFFER:0:$CURSOR}"
}
zle -N delete-to-eol

# Delete to beginning of line (like vim d0)
delete-to-bol() {
  BUFFER="${BUFFER:$CURSOR}"
  CURSOR=0
}
zle -N delete-to-bol

# Duplicate current line (like vim yyp or Ctrl-D in modern editors)
# Keybinding: Ctrl-D in normal mode
duplicate-line() {
  local line="$BUFFER"
  BUFFER="$line"$'\n'"$line"
  CURSOR=$((${#line} + 1))
}
zle -N duplicate-line

# Delete entire line (like vim dd)
delete-line() {
  BUFFER=""
  CURSOR=0
}
zle -N delete-line

# ============================================================================
# CASE CONVERSION
# ============================================================================

# Toggle case of character under cursor
toggle-case() {
  if [[ $CURSOR -lt ${#BUFFER} ]]; then
    local char="${BUFFER:$CURSOR:1}"
    if [[ "$char" =~ [a-z] ]]; then
      BUFFER="${BUFFER:0:$CURSOR}${(U)char}${BUFFER:$CURSOR+1}"
    elif [[ "$char" =~ [A-Z] ]]; then
      BUFFER="${BUFFER:0:$CURSOR}${(L)char}${BUFFER:$CURSOR+1}"
    fi
    ((CURSOR++))
  fi
}
zle -N toggle-case

# Convert entire line to uppercase
uppercase-line() {
  BUFFER="${(U)BUFFER}"
}
zle -N uppercase-line

# Convert entire line to lowercase
lowercase-line() {
  BUFFER="${(L)BUFFER}"
}
zle -N lowercase-line

# Capitalize first letter of each word (title case)
titlecase-line() {
  BUFFER="${(C)BUFFER}"
}
zle -N titlecase-line

# ============================================================================
# WORD MANIPULATION
# ============================================================================

# Delete word backward (enhanced Ctrl-W)
delete-word-backward() {
  local orig_buffer="$BUFFER"
  local orig_cursor=$CURSOR

  # Move backward to start of word
  zle vi-backward-word
  local word_start=$CURSOR

  # Delete from word start to original cursor position
  BUFFER="${BUFFER:0:$word_start}${BUFFER:$orig_cursor}"
  CURSOR=$word_start
}
zle -N delete-word-backward

# Delete word forward
delete-word-forward() {
  local orig_cursor=$CURSOR

  # Move forward to end of word
  zle vi-forward-word
  local word_end=$CURSOR

  # Delete from original cursor to word end
  BUFFER="${BUFFER:0:$orig_cursor}${BUFFER:$word_end}"
  CURSOR=$orig_cursor
}
zle -N delete-word-forward

# Transpose words (swap current word with next)
transpose-words() {
  # Save current position
  local orig_cursor=$CURSOR

  # Get to start of current word
  zle vi-backward-word
  local word1_start=$CURSOR

  # Get to end of current word
  zle vi-forward-word-end
  local word1_end=$CURSOR
  local word1="${BUFFER:$word1_start:$((word1_end - word1_start + 1))}"

  # Skip whitespace
  ((CURSOR++))
  while [[ "${BUFFER:$CURSOR:1}" =~ [[:space:]] ]]; do
    ((CURSOR++))
  done
  local word2_start=$CURSOR

  # Get second word
  zle vi-forward-word-end
  local word2_end=$CURSOR
  local word2="${BUFFER:$word2_start:$((word2_end - word2_start + 1))}"

  # Swap them
  BUFFER="${BUFFER:0:$word1_start}${word2}${BUFFER:$word1_end+1:$((word2_start-word1_end-1))}${word1}${BUFFER:$word2_end+1}"

  zle reset-prompt
}
zle -N transpose-words

# ============================================================================
# SELECTION AND COPYING (visual mode simulation)
# ============================================================================

# Select entire line (like vim V)
select-line() {
  MARK=0
  CURSOR=${#BUFFER}
}
zle -N select-line

# Select entire buffer (like vim ggVG)
select-all() {
  MARK=0
  CURSOR=${#BUFFER}
}
zle -N select-all

# ============================================================================
# SMART NAVIGATION
# ============================================================================

# Jump to beginning of line (like vim ^)
beginning-of-line-text() {
  # Skip leading whitespace
  CURSOR=0
  while [[ "${BUFFER:$CURSOR:1}" =~ [[:space:]] ]]; do
    ((CURSOR++))
  done
}
zle -N beginning-of-line-text

# Jump to matching bracket (like vim %)
jump-to-matching-bracket() {
  local brackets='()[]{}'
  local char="${BUFFER:$CURSOR:1}"
  local match_char=""
  local direction=1

  case "$char" in
    '(') match_char=')' ;;
    ')') match_char='(' direction=-1 ;;
    '[') match_char=']' ;;
    ']') match_char='[' direction=-1 ;;
    '{') match_char='}' ;;
    '}') match_char='{' direction=-1 ;;
    *) return ;;
  esac

  local count=1
  local pos=$CURSOR

  while ((count > 0 && pos >= 0 && pos < ${#BUFFER})); do
    ((pos += direction))
    local next_char="${BUFFER:$pos:1}"

    if [[ "$next_char" == "$char" ]]; then
      ((count++))
    elif [[ "$next_char" == "$match_char" ]]; then
      ((count--))
    fi
  done

  if ((count == 0)); then
    CURSOR=$pos
  fi
}
zle -N jump-to-matching-bracket

# ============================================================================
# UNDO/REDO ENHANCEMENT
# ============================================================================

# Create undo point (useful before making big changes)
create-undo-point() {
  # The undo system in zsh is automatic, but this widget
  # can be used to ensure an undo point is created
  zle split-undo
}
zle -N create-undo-point

# ============================================================================
# QUICK FIXES
# ============================================================================

# Fix common typos on the fly
fix-typos() {
  # Common typos to fix
  BUFFER="${BUFFER//gti /git }"
  BUFFER="${BUFFER//grpe /grep }"
  BUFFER="${BUFFER//teh /the }"
  BUFFER="${BUFFER//taht /that }"
  BUFFER="${BUFFER//yuor /your }"

  zle reset-prompt
}
zle -N fix-typos

# Expand aliases (useful to see what an alias will do)
expand-alias() {
  zle _expand_alias
  zle self-insert
}
zle -N expand-alias

# ============================================================================
# DIRECTORY MANIPULATION IN COMMAND LINE
# ============================================================================

# Quick dirname insertion (useful for file paths)
insert-dirname() {
  if [[ -n "$LBUFFER" ]]; then
    # Get the last word (path)
    local last_word="${LBUFFER##* }"
    if [[ -f "$last_word" ]]; then
      local dirname=$(dirname "$last_word")
      # Replace the last word with its directory
      LBUFFER="${LBUFFER%$last_word}$dirname/"
    fi
  fi
}
zle -N insert-dirname

# Quick basename insertion
insert-basename() {
  if [[ -n "$LBUFFER" ]]; then
    local last_word="${LBUFFER##* }"
    if [[ -f "$last_word" ]]; then
      local basename=$(basename "$last_word")
      LBUFFER="${LBUFFER%$last_word}$basename"
    fi
  fi
}
zle -N insert-basename

# ============================================================================
# HELPER FUNCTIONS (not widgets, for use in scripts)
# ============================================================================

# Smart quote toggle (add/remove quotes around argument)
smart-quote() {
  local text="$1"
  if [[ "$text" =~ ^\".*\"$ ]] || [[ "$text" =~ ^\'.*\'$ ]]; then
    # Remove quotes
    echo "${text:1:-1}"
  else
    # Add quotes
    echo "\"$text\""
  fi
}
