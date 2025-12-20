# Automatic Mail Sync Setup

Set up automatic background syncing of Gmail every 15 minutes using macOS launchd.

## Quick Start

### Enable Auto-Sync

```bash
~/dotfiles/mail/scripts/manage-sync.sh start
```

That's it! Your mail will now sync automatically every 15 minutes.

---

## Management Commands

```bash
# Enable automatic sync
~/dotfiles/mail/scripts/manage-sync.sh start

# Disable automatic sync
~/dotfiles/mail/scripts/manage-sync.sh stop

# Restart the service
~/dotfiles/mail/scripts/manage-sync.sh restart

# Check if it's running
~/dotfiles/mail/scripts/manage-sync.sh status

# View sync logs
~/dotfiles/mail/scripts/manage-sync.sh logs

# Run sync manually right now
~/dotfiles/mail/scripts/manage-sync.sh now
```

---

## How It Works

**Technology:** Uses macOS launchd (superior to cron on Mac)

**Frequency:** Every 15 minutes (900 seconds)

**What it does:**
1. Syncs mail with `mbsync gmail`
2. Indexes new mail with `notmuch new`
3. Logs activity to `~/.local/share/mail/sync.log`

**Benefits:**
- ✅ Runs even when you're not logged in
- ✅ Survives reboots (auto-starts)
- ✅ Native macOS service management
- ✅ Automatic error logging

---

## Verify It's Working

### Method 1: Check Status

```bash
~/dotfiles/mail/scripts/manage-sync.sh status
```

Should show:
```
Mail sync service status:
✅ Running

Last run info:
📬 Starting mail sync...
Syncing with Gmail...
✅ Sync complete
Indexing new mail...
✅ Indexed 5 new message(s)
📭 Mail sync finished
```

### Method 2: Watch Logs Live

```bash
tail -f ~/.local/share/mail/sync.log
```

Wait 15 minutes and you'll see sync activity appear.

### Method 3: Check launchd Directly

```bash
launchctl list | grep mailsync
```

Should show the service running.

---

## Customization

### Change Sync Frequency

Edit the plist file:

```bash
vim ~/Library/LaunchAgents/com.jeromefaria.mailsync.plist
```

Change this line:
```xml
<key>StartInterval</key>
<integer>900</integer>  <!-- 900 seconds = 15 minutes -->
```

Options:
- `300` = 5 minutes
- `600` = 10 minutes
- `900` = 15 minutes (recommended)
- `1800` = 30 minutes
- `3600` = 1 hour

Then restart:
```bash
~/dotfiles/mail/scripts/manage-sync.sh restart
```

---

## Troubleshooting

### Service won't start

**Check plist is valid:**
```bash
plutil -lint ~/Library/LaunchAgents/com.jeromefaria.mailsync.plist
```

**Check script exists:**
```bash
ls -la ~/dotfiles/mail/scripts/sync-mail.sh
```

**Check permissions:**
```bash
chmod +x ~/dotfiles/mail/scripts/sync-mail.sh
```

### No new mail syncing

**Check error logs:**
```bash
cat ~/.local/share/mail/sync-error.log
```

**Test sync manually:**
```bash
~/dotfiles/mail/scripts/manage-sync.sh now
```

**Check mbsync config:**
```bash
mbsync -V gmail-inbox
```

### Service keeps crashing

**Check password in Keychain:**
```bash
~/dotfiles/mail/scripts/get-gmail-pass.sh
```

**Verify network access:**
```bash
ping -c 3 imap.gmail.com
```

**Check logs for errors:**
```bash
~/dotfiles/mail/scripts/manage-sync.sh logs
```

---

## Disable Temporarily

If you need to disable sync temporarily (e.g., traveling with limited bandwidth):

```bash
# Stop automatic sync
~/dotfiles/mail/scripts/manage-sync.sh stop

# Later, re-enable
~/dotfiles/mail/scripts/manage-sync.sh start
```

---

## Alternative: Cron (if you prefer)

If you prefer cron over launchd:

```bash
# Edit crontab
crontab -e

# Add this line:
*/15 * * * * /Users/jeromefaria/dotfiles/mail/scripts/sync-mail.sh >> ~/.local/share/mail/sync.log 2>&1
```

**Note:** launchd is recommended on macOS because:
- Works when you're not logged in
- Survives reboots
- Better error handling
- Native macOS integration

---

## Monitoring

### Desktop Notifications

Install terminal-notifier for new mail alerts:

```bash
brew install terminal-notifier
```

The sync script will automatically use it to notify you of new mail.

### Check Sync History

```bash
# Last 50 lines
tail -50 ~/.local/share/mail/sync.log

# Follow in real-time
tail -f ~/.local/share/mail/sync.log

# Search for errors
grep -i error ~/.local/share/mail/sync.log
```

---

## Files Created

```
~/Library/LaunchAgents/com.jeromefaria.mailsync.plist  # launchd config
~/dotfiles/mail/scripts/manage-sync.sh                 # Management tool
~/dotfiles/mail/scripts/sync-mail.sh                   # Sync script
~/.local/share/mail/sync.log                           # Activity log
~/.local/share/mail/sync-error.log                     # Error log
```

---

## Uninstall

To completely remove automatic sync:

```bash
# Stop and unload service
~/dotfiles/mail/scripts/manage-sync.sh stop

# Remove launchd plist
rm ~/Library/LaunchAgents/com.jeromefaria.mailsync.plist

# Optional: Remove logs
rm ~/.local/share/mail/sync*.log
```

---

## Summary

**Enable auto-sync:**
```bash
~/dotfiles/mail/scripts/manage-sync.sh start
```

**Check it's working:**
```bash
~/dotfiles/mail/scripts/manage-sync.sh status
```

**View activity:**
```bash
~/dotfiles/mail/scripts/manage-sync.sh logs
```

That's it! Your mail stays in sync automatically. 📬✨
