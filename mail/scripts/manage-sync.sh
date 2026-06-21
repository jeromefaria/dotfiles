#!/bin/bash
# Manage automatic mail sync service (launchd)

PLIST="$HOME/Library/LaunchAgents/com.jeromefaria.mailsync.plist"
SERVICE="com.jeromefaria.mailsync"

# Shared TTY-aware colors + launchd service primitives
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../scripts" && pwd)/lib"
source "${LIB_DIR}/io.sh"
source "${LIB_DIR}/launchd-svc.sh"

case "$1" in
  start)
    echo -e "${BLUE}Starting mail sync service...${NC}"
    if svc_start "$PLIST" "$SERVICE"; then
      echo -e "${GREEN}✅ Service started successfully${NC}"
      echo -e "${YELLOW}Mail will sync every 15 minutes${NC}"
    else
      echo -e "${RED}❌ Failed to start service${NC}"
      exit 1
    fi
    ;;

  stop)
    echo -e "${BLUE}Stopping mail sync service...${NC}"
    if svc_stop "$PLIST" "$SERVICE"; then
      echo -e "${GREEN}✅ Service stopped${NC}"
    else
      echo -e "${RED}❌ Failed to stop service${NC}"
      exit 1
    fi
    ;;

  restart)
    echo -e "${BLUE}Restarting mail sync service...${NC}"
    if svc_restart "$PLIST" "$SERVICE"; then
      echo -e "${GREEN}✅ Service restarted${NC}"
    else
      echo -e "${RED}❌ Failed to restart service${NC}"
      exit 1
    fi
    ;;

  status)
    echo -e "${BLUE}Mail sync service status:${NC}"
    if svc_is_loaded "$SERVICE"; then
      echo -e "${GREEN}✅ Running${NC}"
      echo ""
      echo "Last run info:"
      if [ -f "$HOME/.local/share/mail/sync.log" ]; then
        tail -15 "$HOME/.local/share/mail/sync.log"
      else
        echo "No logs yet"
      fi
    else
      echo -e "${YELLOW}⚪ Stopped${NC}"
    fi
    ;;

  logs)
    echo -e "${BLUE}Recent sync logs (last 30 lines):${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [ -f "$HOME/.local/share/mail/sync.log" ]; then
      tail -30 "$HOME/.local/share/mail/sync.log"
    else
      echo "No logs found"
    fi

    if [ -f "$HOME/.local/share/mail/sync-error.log" ]; then
      echo ""
      echo -e "${RED}Errors (if any):${NC}"
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      tail -10 "$HOME/.local/share/mail/sync-error.log"
    fi
    ;;

  now)
    echo -e "${BLUE}Running sync manually...${NC}"
    "${DOTFILES:-$HOME/dotfiles}/mail/scripts/sync-mail.sh"
    ;;

  *)
    echo "Usage: $0 {start|stop|restart|status|logs|now}"
    echo ""
    echo "Commands:"
    echo "  start   - Enable automatic sync every 15 minutes"
    echo "  stop    - Disable automatic sync"
    echo "  restart - Restart the sync service"
    echo "  status  - Show service status and recent activity"
    echo "  logs    - View sync logs"
    echo "  now     - Run sync manually right now"
    exit 1
    ;;
esac
