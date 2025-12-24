#!/usr/bin/env bash
#
# macOS Settings Backup Script
# Backs up current macOS defaults to enable restoration later
#
# Usage: ./backup-settings.sh [backup-name]
#

set -e

# Configuration
BACKUP_DIR="${HOME}/.macos-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="${1:-backup_${TIMESTAMP}}"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

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

# Create backup directory
mkdir -p "${BACKUP_PATH}"

log_info "Starting macOS settings backup..."
log_info "Backup location: ${BACKUP_PATH}"

# Backup system information
log_info "Backing up system information..."
cat > "${BACKUP_PATH}/system-info.txt" << EOF
Backup Date: $(date)
System: $(sw_vers -productName)
Version: $(sw_vers -productVersion)
Build: $(sw_vers -buildVersion)
Hardware: $(sysctl -n hw.model)
Hostname: $(hostname)
EOF

# Backup Global Domain settings
log_info "Backing up NSGlobalDomain settings..."
defaults read NSGlobalDomain > "${BACKUP_PATH}/NSGlobalDomain.plist" 2>/dev/null || log_warning "Could not backup NSGlobalDomain"

# Backup common domain settings
DOMAINS=(
    "com.apple.dock"
    "com.apple.finder"
    "com.apple.Safari"
    "com.apple.Mail"
    "com.apple.screencapture"
    "com.apple.screensaver"
    "com.apple.terminal"
    "com.apple.TextEdit"
    "com.apple.ActivityMonitor"
    "com.apple.dashboard"
    "com.apple.spotlight"
    "com.apple.TimeMachine"
    "com.apple.messageshelper.MessageController"
    "com.apple.LaunchServices"
    "com.apple.universalaccess"
    "com.apple.BluetoothAudioAgent"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad"
    "com.apple.print.PrintingPrefs"
    "com.apple.desktopservices"
    "com.apple.frameworks.diskimages"
    "com.apple.NetworkBrowser"
    "com.apple.SoftwareUpdate"
    "com.apple.commerce"
    "com.apple.AppStore"
    "com.apple.controlcenter"
    "com.apple.menuextra.clock"
    "com.apple.menuextra.battery"
    "com.apple.spaces"
    "com.google.Chrome"
    "com.google.Chrome.canary"
    "com.operasoftware.Opera"
    "com.operasoftware.OperaDeveloper"
    "org.m0k.transmission"
)

mkdir -p "${BACKUP_PATH}/domains"
for domain in "${DOMAINS[@]}"; do
    if defaults read "${domain}" >/dev/null 2>&1; then
        log_info "Backing up ${domain}..."
        defaults read "${domain}" > "${BACKUP_PATH}/domains/${domain}.plist" 2>/dev/null
    fi
done

# Backup currentHost settings
log_info "Backing up currentHost settings..."
mkdir -p "${BACKUP_PATH}/currentHost"
defaults -currentHost read NSGlobalDomain > "${BACKUP_PATH}/currentHost/NSGlobalDomain.plist" 2>/dev/null || log_warning "Could not backup currentHost NSGlobalDomain"

# Backup Finder preferences (binary plist)
log_info "Backing up Finder preferences..."
if [ -f "${HOME}/Library/Preferences/com.apple.finder.plist" ]; then
    cp "${HOME}/Library/Preferences/com.apple.finder.plist" "${BACKUP_PATH}/com.apple.finder.binary.plist"
fi

# Backup system-level settings (requires sudo)
log_info "Backing up system-level settings..."
mkdir -p "${BACKUP_PATH}/system"

# Firewall settings
if sudo defaults read /Library/Preferences/com.apple.alf >/dev/null 2>&1; then
    sudo defaults read /Library/Preferences/com.apple.alf > "${BACKUP_PATH}/system/alf.plist" 2>/dev/null || log_warning "Could not backup firewall settings"
fi

# Login window settings
if sudo defaults read /Library/Preferences/com.apple.loginwindow >/dev/null 2>&1; then
    sudo defaults read /Library/Preferences/com.apple.loginwindow > "${BACKUP_PATH}/system/loginwindow.plist" 2>/dev/null || log_warning "Could not backup login window settings"
fi

# Spotlight settings
if sudo defaults read /.Spotlight-V100/VolumeConfiguration >/dev/null 2>&1; then
    sudo defaults read /.Spotlight-V100/VolumeConfiguration > "${BACKUP_PATH}/system/spotlight-volume.plist" 2>/dev/null || log_warning "Could not backup Spotlight settings"
fi

# Backup NVRAM settings
log_info "Backing up NVRAM settings..."
nvram -p > "${BACKUP_PATH}/nvram.txt" 2>/dev/null || log_warning "Could not backup NVRAM"

# Backup pmset (power management) settings
log_info "Backing up power management settings..."
pmset -g > "${BACKUP_PATH}/pmset.txt" 2>/dev/null || log_warning "Could not backup power settings"

# Backup system setup settings
log_info "Backing up system setup settings..."
{
    echo "=== Timezone ==="
    systemsetup -gettimezone 2>/dev/null
    echo ""
    echo "=== Computer Name ==="
    scutil --get ComputerName 2>/dev/null
    echo ""
    echo "=== Host Name ==="
    scutil --get HostName 2>/dev/null
    echo ""
    echo "=== Local Host Name ==="
    scutil --get LocalHostName 2>/dev/null
    echo ""
    echo "=== Restart on Freeze ==="
    systemsetup -getrestartfreeze 2>/dev/null
    echo ""
    echo "=== Remote Login ==="
    systemsetup -getremotelogin 2>/dev/null
    echo ""
    echo "=== Remote Apple Events ==="
    systemsetup -getremoteappleevents 2>/dev/null
} > "${BACKUP_PATH}/systemsetup.txt" 2>/dev/null || log_warning "Could not backup some system settings"

# Create a manifest of what was backed up
log_info "Creating backup manifest..."
cat > "${BACKUP_PATH}/MANIFEST.txt" << EOF
macOS Settings Backup Manifest
==============================

Backup Name: ${BACKUP_NAME}
Created: $(date)
System Version: $(sw_vers -productVersion)

Contents:
---------
- system-info.txt: System information and version details
- NSGlobalDomain.plist: Global user defaults
- domains/: Individual application domain settings
- currentHost/: Host-specific settings
- system/: System-level settings (requires sudo to restore)
- nvram.txt: NVRAM boot parameters
- pmset.txt: Power management settings
- systemsetup.txt: System setup configuration

To restore this backup:
  ./restore-settings.sh ${BACKUP_NAME}

Notes:
------
- Some settings may require logout/restart to take effect after restoration
- System-level settings require sudo privileges to restore
- Third-party application settings are backed up if present
EOF

# Create a summary
DOMAIN_COUNT=$(ls -1 "${BACKUP_PATH}/domains" 2>/dev/null | wc -l | tr -d ' ')
BACKUP_SIZE=$(du -sh "${BACKUP_PATH}" | cut -f1)

log_success "Backup completed successfully!"
echo ""
echo "Backup Summary:"
echo "  Location: ${BACKUP_PATH}"
echo "  Size: ${BACKUP_SIZE}"
echo "  Domains backed up: ${DOMAIN_COUNT}"
echo ""
echo "To restore this backup, run:"
echo "  ./restore-settings.sh ${BACKUP_NAME}"
echo ""
echo "To list all backups, run:"
echo "  ls -lh ${BACKUP_DIR}"
