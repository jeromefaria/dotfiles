#!/bin/bash
# ============================================================================
# scripts/tm-backup-manage.sh — TM staleness monitor lifecycle
# ============================================================================
# Manages the launchd agent that fires tm-backup-staleness-check.sh daily.
# Doesn't wrap `tmutil` or tm-fast-backup — those already have first-party
# and per-script UIs. This lives specifically to install/manage the
# "notify me when TM goes silent" watchdog.
#
# Usage:
#   tm-backup install      Emit the plist and load it into launchd
#   tm-backup uninstall    Unload and delete the plist
#   tm-backup status       Show service state + last check result
#   tm-backup check        Run the check now (notifies if stale)
#   tm-backup verify       Same as check but exits non-zero on stale, no notify
#   tm-backup logs         Tail the staleness-check log
# ============================================================================

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${TM_BACKUP_CONFIG:-${SCRIPT_DIR}/tm-backup.conf}"
CHECK_SCRIPT="${SCRIPT_DIR}/tm-backup-staleness-check.sh"

# shellcheck source=lib/io.sh
source "${SCRIPT_DIR}/lib/io.sh"
# shellcheck source=lib/launchd-svc.sh
source "${SCRIPT_DIR}/lib/launchd-svc.sh"
# shellcheck disable=SC1090
[ -f "$CONFIG" ] && source "$CONFIG"

LABEL="${TM_STALENESS_LAUNCHD_LABEL:-com.jeromefaria.tmbackupstaleness}"
PLIST="${HOME}/Library/LaunchAgents/${LABEL}.plist"
LOG_DIR="${TM_STALENESS_LOG_DIR:-${HOME}/Library/Logs/tm-backup}"
HOUR="${TM_STALENESS_SCHEDULE_HOUR:-9}"
MINUTE="${TM_STALENESS_SCHEDULE_MINUTE:-0}"

emit_plist() {
  mkdir -p "$(dirname "$PLIST")" "$LOG_DIR"
  cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${LABEL}</string>

  <key>ProgramArguments</key>
  <array>
    <string>${CHECK_SCRIPT}</string>
  </array>

  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key>
    <integer>${HOUR}</integer>
    <key>Minute</key>
    <integer>${MINUTE}</integer>
  </dict>

  <key>RunAtLoad</key>
  <false/>

  <key>StandardOutPath</key>
  <string>${LOG_DIR}/launchd.out.log</string>
  <key>StandardErrorPath</key>
  <string>${LOG_DIR}/launchd.err.log</string>

  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
  </dict>
</dict>
</plist>
EOF
}

cmd_install() {
  print_step "Emitting plist at ${PLIST}"
  emit_plist
  print_step "Loading into launchd"
  if svc_start "$PLIST" "$LABEL"; then
    print_success "Installed. Daily check at $(printf '%02d:%02d' "$HOUR" "$MINUTE") local time."
  else
    print_error "Failed to load. Check ${LOG_DIR}/launchd.err.log"
    exit 1
  fi
}

cmd_uninstall() {
  if [ ! -f "$PLIST" ]; then
    print_info "Not installed (no plist at ${PLIST})"
    return 0
  fi
  print_step "Unloading from launchd"
  svc_stop "$PLIST" "$LABEL" || true
  print_step "Removing plist"
  rm -f "$PLIST"
  print_success "Uninstalled."
}

cmd_status() {
  print_header "TM Backup Staleness Monitor"
  if [ -f "$PLIST" ]; then
    print_success "Plist installed: ${PLIST}"
  else
    print_warning "Plist not installed. Run: tm-backup install"
    return 0
  fi
  if svc_is_loaded "$LABEL"; then
    print_success "Service loaded — daily at $(printf '%02d:%02d' "$HOUR" "$MINUTE") local time"
  else
    print_warning "Service not loaded. Run: tm-backup install"
  fi
  echo
  print_info "Threshold: ${TM_STALE_ALERT_HOURS:-48}h  |  Cooldown: ${TM_STALE_NOTIFY_COOLDOWN_HOURS:-12}h"
  echo
  if [ -f "$LOG_DIR/staleness-check.log" ]; then
    print_info "Recent check log (last 5 lines):"
    tail -n 5 "$LOG_DIR/staleness-check.log"
  else
    print_info "No check log yet."
  fi
}

cmd_check()  { "$CHECK_SCRIPT"; }
cmd_verify() { "$CHECK_SCRIPT" --check; }

cmd_logs() {
  local f="$LOG_DIR/staleness-check.log"
  if [ ! -f "$f" ]; then
    print_info "No log yet at ${f}"
    exit 0
  fi
  tail -n 40 "$f"
}

case "${1:-status}" in
  install)   cmd_install ;;
  uninstall) cmd_uninstall ;;
  status)    cmd_status ;;
  check)     cmd_check ;;
  verify)    cmd_verify ;;
  logs)      cmd_logs ;;
  *)
    print_error "Unknown command: ${1:-}"
    echo "Usage: tm-backup {install|uninstall|status|check|verify|logs}"
    exit 1
    ;;
esac
