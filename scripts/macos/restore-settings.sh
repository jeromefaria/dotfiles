#!/usr/bin/env bash
#
# macOS Settings Restore Script
# Restores macOS defaults from a previous backup
#
# Usage: ./restore-settings.sh <backup-name>
#

set -e

# Configuration
BACKUP_DIR="${HOME}/.macos-backups"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check for backup name
if [ -z "$1" ]; then
    log_error "No backup name provided"
    echo ""
    echo "Usage: $0 <backup-name>"
    echo ""
    echo "Available backups:"
    if [ -d "${BACKUP_DIR}" ]; then
        ls -1 "${BACKUP_DIR}" | sed 's/^/  - /'
    else
        echo "  (none)"
    fi
    exit 1
fi

BACKUP_NAME="$1"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

# Check if backup exists
if [ ! -d "${BACKUP_PATH}" ]; then
    log_error "Backup '${BACKUP_NAME}' not found at ${BACKUP_PATH}"
    echo ""
    echo "Available backups:"
    if [ -d "${BACKUP_DIR}" ]; then
        ls -1 "${BACKUP_DIR}" | sed 's/^/  - /'
    else
        echo "  (none)"
    fi
    exit 1
fi

# Show backup information
if [ -f "${BACKUP_PATH}/system-info.txt" ]; then
    echo ""
    cat "${BACKUP_PATH}/system-info.txt"
    echo ""
fi

# Confirm restoration
echo -e "${YELLOW}WARNING:${NC} This will overwrite your current macOS settings."
echo "It is recommended to create a backup of your current settings first."
echo ""
read -p "Do you want to continue? (yes/no): " -r
echo ""
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    log_info "Restoration cancelled"
    exit 0
fi

log_info "Starting restoration from: ${BACKUP_PATH}"

# Ask for sudo password upfront
sudo -v

# Keep sudo alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Restore NSGlobalDomain
if [ -f "${BACKUP_PATH}/NSGlobalDomain.plist" ]; then
    log_info "Restoring NSGlobalDomain settings..."
    defaults import NSGlobalDomain "${BACKUP_PATH}/NSGlobalDomain.plist" 2>/dev/null || log_warning "Could not restore NSGlobalDomain"
fi

# Restore domain settings
if [ -d "${BACKUP_PATH}/domains" ]; then
    log_info "Restoring application domain settings..."
    for plist in "${BACKUP_PATH}/domains"/*.plist; do
        if [ -f "$plist" ]; then
            domain=$(basename "$plist" .plist)
            log_info "  - Restoring ${domain}..."
            defaults import "${domain}" "$plist" 2>/dev/null || log_warning "    Could not restore ${domain}"
        fi
    done
fi

# Restore currentHost settings
if [ -f "${BACKUP_PATH}/currentHost/NSGlobalDomain.plist" ]; then
    log_info "Restoring currentHost settings..."
    defaults -currentHost import NSGlobalDomain "${BACKUP_PATH}/currentHost/NSGlobalDomain.plist" 2>/dev/null || log_warning "Could not restore currentHost settings"
fi

# Restore Finder binary plist
if [ -f "${BACKUP_PATH}/com.apple.finder.binary.plist" ]; then
    log_info "Restoring Finder binary preferences..."
    cp "${BACKUP_PATH}/com.apple.finder.binary.plist" "${HOME}/Library/Preferences/com.apple.finder.plist" 2>/dev/null || log_warning "Could not restore Finder binary plist"
fi

# Restore system-level settings
if [ -d "${BACKUP_PATH}/system" ]; then
    log_info "Restoring system-level settings (requires sudo)..."

    # Firewall
    if [ -f "${BACKUP_PATH}/system/alf.plist" ]; then
        log_info "  - Restoring firewall settings..."
        sudo defaults import /Library/Preferences/com.apple.alf "${BACKUP_PATH}/system/alf.plist" 2>/dev/null || log_warning "    Could not restore firewall settings"
    fi

    # Login window
    if [ -f "${BACKUP_PATH}/system/loginwindow.plist" ]; then
        log_info "  - Restoring login window settings..."
        sudo defaults import /Library/Preferences/com.apple.loginwindow "${BACKUP_PATH}/system/loginwindow.plist" 2>/dev/null || log_warning "    Could not restore login window settings"
    fi

    # Spotlight
    if [ -f "${BACKUP_PATH}/system/spotlight-volume.plist" ]; then
        log_info "  - Restoring Spotlight settings..."
        sudo defaults import /.Spotlight-V100/VolumeConfiguration "${BACKUP_PATH}/system/spotlight-volume.plist" 2>/dev/null || log_warning "    Could not restore Spotlight settings"
    fi
fi

# Note about NVRAM and other settings
if [ -f "${BACKUP_PATH}/nvram.txt" ]; then
    log_warning "NVRAM settings found but not automatically restored"
    log_info "  Review ${BACKUP_PATH}/nvram.txt to manually restore if needed"
fi

if [ -f "${BACKUP_PATH}/systemsetup.txt" ]; then
    log_warning "System setup settings found but not automatically restored"
    log_info "  Review ${BACKUP_PATH}/systemsetup.txt to manually restore if needed"
fi

if [ -f "${BACKUP_PATH}/pmset.txt" ]; then
    log_warning "Power management settings found but not automatically restored"
    log_info "  Review ${BACKUP_PATH}/pmset.txt to manually restore if needed"
fi

# Kill affected applications to apply changes
log_info "Restarting affected applications..."
APPS_TO_KILL=(
    "Dock"
    "Finder"
    "SystemUIServer"
    "cfprefsd"
)

for app in "${APPS_TO_KILL[@]}"; do
    killall "${app}" >/dev/null 2>&1 || true
done

log_success "Restoration completed!"
echo ""
echo "Notes:"
echo "  - Some settings may require a logout or restart to take full effect"
echo "  - Review the backup directory for any settings that need manual restoration:"
echo "    ${BACKUP_PATH}"
echo ""
echo "Recommended next steps:"
echo "  1. Log out and log back in"
echo "  2. Verify your settings are correct"
echo "  3. Check ${BACKUP_PATH}/systemsetup.txt for any manual changes needed"
