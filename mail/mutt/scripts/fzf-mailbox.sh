#!/bin/bash
# FZF mailbox picker for Neomutt
# Similar to fzf-git-branch from ZSH configuration

# List of mailboxes with descriptions
mailboxes=(
  "INBOX:Main inbox"
  "[Gmail]/All Mail:Archive (all mail)"
  "[Gmail]/Sent Mail:Sent messages"
  "[Gmail]/Drafts:Draft messages"
  "[Gmail]/Spam:Spam folder"
  "[Gmail]/Trash:Deleted messages"
)

# Format for FZF display (with descriptions)
display_list=$(printf '%s\n' "${mailboxes[@]}" | \
  awk -F: '{printf "%-25s %s\n", $1, $2}')

# Show FZF picker
selected=$(echo "$display_list" | \
  fzf --height 40% \
      --reverse \
      --header "Select Mailbox" \
      --prompt "Mailbox > " \
      --preview-window=hidden)

# Extract mailbox path and output neomutt command
if [ -n "$selected" ]; then
  mailbox=$(echo "$selected" | awk '{print $1}')
  echo "push <change-folder>=$mailbox<enter>"
fi
