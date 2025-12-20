#!/bin/bash
# FZF directory picker for saving attachments
# Provides a fuzzy-searchable directory selector

# Default locations for quick access
default_dirs=(
  "$HOME/Downloads"
  "$HOME/Documents"
  "$HOME/Desktop"
  "$HOME/Pictures"
  "$HOME/Work"
  "$HOME"
)

# If fd is available, find additional directories
if command -v fd &>/dev/null; then
  # Find directories up to 3 levels deep from home
  additional_dirs=$(fd -t d -d 3 . "$HOME" 2>/dev/null)
  all_dirs=$(printf '%s\n%s' "$(printf '%s\n' "${default_dirs[@]}")" "$additional_dirs" | sort -u)
else
  all_dirs=$(printf '%s\n' "${default_dirs[@]}")
fi

# Show FZF picker for directory selection
selected_dir=$(echo "$all_dirs" | \
  fzf --height 50% \
      --reverse \
      --prompt "Save to > " \
      --header "Select directory to save attachment" \
      --preview "ls -lah {} 2>/dev/null | head -20" \
      --preview-window=right:50%)

if [ -n "$selected_dir" ]; then
  echo "push <save-entry>$selected_dir/<enter>"
else
  echo "Cancelled"
fi
