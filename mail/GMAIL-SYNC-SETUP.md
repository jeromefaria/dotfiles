# Gmail Sync Setup Guide

This guide will help you set up offline Gmail sync with mbsync, enabling full notmuch search functionality in Neomutt.

## What This Gives You

- ✅ **Offline mail access** - Read and search mail without internet
- ✅ **Lightning-fast search** - Notmuch full-text search across all mail
- ✅ **Virtual mailboxes** - Smart folders (Today, This Week, Unread, etc.)
- ✅ **Better performance** - No IMAP latency
- ✅ **Privacy** - Mail stored locally, encrypted on disk

## Prerequisites

- ✅ mbsync/isync (already installed)
- ✅ notmuch (already installed)
- ✅ Gmail account: jerome.faria@gmail.com

## Setup Steps

### Step 1: Run the Setup Script

The easiest way to set everything up:

```bash
~/dotfiles/mail/scripts/setup-gmail-sync.sh
```

This script will:
1. Guide you through creating a Gmail app-specific password
2. Store it securely in macOS Keychain
3. Test the connection
4. Perform the initial mail sync
5. Index mail with notmuch

**Time estimate:** 10-30 minutes (depending on mail volume)

---

### Manual Setup (Alternative)

If you prefer to set things up manually:

#### 1. Create Gmail App-Specific Password

1. Go to: https://myaccount.google.com/apppasswords
2. Sign in to jerome.faria@gmail.com
3. Select app: **Mail**
4. Select device: **Mac**
5. Click **Generate**
6. Copy the 16-character password (format: xxxx xxxx xxxx xxxx)

#### 2. Store Password in macOS Keychain

```bash
security add-internet-password \
  -a "jerome.faria@gmail.com" \
  -s "imap.gmail.com" \
  -w "your-app-specific-password-here" \
  -r "imap" \
  -l "Gmail IMAP (jerome.faria@gmail.com)"
```

#### 3. Test Password Retrieval

```bash
~/dotfiles/mail/scripts/get-gmail-pass.sh
```

Should output your password (keep it secret!)

#### 4. Perform Initial Sync

```bash
# Sync all folders (this will take a while!)
mbsync -V gmail

# Or sync just inbox first to test
mbsync -V gmail-inbox
```

#### 5. Index with Notmuch

```bash
cd ~/.local/share/mail/gmail
notmuch new
```

---

## Using the Synced Mail

### Switch Neomutt to Use Local Mail

Edit `/Users/jeromefaria/dotfiles/mail/mutt/muttrc` and change the account line:

```muttrc
# OLD (IMAP):
# source $DOTFILES/mail/mutt/accounts/1-personal.muttrc

# NEW (Local Maildir):
source $DOTFILES/mail/mutt/accounts/1-personal-maildir.muttrc
```

Then reload neomutt or restart it.

### Regular Syncing

Run the sync script to update your mail:

```bash
~/dotfiles/mail/scripts/sync-mail.sh
```

**Recommended:** Set up automatic syncing every 15 minutes

#### Option 1: Cron (Simple)

```bash
crontab -e
# Add this line:
*/15 * * * * /Users/jeromefaria/dotfiles/mail/scripts/sync-mail.sh >> ~/.local/share/mail/sync.log 2>&1
```

#### Option 2: launchd (macOS Recommended)

Create `~/Library/LaunchAgents/com.jeromefaria.mailsync.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.jeromefaria.mailsync</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/jeromefaria/dotfiles/mail/scripts/sync-mail.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>900</integer>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
```

Then load it:

```bash
launchctl load ~/Library/LaunchAgents/com.jeromefaria.mailsync.plist
```

---

## Folder Structure

After sync, your mail will be organized as:

```
~/.local/share/mail/gmail/
├── INBOX/           # Your inbox
├── archive/         # All Mail (Gmail archive)
├── sent/            # Sent mail
├── drafts/          # Draft messages
├── spam/            # Spam folder
├── trash/           # Deleted messages
└── .notmuch/        # Notmuch database (search index)
```

---

## Troubleshooting

### "PassCmd exited with status 2"

Password not in Keychain. Run the setup script again or manually add the password.

### "No such mailbox"

The initial sync hasn't completed. Run `mbsync -V gmail` to sync all folders.

### Notmuch search not working

1. Check database path: `notmuch config get database.path`
   - Should be: `/Users/jeromefaria/.local/share/mail/gmail`
2. Reindex: `cd ~/.local/share/mail/gmail && notmuch new`

### Virtual mailboxes not appearing

1. Ensure notmuch integration is enabled in neomutt: `neomutt -v | grep notmuch`
2. Check that virtual mailboxes are defined in `~/dotfiles/mail/mutt/notmuch`
3. Try pressing `c` and typing "Search" to see available virtual folders

---

## Testing Everything Works

After setup, test these features in neomutt:

1. **Basic navigation:** Open neomutt - should show your inbox
2. **Virtual mailboxes:** Press `c`, type "Search: Today"
3. **Notmuch search:** Press `\`, type `from:example@gmail.com`
4. **FZF mailbox picker:** Press `gm` - should show all folders
5. **Read messages offline:** Disconnect WiFi, read mail (should work!)

---

## Reverting to IMAP (if needed)

If you want to go back to direct IMAP:

Edit `/Users/jeromefaria/dotfiles/mail/mutt/muttrc`:

```muttrc
# Restore IMAP account
source $DOTFILES/mail/mutt/accounts/1-personal.muttrc
```

Your IMAP config is backed up at:
`/Users/jeromefaria/dotfiles/mail/mutt/accounts/1-personal.muttrc.imap-backup`

---

## Next Steps

Once everything is working:

1. Set up automatic syncing (cron or launchd)
2. Try the virtual mailboxes (`c` → "Search: Today", "Search: Unread", etc.)
3. Test notmuch search (`\` → `subject:important date:today`)
4. Explore the command palette (`Space p`)
5. Enjoy lightning-fast offline mail! ⚡📬

