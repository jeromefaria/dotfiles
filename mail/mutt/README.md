# Neomutt Configuration

This directory contains configuration files for [Neomutt](https://neomutt.org/), a command-line email client.

## Files

- **muttrc** - Main configuration file that sources all other config files
- **settings** - General settings and options
- **notmuch** - Notmuch integration for powerful search (Telescope-like)
- **bindings** - Custom key bindings
- **macros** - Custom macros for common operations
- **colours** - Color scheme configuration
- **mailcap** - MIME type handlers for attachments
- **scripts/** - Helper scripts for enhanced functionality (FZF integration, etc.)
- **accounts/** - Account-specific configurations

## Key Bindings Reference

### Core Navigation (Vim-style)

| Key | Context | Description |
|-----|---------|-------------|
| `j` | index | Move to next message |
| `k` | index | Move to previous message |
| `j` | pager | Scroll down one line |
| `k` | pager | Scroll up one line |
| `l` | index | Open/view selected message |
| `l` | pager | View attachments |
| `l` | attach | Open attachment with mailcap |
| `l` | browser | Select/open entry |
| `h` | pager | Go back to message list |
| `h` | attach | Exit attachment view |
| `h` | browser | Go to parent folder |
| `gg` | index | Jump to first message |
| `gg` | attach | Jump to first attachment |
| `gg` | pager | Jump to top of message |
| `gg` | browser | Jump to top |
| `G` | index | Jump to last message |
| `G` | attach | Jump to last attachment |
| `G` | pager | Jump to bottom of message |
| `G` | browser | Jump to bottom |
| `↑` | pager | Scroll up one line |
| `↓` | pager | Scroll down one line |

### Message Operations

| Key | Context | Description |
|-----|---------|-------------|
| `Space` | index | Tag/select message for batch operations |
| `D` | pager | Delete current message |
| `U` | pager | Undelete message |
| `Ctrl-d` | index | Permanently delete message (purge) |
| `L` | index | Limit/filter visible messages |
| `A` | index | Show all messages (remove limit) |
| `H` | index/pager | View raw email source |
| `S` | index/pager | Sync mailbox with server |
| `R` | index/pager | Reply to all recipients |
| `@` | index/pager | Compose new email to sender |
| `N` | index/pager | Search in opposite direction |
| `Ctrl-r` | index | Mark all messages as read |

### Compose & Editor

| Key | Context | Description |
|-----|---------|-------------|
| `P` | compose | Postpone message (save as draft) |
| `P` | index | Recall postponed message |
| `Tab` | editor | Auto-complete email address |

### Gmail Folder Navigation

Navigate, move, and copy messages between Gmail folders using mnemonic keys:
- **Pattern**: `g` = go to folder, `M` = move message, `C` = copy message
- **Folders**: `i` = inbox, `a` = all mail (archive), `d` = drafts, `s` = sent, `S` = spam

| Key | Context | Description |
|-----|---------|-------------|
| `gm` | index/pager | **Fuzzy mailbox switcher (FZF)** |
| `gi` | index/pager | Go to Inbox |
| `Mi` | index/pager | Move message to Inbox |
| `Ci` | index/pager | Copy message to Inbox |
| `ga` | index/pager | Go to All Mail (Archive) |
| `Ma` | index/pager | Move message to All Mail |
| `Ca` | index/pager | Copy message to All Mail |
| `gd` | index/pager | Go to Drafts |
| `Md` | index/pager | Move message to Drafts |
| `Cd` | index/pager | Copy message to Drafts |
| `gs` | index/pager | Go to Sent Mail |
| `Ms` | index/pager | Move message to Sent Mail |
| `Cs` | index/pager | Copy message to Sent Mail |
| `gS` | index/pager | Go to Spam |
| `MS` | index/pager | Move message to Spam |
| `CS` | index/pager | Copy message to Spam |

### Sidebar Navigation

| Key | Context | Description |
|-----|---------|-------------|
| `B` | index/pager | Toggle sidebar visibility |
| `Ctrl-j` | index/pager | Next mailbox in sidebar |
| `Ctrl-k` | index/pager | Previous mailbox in sidebar |
| `Ctrl-o` | index/pager | Open selected mailbox |
| `Ctrl-n` | index/pager | Next mailbox with new mail |
| `Ctrl-p` | index/pager | Previous mailbox with new mail |

### Account Management

| Key | Context | Description |
|-----|---------|-------------|
| `i1` | index/pager | Switch to personal account (jerome.faria@gmail.com) |

### Quick Filters & Function Keys

| Key | Context | Description |
|-----|---------|-------------|
| `F1` | index | Reload Neomutt configuration |
| `F2` | index | Show only new messages |
| `F3` | index | Show only flagged messages |
| `F4` | index | Filter utilities (EDP, EPAL, MEO, Vodafone, etc.) |
| `F5` | index | Filter orders and packages (order, encomenda, #) |
| `F6` | index | Filter PayPal messages |

### Notmuch Search (Telescope-like)

Powerful full-text search using notmuch virtual mailboxes:

| Key | Context | Description |
|-----|---------|-------------|
| `\` | index/pager | Open notmuch search query (like Telescope live_grep) |
| `+` | index/pager | Modify tags (add/remove labels) |
| `F7` | index/pager | Notmuch search prompt |
| `F8` | index/pager | Show entire email thread |
| `F9` | index/pager | Reconstruct thread view |

**Virtual Mailboxes** - Access via `c` (change folder):
- Search: Inbox - All inbox messages
- Search: Unread - Unread messages across all folders
- Search: Flagged - Starred/flagged messages
- Search: Today - Today's messages
- Search: This Week - Messages from this week
- Search: This Month - Messages from this month
- Search: Attachments - Messages with attachments
- Search: To Me - Direct messages to you
- Search: From Me - Messages sent by you

## Key Binding Patterns

Understanding the logic behind key choices makes them easier to remember:

- **Vim Navigation**: Movement keys follow Vim conventions (`hjkl`, `gg/G` for start/end)
- **Gmail Folders**: Three-letter pattern for each folder
  - First letter: `g` (go), `M` (move), or `C` (copy)
  - Second letter: folder identifier (`i`nbox, `a`rchive, `d`rafts, `s`ent, `S`pam)
- **Case Sensitivity**: Uppercase often indicates a more destructive/permanent action
  - `D` (delete) vs `U` (undelete)
  - `S` (spam) vs `s` (sent)
  - `M` (move) vs standard motion keys

## Useful Tips

- Press `?` in any context to see all available keybindings for that view
- Use `:` to enter Neomutt commands directly
- Press `v` on a message to view attachments
- Press `y` to change folders manually
- Press `/` to search messages
- Mouse wheel scrolling is supported in both index and pager views

## Features

### Security
- SSL certificate verification enabled
- GPG encryption support for PGP messages

### Performance
- IMAP keepalive for persistent connections
- IMAP IDLE for real-time notifications
- Message cache auto-cleanup
- Header cache compression

### Usability
- Format=flowed support for better text wrapping
- Auto-reflow text when viewing
- 10 index lines visible while reading messages
- Line-by-line scrolling instead of page-by-page
- Don't collapse threads with unread or flagged messages

### MIME Type Support (mailcap)

The configuration includes handlers for various file types:

- **Text**: Plain text, HTML (lynx/browser), CSV (sc-im), Markdown (glow), YAML (bat)
- **Images**: All image formats (system default viewer)
- **Video**: All video formats (mpv)
- **Documents**: PDF (system default viewer)
- **Spreadsheets**: Excel, ODS (sc-im)
- **Data**: JSON (jq with syntax highlighting)
- **Calendar**: iCal files (khal)
- **Security**: PGP encrypted messages (gpg)

## Tips

- Use `?` in any context to see all available keybindings
- Use `:` to enter commands directly
- Press `v` on a message to view attachments
- Use `y` to change folders
- Press `/` to search messages
