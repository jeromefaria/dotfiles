# Neomutt Configuration

This directory contains configuration files for [Neomutt](https://neomutt.org/), a command-line email client.

## Files

- **muttrc** - Main configuration file that sources all other config files
- **settings** - General settings and options
- **bindings** - Custom key bindings
- **macros** - Custom macros for common operations
- **colours** - Color scheme configuration
- **mailcap** - MIME type handlers for attachments
- **accounts/** - Account-specific configurations

## Custom Key Bindings

### Navigation (Vim-style)

| Key | Context | Action | Description |
|-----|---------|--------|-------------|
| `j` | index | next-entry | Move to next message |
| `k` | index | previous-entry | Move to previous message |
| `j` | pager | next-line | Scroll down one line |
| `k` | pager | previous-line | Scroll up one line |
| `l` | index | display-message | Open/view message |
| `l` | attach | view-mailcap | Open attachment |
| `h` | pager/attach | exit | Go back/exit |
| `gg` | index/attach | first-entry | Jump to first message |
| `gg` | pager/browser | top-page | Jump to top |
| `G` | index/attach | last-entry | Jump to last message |
| `G` | pager/browser | bottom-page | Jump to bottom |
| `<up>` | pager | previous-line | Scroll up |
| `<down>` | pager | next-line | Scroll down |

### Message Operations

| Key | Context | Action | Description |
|-----|---------|--------|-------------|
| `D` | pager | delete-message | Delete current message |
| `U` | pager | undelete-message | Undelete message |
| `Ctrl-d` | index | purge-message | Delete message permanently |
| `L` | index | limit | Limit/filter messages |
| `Space` | index | tag-entry | Tag/select message |
| `H` | index/pager | view-raw-message | View raw email source |
| `S` | index/pager | sync-mailbox | Sync mailbox |
| `R` | index/pager | group-reply | Reply to all |
| `@` | index/pager | compose-to-sender | Compose email to sender |
| `N` | index/pager | search-opposite | Search in opposite direction |

### Compose & Postpone

| Key | Context | Action | Description |
|-----|---------|--------|-------------|
| `P` | compose | postpone-message | Save draft |
| `P` | index | recall-message | Recall postponed message |
| `Tab` | editor | complete-query | Auto-complete email address |

### Sidebar Navigation

| Key | Context | Action | Description |
|-----|---------|--------|-------------|
| `B` | index/pager | sidebar-toggle-visible | Toggle sidebar visibility |
| `Ctrl-k` | index/pager | sidebar-prev | Previous mailbox |
| `Ctrl-j` | index/pager | sidebar-next | Next mailbox |
| `Ctrl-o` | index/pager | sidebar-open | Open selected mailbox |
| `Ctrl-p` | index/pager | sidebar-prev-new | Previous mailbox with new mail |
| `Ctrl-n` | index/pager | sidebar-next-new | Next mailbox with new mail |

### Browser

| Key | Context | Action | Description |
|-----|---------|--------|-------------|
| `l` | browser | select-entry | Select/open entry |
| `h` | browser | - | Go to parent folder (via macro) |

## Custom Macros

### Quick Actions

| Key | Context | Description |
|-----|---------|-------------|
| `Ctrl-r` | index | Mark all messages as read |
| `A` | index | Show all messages (undo limit) |
| `h` | browser | Go to parent folder |

### Account Switching

| Key | Description |
|-----|-------------|
| `i1` | Switch to personal account (jerome.faria@gmail.com) |

### Configuration & Filtering

| Key | Description |
|-----|-------------|
| `F1` | Reload configuration |
| `F2` | Show only new messages |
| `F3` | Show only flagged messages |
| `F4` | Filter utilities (EDP, EPAL, MEO, Vodafone, Activobank, etc.) |
| `F5` | Filter orders and packages |
| `F6` | Filter PayPal messages |

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
