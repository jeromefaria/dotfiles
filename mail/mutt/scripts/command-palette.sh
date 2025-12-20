#!/bin/bash
# Neomutt command palette - fuzzy searchable commands (like ZSH command palette)
# Similar to Neovim :Commands

# Define commands in format: "name:description:neomuttcommand"
commands=(
  # Message operations
  "sync:Sync all mailboxes:<sync-mailbox>"
  "reply-all:Reply to all recipients:<group-reply>"
  "forward:Forward current message:<forward-message>"
  "delete:Delete current message:<delete-message>"
  "undelete:Undelete message:<undelete-message>"
  "purge:Permanently delete (purge):<delete-message><sync-mailbox>"
  "bounce:Bounce/redirect message:<bounce-message>"
  "resend:Resend message:<resend-message>"

  # View operations
  "view-attachments:View message attachments:<view-attachments>"
  "view-raw:View raw message source:<view-raw-message>"
  "view-headers:Display all headers:<display-toggle-weed>"
  "show-urls:Extract URLs from message:<pipe-message>urlview<enter>"

  # Compose operations
  "compose:Compose new message:<mail>"
  "compose-to-sender:Compose to current sender:<compose-to-sender>"
  "recall-draft:Recall postponed message:<recall-message>"
  "edit-message:Edit/re-edit message:<edit>"

  # Search and filter
  "search:Search messages:<search>"
  "limit-unread:Show only unread:<limit>~U<enter>"
  "limit-flagged:Show only flagged:<limit>~F<enter>"
  "limit-today:Show today's mail:<limit>~d<1d<enter>"
  "limit-week:Show this week's mail:<limit>~d<7d<enter>"
  "limit-attachments:Show messages with attachments:<limit>~X 1-<enter>"
  "clear-limit:Clear all filters/limits:<limit>all<enter>"
  "notmuch-search:Notmuch full-text search:<vfolder-from-query>"

  # Folder operations
  "goto-inbox:Go to Inbox:<change-folder>=INBOX<enter>"
  "goto-sent:Go to Sent Mail:<change-folder>=[Gmail]/Sent\\ Mail<enter>"
  "goto-drafts:Go to Drafts:<change-folder>=[Gmail]/Drafts<enter>"
  "goto-archive:Go to All Mail (Archive):<change-folder>=[Gmail]/All\\ Mail<enter>"
  "goto-spam:Go to Spam:<change-folder>=[Gmail]/Spam<enter>"
  "goto-trash:Go to Trash:<change-folder>=[Gmail]/Trash<enter>"
  "fuzzy-mailbox:Fuzzy mailbox picker (FZF):<enter-command>source \$DOTFILES/mail/mutt/scripts/fzf-mailbox.sh|<enter>"

  # Message organization
  "archive:Move to All Mail (archive):;<save-message>=[Gmail]/All\\ Mail<enter>"
  "move-to-drafts:Move to Drafts:;<save-message>=[Gmail]/Drafts<enter>"
  "mark-spam:Move to Spam:;<save-message>=[Gmail]/Spam<enter>"
  "copy-to-folder:Copy to folder:;<copy-message>"
  "save-to-folder:Move to folder:;<save-message>"

  # Tagging and marking
  "toggle-new:Toggle new flag:<toggle-new>"
  "toggle-flag:Toggle important flag:<flag-message>"
  "mark-read:Mark as read:<clear-flag>N"
  "mark-unread:Mark as unread:<set-flag>N"
  "tag-message:Tag message for batch ops:<tag-entry>"
  "tag-thread:Tag entire thread:<tag-thread>"
  "tag-pattern:Tag by pattern:<tag-pattern>"
  "untag-all:Untag all messages:<untag-pattern>.<enter>"

  # Thread operations
  "collapse-thread:Collapse/expand thread:<collapse-thread>"
  "collapse-all:Collapse all threads:<collapse-all>"
  "read-thread:Mark thread as read:<read-thread>"
  "delete-thread:Delete entire thread:<delete-thread>"
  "entire-thread:Show entire thread (notmuch):<entire-thread>"

  # Batch operations
  "mark-all-read:Mark all as read:T~U<enter><tag-prefix><clear-flag>N<untag-pattern>.<enter>"
  "delete-all:Delete all visible:<tag-pattern>~A<enter><tag-prefix><delete-message>"
  "save-all:Save all visible:<tag-pattern>~A<enter><tag-prefix><save-message>"

  # Configuration
  "reload-config:Reload configuration:<enter-command>source \$DOTFILES/mail/mutt/muttrc<enter>"
  "show-version:Show Neomutt version:<version>"
  "show-keybindings:Show all keybindings:<help>"

  # Utility
  "print:Print message:<print-message>"
  "pipe-command:Pipe message to command:<pipe-message>"
  "shell-escape:Run shell command:<shell-escape>"
  "refresh:Refresh/redraw screen:<redraw-screen>"
  "quit:Quit Neomutt:<quit>"
)

# Use FZF to select command
selected=$(printf '%s\n' "${commands[@]}" | \
  awk -F: '{printf "%-25s %s\n", $1, $2}' | \
  fzf --height 50% \
      --reverse \
      --prompt "Command > " \
      --header "Neomutt Command Palette (like :Commands in Neovim)" \
      --preview-window=hidden)

# Execute selected command
if [ -n "$selected" ]; then
  cmd_name=$(echo "$selected" | awk '{print $1}')
  # Find the full command from the array
  for cmd in "${commands[@]}"; do
    if [[ "$cmd" == "$cmd_name:"* ]]; then
      neomutt_cmd=$(echo "$cmd" | cut -d: -f3)
      echo "push $neomutt_cmd"
      break
    fi
  done
fi
