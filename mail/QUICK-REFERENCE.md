# Neomutt Quick Reference Card

Print this or keep it open in another window while testing!

---

## 🎯 Most Useful New Features

| Feature | Key | What It Does |
|---------|-----|--------------|
| **Command Palette** | `Space p` | Search all 70+ commands (like :Commands) |
| **FZF Mailbox Picker** | `gm` | Fuzzy find folders |
| **Notmuch Search** | `\` | Full-text search all mail |
| **Virtual Mailboxes** | `c` → "Search:" | Smart folders (Today, Unread, etc.) |
| **URL Extraction** | `Ctrl-b` | Extract all URLs from message |
| **Sync Mailbox** | `Space s` | Sync with server |

---

## ⌨️ Space Leader Cheat Sheet

**Essential (Learn These First):**
```
Space p   Command palette ⭐
Space s   Sync
Space r   Reply all
Space f   Forward
Space d   Delete
Space v   View attachments
Space c   Compose new
```

**Navigation:**
```
Space g a   Archive (All Mail)
Space g d   Move to Drafts
Space g s   Move to Spam
```

**View:**
```
Space h   View raw/headers
Space u   Extract URLs
Space t   Tag message
Space T   Tag thread
```

**Search & Filter:**
```
Space /   Limit/filter
Space a   Show all (clear limit)
Space n   Next result
Space N   Previous result
```

---

## 📁 Gmail Folder Navigation

```
gi   Go to Inbox
ga   Go to All Mail (Archive)
gd   Go to Drafts
gs   Go to Sent
gS   Go to Spam
gm   FZF picker (fuzzy find) ⭐
```

**Pattern:** `g` + folder letter

**Move messages:**
```
Mi   Move to Inbox
Ma   Move to Archive
Md   Move to Drafts
Ms   Move to Sent
MS   Move to Spam
```

**Copy messages:**
```
Ci   Copy to Inbox
Ca   Copy to Archive
Cd   Copy to Drafts
Cs   Copy to Sent
CS   Copy to Spam
```

---

## 🔍 Notmuch Search Examples

Press `\` then type:

```
from:john@example.com          # From someone
subject:invoice                # Subject contains
date:today                     # Today's mail
date:week..                    # This week
date:month..                   # This month
tag:unread                     # Unread messages
tag:flagged                    # Flagged/starred
attachment:pdf                 # Has PDF attachment
from:boss AND date:today       # Combine criteria
subject:meeting OR call        # Either/or
NOT tag:spam                   # Exclude spam
```

---

## 📦 Virtual Mailboxes

Press `c` (change folder) then type "Search:"

```
Search: Today        # Today's messages
Search: This Week    # This week's messages
Search: This Month   # This month's messages
Search: Unread       # All unread (across all folders)
Search: Flagged      # All starred/flagged
Search: Attachments  # Messages with attachments
Search: To Me        # Direct messages to you
Search: From Me      # Messages sent by you
```

---

## 🎨 Vim-Style Navigation

```
j/k       Next/previous message
h/l       Back/forward (or exit/enter)
gg/G      First/last message
Ctrl-d    Page down
Ctrl-u    Page up
/         Search
n/N       Next/previous search result
```

---

## 📎 Attachment Handling

In message, press `v` to view attachments, then:

```
j/k   Navigate
l     View/open
o     Open with mailcap
s     Save with FZF picker ⭐
S     Save all to ~/Downloads
```

---

## 🗂️ Sidebar

```
B         Toggle sidebar
Ctrl-j    Next mailbox
Ctrl-k    Previous mailbox
Ctrl-o    Open mailbox
Ctrl-n    Next with new mail
Ctrl-p    Previous with new mail
```

---

## 📇 Address Book

```
a          Add sender to abook
A          Open abook interface
Space a    Add quietly (no confirm)
Ctrl-T     Query contacts (in compose)
```

---

## ⚡ Quick Actions

```
F1    Reload config
F2    Show new only
F3    Show flagged only
F4    Filter utilities
F5    Filter orders
F6    Filter PayPal
A     Show all (clear filter)
```

---

## 🏷️ Tagging & Marking

```
+           Modify tags (notmuch)
Space t     Tag message
Space T     Tag thread
F           Flag message
N           Mark as new
Ctrl-r      Mark all as read
```

---

## 🔧 Thread Operations

```
F8    Show entire thread (notmuch)
F9    Reconstruct thread
```

---

## 💬 Compose & Reply

```
m         New message (or Space c)
r         Reply
R         Reply all (or Space r)
f         Forward (or Space f)
P         Recall draft
Tab       Autocomplete address (in To:/Cc:)
```

---

## 🎪 Command Palette Categories

Press `Space p` then type to filter:

**Search for:**
- `delete` - All delete operations
- `sync` - Sync operations
- `archive` - Archive/move to All Mail
- `limit` - Filter operations
- `search` - Search options
- `compose` - Compose/edit operations
- `tag` - Tagging operations
- `thread` - Thread operations
- `view` - View options (attachments, raw, headers)

---

## 🐛 Troubleshooting Quick Fixes

**Bindings not working?**
```bash
# Reload config
Press F1 in neomutt
```

**Notmuch search doesn't work?**
```bash
# Check you've run sync first
~/dotfiles/mail/scripts/setup-gmail-sync.sh
```

**Virtual mailboxes missing?**
```bash
# Index mail with notmuch
cd ~/.local/share/mail/gmail
notmuch new
```

**Colors look wrong?**
```bash
# Check terminal supports 256 colors
echo $TERM  # should be "xterm-256color" or similar
```

---

## 📚 Learn More

- **Full testing guide:** `~/dotfiles/mail/TESTING-GUIDE.md`
- **Setup guide:** `~/dotfiles/mail/GMAIL-SYNC-SETUP.md`
- **Key bindings:** `~/dotfiles/mail/mutt/README.md`
- **Help in neomutt:** Press `?` in any view

---

## 🎯 Daily Workflow Example

```
1. gm              # Pick mailbox with FZF
2. j/k             # Browse messages
3. l               # Read message
4. Space r         # Reply
5. Space g a       # Archive
6. \               # Search for something
   from:boss
7. Space p         # Command palette
   "sync"          # Sync mailbox
8. q               # Quit
```

---

## ⚙️ Maintenance

**Sync mail:**
```bash
~/dotfiles/mail/scripts/sync-mail.sh
```

**Reindex search:**
```bash
cd ~/.local/share/mail/gmail
notmuch new
```

**Backup config:**
```bash
cd ~/dotfiles
git status
```

---

*Keep this handy while learning!* 📌
