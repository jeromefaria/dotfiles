#!/bin/bash
# Sync Gmail with mbsync and index with notmuch
# Run this periodically (e.g., every 15 minutes via cron or launchd)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# run_bounded: terminal-notifier waits on a Notification Center callback that
# never arrives without an Aqua session, and this runs every 15 minutes under
# launchd — unbounded, a headless login stacks up a hung process per sync.
# shellcheck source=../../scripts/lib/bounded.sh
source "${SCRIPT_DIR}/../../scripts/lib/bounded.sh"

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
  cd ~/.local/share/mail/gmail || exit
  new_count=$(notmuch new 2>&1 | grep -o '[0-9]\+ new' | grep -o '[0-9]\+')

  if [ -n "$new_count" ] && [ "$new_count" -gt 0 ]; then
    echo -e "${GREEN}✅ Indexed $new_count new message(s)${NC}"

    # Optional: Send notification (requires terminal-notifier)
    if command -v terminal-notifier &> /dev/null; then
      run_bounded 5 terminal-notifier -title "New Mail" \
        -message "$new_count new message(s)" -sound default
    fi
  else
    echo -e "${GREEN}✅ No new mail${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  Sync failed or timed out${NC}"
  exit 1
fi

echo -e "${BLUE}📭 Mail sync finished${NC}"
