#!/bin/bash
# FZF-based attachment handler for Neomutt
# Similar to Telescope file picker for attachments

# This script is called from neomutt's attachment view
# It extracts attachment information and provides FZF interface

# Temporary file to store attachment list
TMPFILE=$(mktemp)

# Get the message file from stdin
cat > "$TMPFILE"

# Extract attachments using mu view (if available) or fall back to basic parsing
if command -v munpack &>/dev/null; then
  # Use munpack to extract attachment info
  attachments=$(munpack -t < "$TMPFILE" 2>/dev/null | grep -E "^  " | sed 's/^  //')
else
  # Fallback: basic attachment detection
  attachments="No attachment extraction tool found. Please install mpack/munpack."
fi

# If no attachments found
if [ -z "$attachments" ] || [ "$attachments" = "No attachment extraction tool found. Please install mpack/munpack." ]; then
  echo "No attachments found or extraction failed"
  rm -f "$TMPFILE"
  exit 1
fi

# Show attachments in FZF
selected=$(echo "$attachments" | \
  fzf --height 50% \
      --reverse \
      --prompt "Attachment > " \
      --header "Select attachment to save/open" \
      --preview-window=hidden)

if [ -n "$selected" ]; then
  # Extract filename
  filename=$(echo "$selected" | awk '{print $1}')
  echo "Selected: $filename"

  # Ask what to do with the attachment
  action=$(echo -e "Open\nSave to Downloads\nSave to..." | \
    fzf --height 40% --reverse --header "What to do with $filename?")

  case "$action" in
    "Open")
      echo "Opening $filename..."
      # This would require extraction first
      ;;
    "Save to Downloads")
      echo "Saving to ~/Downloads/$filename..."
      ;;
    "Save to...")
      echo "Choose destination..."
      ;;
  esac
fi

# Cleanup
rm -f "$TMPFILE"
