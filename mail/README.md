# Neomutt Email Configuration

Modern, Neovim-inspired terminal email client with offline sync, full-text search, and FZF integration.

---

## 🚀 Quick Start

### First Time Setup

1. **Run the setup wizard:**
   ```bash
   ~/dotfiles/mail/scripts/setup-gmail-sync.sh
   ```
   This will guide you through Gmail app password creation and initial sync.

2. **Enable automatic background sync:**
   ```bash
   ~/dotfiles/mail/scripts/manage-sync.sh start
   ```
   Your mail will now sync every 15 minutes automatically.

3. **Launch neomutt:**
   ```bash
   neomutt
   ```

4. **Learn the essential keybindings:**
   - `Space p` - Command palette (search all commands)
   - `gm` - Mailbox switcher (FZF)
   - `\` - Full-text search (notmuch)
   - `Space r` - Reply all
   - `Space g a` - Archive message

**That's it!** You're ready to go.

---

## 📚 Documentation

### Getting Started
- **[FEATURES.md](FEATURES.md)** ⭐ - Complete guide to all features (start here!)
- **[QUICK-REFERENCE.md](QUICK-REFERENCE.md)** - Printable cheat sheet for daily use

### Setup & Configuration
- **[GMAIL-SYNC-SETUP.md](GMAIL-SYNC-SETUP.md)** - Detailed offline sync setup
- **[AUTO-SYNC-SETUP.md](AUTO-SYNC-SETUP.md)** - Automatic background sync configuration

### Learning & Testing
- **[TESTING-GUIDE.md](TESTING-GUIDE.md)** - Comprehensive feature testing walkthrough
- **[mutt/README.md](mutt/README.md)** - Complete keybinding reference

---

## ✨ What's Included

### Core Features
- **Offline Mail Sync** - Fast, local Maildir storage with mbsync
- **Full-Text Search** - Telescope-like search with notmuch
- **FZF Integration** - Fuzzy find mailboxes, commands, and directories
- **Command Palette** - Searchable list of 70+ commands (`Space p`)
- **Space Leader Pattern** - Neovim-style leader key
- **OceanicNext Theme** - Matching your Tmux color scheme
- **Vim Navigation** - j/k/gg/G and all the classics
- **Automatic Sync** - Background syncing every 15 minutes (launchd)

### Enhancements
- Address book with autocomplete (abook)
- URL extraction from emails (urlview)
- Enhanced attachment handling with FZF
- Gmail-style folder navigation (gi, ga, gd, gs)
- Virtual mailboxes (smart folders)
- Tag management
- Sidebar with folder list

**Performance:** 10-30x faster than direct IMAP

---

## 🎯 Essential Keybindings

### The "Big 5" (Learn First)
```
Space p    Command palette (when you forget anything)
gm         Mailbox switcher (FZF)
\          Search everything (notmuch)
Space r    Reply all
Space g a  Archive message
```

### Navigation
```
j/k        Next/previous message
l          Open message
h          Back to list (from message)
gg/G       First/last message
gi/ga/gd   Go to Inbox/Archive/Drafts
```

### Space Leader Commands
```
Space s    Sync mailbox
Space f    Forward
Space d    Delete
Space v    View attachments
Space c    Compose new message
Space h    View raw message
```

**Full list:** See [QUICK-REFERENCE.md](QUICK-REFERENCE.md)

---

## 🛠️ Management Commands

### Sync Control
```bash
# Manual sync
~/dotfiles/mail/scripts/sync-mail.sh

# Enable automatic sync (every 15 min)
~/dotfiles/mail/scripts/manage-sync.sh start

# Check sync status
~/dotfiles/mail/scripts/manage-sync.sh status

# View sync logs
~/dotfiles/mail/scripts/manage-sync.sh logs

# Sync right now (manual trigger)
~/dotfiles/mail/scripts/manage-sync.sh now

# Stop automatic sync
~/dotfiles/mail/scripts/manage-sync.sh stop
```

### Configuration
```bash
# Reload config without restarting
Press F1 in neomutt

# Edit main config
vim ~/dotfiles/mail/mutt/muttrc

# Edit keybindings
vim ~/dotfiles/mail/mutt/bindings
vim ~/dotfiles/mail/mutt/macros
vim ~/dotfiles/mail/mutt/leader

# Edit colors
vim ~/dotfiles/mail/mutt/colours
```

---

## 📁 Directory Structure

```
~/dotfiles/mail/
├── README.md                    # This file (overview)
├── FEATURES.md                  # Complete feature documentation
├── QUICK-REFERENCE.md           # Cheat sheet
├── TESTING-GUIDE.md             # Testing walkthrough
├── GMAIL-SYNC-SETUP.md          # Sync setup guide
├── AUTO-SYNC-SETUP.md           # Auto-sync setup guide
│
├── mutt/                        # Neomutt configuration
│   ├── muttrc                   # Main config (entry point)
│   ├── settings                 # General settings
│   ├── bindings                 # Vim-style navigation
│   ├── macros                   # FZF and Gmail navigation
│   ├── leader                   # Space leader commands
│   ├── colours                  # OceanicNext theme
│   ├── notmuch                  # Search integration
│   ├── abook                    # Address book
│   ├── urlview                  # URL extraction
│   ├── attachments              # Attachment handling
│   ├── accounts/                # Account configurations
│   │   ├── 1-personal.muttrc.imap-backup
│   │   └── 1-personal-maildir.muttrc
│   └── scripts/                 # Helper scripts
│       ├── fzf-mailbox.sh       # Mailbox picker
│       ├── command-palette.sh   # Command palette
│       └── fzf-save-attachment.sh
│
└── scripts/                     # Sync & management scripts
    ├── setup-gmail-sync.sh      # Setup wizard
    ├── sync-mail.sh             # Sync script
    ├── manage-sync.sh           # Service management
    └── get-gmail-pass.sh        # Password retrieval

