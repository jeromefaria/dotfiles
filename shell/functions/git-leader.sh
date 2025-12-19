#!/usr/bin/env zsh
# Git leader key implementation for normal mode
# Handles 'g' prefix followed by b/l/s for git operations

# Git leader widget - waits for second keypress
git-leader-widget() {
  # Read the next character
  local char
  read -k 1 char

  case "$char" in
    b)
      # Git branches
      zle -U ''  # Clear any pending input
      fzf-git-branch
      ;;
    l)
      # Git log
      zle -U ''
      fzf-git-log
      ;;
    s)
      # Git status
      zle -U ''
      fzf-git-status
      ;;
    *)
      # Invalid key - just insert 'g' and the pressed key
      zle -U "g${char}"
      ;;
  esac
}
zle -N git-leader-widget
