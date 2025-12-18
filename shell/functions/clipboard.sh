#!/usr/bin/env zsh
# Enhanced clipboard integration (like vim/tmux)

# ============================================================================
# ZSH COMMAND LINE CLIPBOARD OPERATIONS
# ============================================================================

# Yank current command to clipboard (like vim yy)
# Keybinding: Ctrl-Y Ctrl-Y in insert mode
yank-command-line() {
  if [[ -n "$BUFFER" ]]; then
    echo -n "$BUFFER" | pbcopy
    # Visual feedback
    echo -ne '\a'  # Terminal bell
    zle -M "Yanked command to clipboard"
  fi
}
zle -N yank-command-line

# Paste from clipboard (like vim p)
# Keybinding: Ctrl-V in insert mode
paste-from-clipboard() {
  local clip=$(pbpaste)
  if [[ -n "$clip" ]]; then
    # Clean up clipboard content (remove trailing newlines)
    clip="${clip%$'\n'}"
    LBUFFER+="$clip"
  fi
}
zle -N paste-from-clipboard

# Paste and execute
paste-and-execute() {
  local clip=$(pbpaste)
  if [[ -n "$clip" ]]; then
    clip="${clip%$'\n'}"
    BUFFER="$clip"
    zle accept-line
  fi
}
zle -N paste-and-execute

# ============================================================================
# DIRECTORY & PATH OPERATIONS
# ============================================================================

# Yank current directory path (pwd)
# Keybinding: Y in normal mode
yank-pwd() {
  pwd | tr -d '\n' | pbcopy
  echo "📋 Copied: $(pwd)"
}
zle -N yank-pwd

# Yank absolute path of file/directory under cursor
yank-absolute-path() {
  # Get the word under/before cursor
  local word
  if [[ $CURSOR -gt 0 ]]; then
    # Extract the path-like word at cursor
    local buffer_before="${BUFFER:0:$CURSOR}"
    local buffer_after="${BUFFER:$CURSOR}"

    # Find the start of the path (look for space or beginning)
    local start=0
    if [[ "$buffer_before" =~ (.* |^)([^ ]+)$ ]]; then
      word="${BASH_REMATCH[2]}"
    fi

    # Check if it looks like a path
    if [[ -e "$word" ]]; then
      local abs_path=$(realpath "$word" 2>/dev/null || echo "$word")
      echo -n "$abs_path" | pbcopy
      zle -M "Copied absolute path: $abs_path"
    elif [[ -e "$PWD/$word" ]]; then
      local abs_path=$(realpath "$PWD/$word")
      echo -n "$abs_path" | pbcopy
      zle -M "Copied absolute path: $abs_path"
    else
      zle -M "No valid path found under cursor"
    fi
  fi
}
zle -N yank-absolute-path

# Yank basename of current directory
yank-dirname() {
  basename "$(pwd)" | tr -d '\n' | pbcopy
  echo "📋 Copied: $(basename "$(pwd)")"
}
zle -N yank-dirname

# ============================================================================
# HISTORY OPERATIONS
# ============================================================================

# Yank last command to clipboard
yank-last-command() {
  fc -ln -1 | sed 's/^[[:space:]]*//' | tr -d '\n' | pbcopy
  zle -M "Copied last command to clipboard"
}
zle -N yank-last-command

# Yank last command's output (requires shell history of outputs)
# Note: This uses a simple hack - copies from scrollback
yank-last-output() {
  zle -M "Use tmux's copy mode or terminal selection to copy output"
}
zle -N yank-last-output