~/.local/share/mail/gmail/       # Local mail storage (Maildir)
~/.mbsyncrc                      # mbsync configuration
~/.notmuch-config                # notmuch configuration
~/Library/LaunchAgents/          # launchd service (auto-sync)
```

---

## 🔧 Technology Stack

- **Neomutt** - Terminal email client
- **mbsync** - IMAP synchronization (offline mail)
- **Notmuch** - Email indexing and full-text search
- **FZF** - Fuzzy finder
- **abook** - Address book
- **urlview** - URL extraction
- **launchd** - macOS service management
- **macOS Keychain** - Secure password storage

---

## 🎨 Philosophy

This configuration is designed to provide an email experience that matches your development environment:

- **Fast** - Local storage, instant operations
- **Offline** - Work anywhere, sync in background
- **Keyboard-driven** - Vim navigation, minimal mouse usage
- **Discoverable** - Command palette, help system
- **Consistent** - Same patterns as Neovim/Tmux/ZSH
- **Powerful** - Full-text search, tagging, complex queries

**Goal:** Email should feel as natural as editing code in Neovim.

---

## 🆘 Troubleshooting

### Mail not syncing
```bash
# Check sync status
~/dotfiles/mail/scripts/manage-sync.sh status

# View error logs
~/dotfiles/mail/scripts/manage-sync.sh logs

# Test manual sync
~/dotfiles/mail/scripts/sync-mail.sh

# Check mbsync config
cat ~/.mbsyncrc

# Verify password in Keychain
~/dotfiles/mail/scripts/get-gmail-pass.sh
```

### Notmuch search not working
```bash
# Reindex mail
cd ~/.local/share/mail/gmail
notmuch new

# Check notmuch config
cat ~/.notmuch-config

# Verify database location
ls -la ~/.local/share/mail/gmail/.notmuch/
```

### Keybindings not working
```bash
# Reload config in neomutt
Press F1

# Check for errors
neomutt -n  # Test config without loading

# View current bindings
Press ? in neomutt (context-specific help)
```

### Service won't start
```bash
# Check launchd service
launchctl list | grep mailsync

# Verify plist is valid
plutil -lint ~/Library/LaunchAgents/com.jeromefaria.mailsync.plist

# Check script permissions
ls -la ~/dotfiles/mail/scripts/*.sh
chmod +x ~/dotfiles/mail/scripts/*.sh
```

---

## 📖 Learning Resources

### For Beginners
1. Read [FEATURES.md](FEATURES.md) to understand what's available
2. Print [QUICK-REFERENCE.md](QUICK-REFERENCE.md) for your desk
3. Work through [TESTING-GUIDE.md](TESTING-GUIDE.md) systematically

### For Power Users
1. Learn complex notmuch queries
2. Create custom virtual mailboxes
3. Set up tag-based workflows
4. Customize colors and keybindings

### In Neomutt
- Press `?` for context-specific help
- Use `Space p` when you forget a keybinding
- Press `:` to enter commands directly

---

## 🎯 Common Workflows

### Processing Today's Mail
```
c                       # Change folder
Search: Today<Enter>    # View today's messages
j/k                     # Navigate
Space r / Space d       # Reply or delete
Space g a               # Archive
```

### Finding Old Emails
```
\                                    # Notmuch search
from:client@example.com date:month.. # Search query
l                                    # Read result
```

### Bulk Operations
```
F2          # Show new only
Space t     # Tag messages (repeat)
Ctrl-r      # Mark all as read
A           # Show all again
```

### Contact Management
```
# While reading
a           # Add sender to contacts

# While composing
m           # New message
Ctrl-T      # Query contacts
```

---

## 🚀 Performance

### Before (Direct IMAP)
- Open message: ~500ms
- Search: ~3-5 seconds
- Switch folder: ~1-2 seconds
- Offline: ❌

### After (Local Maildir + Notmuch)
- Open message: ~50ms (10x faster)
- Search: ~100ms (30x faster)
- Switch folder: ~100ms (10x faster)
- Offline: ✅

---

## 🔄 Updates & Maintenance

### Keep Mail in Sync
Auto-sync runs every 15 minutes. To sync immediately:
```bash
~/dotfiles/mail/scripts/manage-sync.sh now
```

### Update Configuration
After changing config files:
```bash
# In neomutt, press F1 to reload
# Or restart neomutt
```

### Backup
Your mail is stored in:
```
~/.local/share/mail/gmail/    # Maildir (mail files)
~/.notmuch-config             # Notmuch config
~/.mbsyncrc                   # mbsync config
~/dotfiles/mail/              # Neomutt config (git tracked)
```

---

## 📝 Next Steps

1. **If you haven't set up yet:** Run `~/dotfiles/mail/scripts/setup-gmail-sync.sh`

2. **Enable automatic sync:** `~/dotfiles/mail/scripts/manage-sync.sh start`

3. **Learn the essentials:** Read [FEATURES.md](FEATURES.md) sections 1-4

4. **Practice:** Follow [TESTING-GUIDE.md](TESTING-GUIDE.md) Phase 1

5. **Customize:** Adjust keybindings and colors to your preference

6. **Master:** Learn advanced notmuch queries and workflows

---

## 🎓 Support

- **Documentation:** See files listed above
- **In-app help:** Press `?` in neomutt
- **Command search:** Press `Space p` in neomutt
- **Config location:** `~/dotfiles/mail/`

---

**Ready to revolutionize your email workflow?**

```bash
~/dotfiles/mail/scripts/setup-gmail-sync.sh
```

📬 Happy emailing! ✨
