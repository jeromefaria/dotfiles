# Neomutt New Features - Testing Guide

Complete walkthrough to test every new feature and binding.

---

## 🎨 Phase 1: Test Features That Work NOW

These features work immediately with your current IMAP setup.

### Test 1: OceanicNext Color Theme

**Steps:**
1. Open neomutt: `neomutt`
2. Look at the interface

**Expected Results:**
- ✅ Status bar has cyan background (#6699CC)
- ✅ New messages highlighted in cyan
- ✅ Flagged messages in yellow
- ✅ Selection bar (indicator) has cyan background
- ✅ Overall dark theme matching Tmux

**Pass/Fail:** _______

---

### Test 2: Vim-Style Navigation

**Steps:**
1. In neomutt index view
2. Try these keys:

| Key | Expected Action | Works? |
|-----|----------------|--------|
| `j` | Move down one message | ☐ |
| `k` | Move up one message | ☐ |
| `gg` | Jump to first message | ☐ |
| `G` | Jump to last message | ☐ |
| `l` | Open/view message | ☐ |
| `h` | (in pager) Go back to list | ☐ |

**Pass/Fail:** _______

---

### Test 3: FZF Mailbox Switcher

**Steps:**
1. In neomutt, press `gm`

**Expected Results:**
- ✅ FZF window opens with mailbox list
- ✅ Shows: INBOX, All Mail, Sent Mail, Drafts, Spam, Trash
- ✅ Type to filter (e.g., "sent")
- ✅ Arrow keys to select
- ✅ Enter switches to that folder

**Screenshot moment:** This is like your `gb` git branch picker!

**Pass/Fail:** _______

---

### Test 4: Space Leader - Essential Operations

Try these space-based shortcuts:

| Shortcut | Expected Action | Works? |
|----------|----------------|--------|
| `Space s` | Sync mailbox | ☐ |
| `Space r` | Reply to all | ☐ |
| `Space f` | Forward message | ☐ |
| `Space d` | Delete message | ☐ |
| `Space v` | View attachments | ☐ |
| `Space h` | View raw message | ☐ |
| `Space c` | Compose new message | ☐ |

**Tips:**
- Select a message first (with j/k)
- Try Space+r on a message to test reply
- Try Space+v on a message with attachments

**Pass/Fail:** _______

---

### Test 5: Command Palette (Star Feature!)

**Steps:**
1. Press `Space p` anywhere in neomutt

**Expected Results:**
- ✅ FZF window opens
- ✅ Header says "Neomutt Command Palette (like :Commands in Neovim)"
- ✅ Shows 70+ commands
- ✅ Type "delete" - filters to delete operations
- ✅ Type "sync" - shows sync operations
- ✅ Arrow keys to select, Enter to execute

**Try searching for:**
- "archive"
- "forward"
- "compose"
- "limit"
- "reload"

**Screenshot moment:** This is your `:Commands` in Neovim!

**Pass/Fail:** _______

---

### Test 6: Gmail Folder Navigation

Try the Gmail-style shortcuts:

| Shortcut | Expected Action | Works? |
|----------|----------------|--------|
| `gi` | Go to Inbox | ☐ |
| `gs` | Go to Sent | ☐ |
| `gd` | Go to Drafts | ☐ |
| `ga` | Go to All Mail (Archive) | ☐ |
| `gS` | Go to Spam | ☐ |

**Pattern:** `g` + folder letter (i=inbox, s=sent, d=drafts, a=archive)

**Pass/Fail:** _______

---

### Test 7: Sidebar Navigation

**Steps:**
1. Press `B` to toggle sidebar

**Expected Results:**
- ✅ Sidebar appears on left showing mailbox list
- ✅ Shows unread counts for each folder
- ✅ Try these keys:

| Key | Expected Action | Works? |
|-----|----------------|--------|
| `Ctrl-j` | Next mailbox in sidebar | ☐ |
| `Ctrl-k` | Previous mailbox | ☐ |
| `Ctrl-o` | Open selected mailbox | ☐ |
| `B` | Toggle sidebar off/on | ☐ |

**Pass/Fail:** _______

---

### Test 8: Address Book (abook)

**Steps:**
1. Select any message
2. Press `a` (lowercase)

**Expected Results:**
- ✅ Prompts to add sender to address book
- ✅ Sender's email is captured

**Alternative test:**
3. Press `A` (uppercase)

**Expected Results:**
- ✅ Opens full abook interface
- ✅ Shows contact management screen

**To test autocomplete:**
4. Press `m` to compose new message
5. In the To: field, press `Ctrl-T`

**Expected Results:**
- ✅ Shows contact search/query prompt
- ✅ Can select from address book

**Pass/Fail:** _______

---

### Test 9: URL Extraction (urlview)

**Steps:**
1. Find a message with URLs (like an email newsletter)
2. Open the message (`l`)
3. Press `Ctrl-b`

**Expected Results:**
- ✅ Shows numbered list of all URLs in message
- ✅ Can select URL to open in browser

**Alternative:** Try `Space u` (space leader version)

**Pass/Fail:** _______

---

### Test 10: Attachment Handling

**Steps:**
1. Find a message with attachments
2. Press `v` to view attachments

**In attachment view, try:**

| Key | Expected Action | Works? |
|-----|----------------|--------|
| `j/k` | Navigate attachments | ☐ |
| `l` | Open/view attachment | ☐ |
| `o` | Open with mailcap | ☐ |
| `S` | Save all to ~/Downloads | ☐ |
| `s` | FZF directory picker | ☐ |

**FZF save test:**
3. Press `s` in attachment view

**Expected Results:**
- ✅ FZF window shows directories
- ✅ Shows preview of directory contents
- ✅ Can type to filter directories
- ✅ Select destination to save

**Pass/Fail:** _______

---

### Test 11: Quick Filters (F-Keys)

Try these quick filters:

| Key | Expected Action | Works? |
|-----|----------------|--------|
| `F1` | Reload config | ☐ |
| `F2` | Show only new messages | ☐ |
| `F3` | Show only flagged | ☐ |
| `A` | Clear filter (show all) | ☐ |

**Pass/Fail:** _______

---

### Test 12: Message Operations

Try these on various messages:

| Key/Combo | Expected Action | Works? |
|-----------|----------------|--------|
| `Space t` | Tag message | ☐ |
| `Space T` | Tag entire thread | ☐ |
| `L` | Limit/filter by pattern | ☐ |
| `Space /` | Limit (leader version) | ☐ |
| `Space n` | Next search result | ☐ |
| `Ctrl-r` | Mark all as read | ☐ |

**Pass/Fail:** _______

---

## 🔍 Phase 2: Test After Mail Sync Setup

Run `~/dotfiles/mail/scripts/setup-gmail-sync.sh` first, then test these.

### Test 13: Notmuch Quick Search

**Steps:**
1. Press `\` (backslash)
2. Type a search query

**Try these queries:**
```
from:example@gmail.com
subject:invoice
date:today
date:week..
tag:unread
attachment:pdf
```

**Expected Results:**
- ✅ Shows matching messages instantly
- ✅ Full-text search across all mail
- ✅ Results update as you type

**Pass/Fail:** _______

---

### Test 14: Virtual Mailboxes

**Steps:**
1. Press `c` (change folder)
2. Type "Search" (with capital S)

**Expected Results:**
- ✅ Shows virtual mailbox options:
  - Search: Inbox
  - Search: Unread
  - Search: Flagged
  - Search: Today
  - Search: This Week
  - Search: This Month
  - Search: Attachments
  - Search: To Me
  - Search: From Me

**Test a few:**
3. Select "Search: Today"
   - ✅ Shows today's messages only
4. Press `c` again, select "Search: Unread"
   - ✅ Shows all unread messages across all folders
5. Press `c` again, select "Search: Flagged"
   - ✅ Shows all flagged/starred messages

**Screenshot moment:** These are like Telescope saved searches!

**Pass/Fail:** _______

---

### Test 15: Notmuch Tag Management

**Steps:**
1. Select a message
2. Press `+`

**Expected Results:**
- ✅ Shows tag modification prompt
- ✅ Can add tags: `+important +work`
- ✅ Can remove tags: `-inbox`

**Test queries with tags:**
3. Press `\` and search `tag:important`
   - ✅ Shows messages you tagged

**Pass/Fail:** _______

---

### Test 16: Thread Operations

**Steps:**
1. Find a message that's part of a thread
2. Try these:

| Key | Expected Action | Works? |
|-----|----------------|--------|
| `F8` | Show entire thread | ☐ |
| `F9` | Reconstruct thread | ☐ |
| `Space T` | Tag whole thread | ☐ |

**Pass/Fail:** _______

---

### Test 17: Complex Notmuch Queries

**Steps:**
1. Press `\` (notmuch search)
2. Try advanced queries:

```
from:boss@company.com AND date:week..
subject:meeting OR subject:call
attachment:pdf AND date:today
NOT tag:spam AND tag:unread
```

**Expected Results:**
- ✅ Boolean operators work (AND, OR, NOT)
- ✅ Can combine multiple criteria
- ✅ Results are accurate

**Pass/Fail:** _______

---

## 🎯 Phase 3: Workflow Testing

Test real-world workflows combining multiple features.

### Workflow 1: Process Today's Mail

**Steps:**
1. Press `c` → select "Search: Today"
2. Review with `j/k`
3. Archive important ones: `Space g a`
4. Delete junk: `Space d`
5. Reply to urgent: `Space r`

**Time it:** How long to process 10 messages? _______

**Pass/Fail:** _______

---

### Workflow 2: Find and Archive Old Threads

**Steps:**
1. Press `\` → search `from:client@example.com date:month..`
2. Review threads with `j/k`
3. Tag multiple: `Space t` (repeat on each)
4. Press `Space p` → type "archive"
5. Select "archive all visible" or archive tagged

**Pass/Fail:** _______

---

### Workflow 3: Quick Contact Management

**Steps:**
1. Receive email from new contact
2. Press `a` to add to address book
3. Compose new message: `Space c`
4. Press `Ctrl-T` in To: field
5. Type contact name → auto-completes

**Time it:** How fast can you add and use a contact? _______

**Pass/Fail:** _______

---

### Workflow 4: Research Email History

**Steps:**
1. Press `\`
2. Search: `from:someone@example.com`
3. See all emails from that person
4. Refine: add `AND attachment:contract`
5. Find that one email with contract

**How many keystrokes?** _______

**Pass/Fail:** _______

---

### Workflow 5: Bulk Operations

**Steps:**
1. Press `F2` (show new only)
2. Tag 5 messages: `Space t` on each
3. Press `Space p` → search "mark"
4. Select "mark all as read"
5. Verify all are now read

**Pass/Fail:** _______

---

## 🧪 Phase 4: Edge Cases & Stress Tests

### Test 18: Large Mailbox Performance

**Steps:**
1. Go to All Mail: `ga`
2. Try these and note speed:
   - `gg` (jump to first of 1000s)
   - `G` (jump to last)
   - `/` then search pattern
   - `Space p` (command palette)

**Performance acceptable?** Yes / No

**Pass/Fail:** _______

---

### Test 19: Offline Mode

**Steps:**
1. Disconnect WiFi/network
2. Open neomutt
3. Try these:
   - Read messages
   - Search with `\`
   - Use virtual mailboxes
   - Compose (save as draft)

**Expected Results:**
- ✅ Everything works offline (after initial sync)
- ✅ Can read all synced mail
- ✅ Search works
- ✅ Only sending fails (expected)

**Pass/Fail:** _______

---

### Test 20: Command Palette Search Speed

**Steps:**
1. Press `Space p`
2. Type "del" (partial)
3. Type "sync"
4. Type "archive"

**Expected Results:**
- ✅ Filters instantly (< 100ms)
- ✅ Shows relevant commands
- ✅ Fuzzy matching works

**Pass/Fail:** _______

---

## 📊 Results Summary

### Features Working (✓/✗)

**Phase 1 (Works Now):**
- [ ] OceanicNext colors
- [ ] Vim navigation
- [ ] FZF mailbox switcher
- [ ] Space leader bindings
- [ ] Command palette
- [ ] Gmail folder navigation
- [ ] Sidebar
- [ ] Address book
- [ ] URL extraction
- [ ] Attachment handling
- [ ] Quick filters
- [ ] Message operations

**Phase 2 (After Sync):**
- [ ] Notmuch search
- [ ] Virtual mailboxes
- [ ] Tag management
- [ ] Thread operations
- [ ] Complex queries

**Phase 3 (Workflows):**
- [ ] Process today's mail
- [ ] Find and archive
- [ ] Contact management
- [ ] Email history research
- [ ] Bulk operations

**Phase 4 (Stress Tests):**
- [ ] Large mailbox performance
- [ ] Offline mode
- [ ] Command palette speed

---

## 🐛 Issue Tracker

Found issues? Document them here:

### Issue 1
**What:** _______________________________
**Expected:** __________________________
**Actual:** ____________________________
**Steps to reproduce:** ________________

### Issue 2
**What:** _______________________________
**Expected:** __________________________
**Actual:** ____________________________
**Steps to reproduce:** ________________

---

## 💡 Pro Tips Discovered

Write down useful tricks you discover:

1. ____________________________________________
2. ____________________________________________
3. ____________________________________________

---

## ⏱️ Speed Comparisons

**Before (IMAP direct):**
- Open message: ______ ms
- Search: ______ ms
- Switch folder: ______ ms

**After (Local Maildir):**
- Open message: ______ ms
- Search: ______ ms
- Switch folder: ______ ms

**Speedup factor:** ______x

---

## 🎓 Learning Curve

**Time to feel comfortable with:**
- Basic space leader: ______ minutes
- Command palette: ______ minutes
- Notmuch search: ______ minutes
- Virtual mailboxes: ______ minutes

**Overall comfort level:** ___/10

---

## 📝 Notes

Any other observations:

_________________________________________________
_________________________________________________
_________________________________________________