# Yank nth command from history
yank-history-command() {
  local commands=$(fc -l -50 | fzf --height 40% --reverse --header "Select command to copy")
  if [[ -n "$commands" ]]; then
    local command=$(echo "$commands" | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//')
    echo -n "$command" | pbcopy
    zle -M "Copied: $command"
  fi
}
zle -N yank-history-command

# ============================================================================
# SELECTION & REGION OPERATIONS
# ============================================================================

# Yank selected region (if mark is set)
yank-region() {
  if [[ -n "$MARK" ]] && [[ $MARK -ne $CURSOR ]]; then
    local start=$MARK
    local end=$CURSOR

    if [[ $start -gt $end ]]; then
      local temp=$start
      start=$end
      end=$temp
    fi

    local selection="${BUFFER:$start:$((end - start))}"
    echo -n "$selection" | pbcopy
    zle -M "Yanked selection: ${selection:0:50}..."
  else
    zle -M "No selection (set mark with Ctrl-Space)"
  fi
}
zle -N yank-region

# Copy and delete region (cut)
cut-region() {
  if [[ -n "$MARK" ]] && [[ $MARK -ne $CURSOR ]]; then
    local start=$MARK
    local end=$CURSOR

    if [[ $start -gt $end ]]; then
      local temp=$start
      start=$end
      end=$temp
    fi

    local selection="${BUFFER:$start:$((end - start))}"
    echo -n "$selection" | pbcopy

    # Delete the region
    BUFFER="${BUFFER:0:$start}${BUFFER:$end}"
    CURSOR=$start
    MARK=-1

    zle -M "Cut: ${selection:0:50}..."
  else
    zle -M "No selection"
  fi
}
zle -N cut-region

# ============================================================================
# SMART OPERATIONS
# ============================================================================

# Copy command without arguments (useful for documentation)
yank-command-name() {
  local cmd=$(echo "$BUFFER" | awk '{print $1}')
  if [[ -n "$cmd" ]]; then
    echo -n "$cmd" | pbcopy
    zle -M "Copied command: $cmd"
  fi
}
zle -N yank-command-name

# Copy all arguments (without command)
yank-arguments() {
  local args=$(echo "$BUFFER" | cut -d' ' -f2-)
  if [[ -n "$args" ]] && [[ "$args" != "$BUFFER" ]]; then
    echo -n "$args" | pbcopy
    zle -M "Copied arguments: ${args:0:50}..."
  else
    zle -M "No arguments found"
  fi
}
zle -N yank-arguments

# Copy last word (useful for file paths, arguments)
yank-last-word() {
  local last_word="${BUFFER##* }"
  if [[ -n "$last_word" ]]; then
    echo -n "$last_word" | pbcopy
    zle -M "Copied: $last_word"
  fi
}
zle -N yank-last-word

# ============================================================================
# CLIPBOARD MANIPULATION (non-widget functions)
# ============================================================================

# Copy file contents to clipboard
copy-file() {
  if [[ -f "$1" ]]; then
    cat "$1" | pbcopy
    echo "📋 Copied contents of: $1"
  else
    echo "Error: File not found: $1"
    return 1
  fi
}

# Copy multiple files to clipboard (concatenated)
copy-files() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: copy-files file1 [file2 ...]"
    return 1
  fi

  local content=""
  for file in "$@"; do
    if [[ -f "$file" ]]; then
      content+="### $file ###"$'\n'
      content+=$(cat "$file")
      content+=$'\n\n'
    fi
  done

  echo -n "$content" | pbcopy
  echo "📋 Copied $# file(s) to clipboard"
}

# Append to clipboard (add to existing clipboard content)
clipboard-append() {
  local current=$(pbpaste)
  local new="$1"
  echo "${current}${new}" | pbcopy
  echo "📋 Appended to clipboard"
}

# Clipboard history (simple ring buffer)
typeset -g CLIPBOARD_HISTORY_FILE="$HOME/.zsh_clipboard_history"
typeset -g CLIPBOARD_HISTORY_SIZE=50

# Save clipboard to history
clipboard-save() {
  local clip=$(pbpaste)
  if [[ -n "$clip" ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $clip" >> "$CLIPBOARD_HISTORY_FILE"
    # Keep only last N entries
    tail -n "$CLIPBOARD_HISTORY_SIZE" "$CLIPBOARD_HISTORY_FILE" > "${CLIPBOARD_HISTORY_FILE}.tmp"
    mv "${CLIPBOARD_HISTORY_FILE}.tmp" "$CLIPBOARD_HISTORY_FILE"
  fi
}

# Browse clipboard history with fzf
clipboard-history() {
  if [[ ! -f "$CLIPBOARD_HISTORY_FILE" ]]; then
    echo "No clipboard history found"
    return 1
  fi

  local selected=$(cat "$CLIPBOARD_HISTORY_FILE" |
    fzf --height 40% --reverse \
        --delimiter=' | ' \
        --with-nth=2.. \
        --preview='echo {2..}' \
        --header='Clipboard History')

  if [[ -n "$selected" ]]; then
    local content=$(echo "$selected" | cut -d'|' -f2- | sed 's/^ //')
    echo -n "$content" | pbcopy
    echo "📋 Restored to clipboard"
  fi
}

# Clear clipboard
clipboard-clear() {
  echo -n "" | pbcopy
  echo "📋 Clipboard cleared"
}

# Show clipboard content (useful for debugging)
clipboard-show() {
  echo "=== Clipboard Content ==="
  pbpaste
  echo "\n========================="
  echo "Length: $(pbpaste | wc -c) characters"
  echo "Lines: $(pbpaste | wc -l)"
}

# ============================================================================
# ALIASES FOR CONVENIENCE
# ============================================================================

alias yank='pbcopy'
alias paste='pbpaste'
alias y='pbcopy'
alias p='pbpaste'
alias cb='pbpaste'  # clipboard
alias cbc='clipboard-clear'
alias cbs='clipboard-show'
alias cbh='clipboard-history'

# Quick copy current directory
alias yp='yank-pwd'
alias ypwd='pwd | pbcopy && echo "Copied: $(pwd)"'

# Copy with feedback
alias copy='pbcopy && echo "Copied to clipboard"'
