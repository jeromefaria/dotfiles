#!/bin/bash
# Sync Gmail with mbsync and index with notmuch
# Run this periodically (e.g., every 15 minutes via cron or launchd)

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}📬 Starting mail sync...${NC}"

# Sync mail with mbsync
echo -e "${YELLOW}Syncing with Gmail...${NC}"
if mbsync -q gmail 2>&1; then
  echo -e "${GREEN}✅ Sync complete${NC}"

  # Index new mail with notmuch
  echo -e "${YELLOW}Indexing new mail...${NC}"
  cd ~/.local/share/mail/gmail
  new_count=$(notmuch new 2>&1 | grep -o '[0-9]\+ new' | grep -o '[0-9]\+')

  if [ -n "$new_count" ] && [ "$new_count" -gt 0 ]; then
    echo -e "${GREEN}✅ Indexed $new_count new message(s)${NC}"

    # Optional: Send notification (requires terminal-notifier)
    if command -v terminal-notifier &> /dev/null; then
      terminal-notifier -title "New Mail" -message "$new_count new message(s)" -sound default
    fi
  else
    echo -e "${GREEN}✅ No new mail${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  Sync failed or timed out${NC}"
  exit 1
fi

echo -e "${BLUE}📭 Mail sync finished${NC}"
