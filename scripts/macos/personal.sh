#!/usr/bin/env bash
#
# macOS Personal Settings
# User-specific preferences and customizations
# Customize this file with your own preferences
#
# This script is part of a modular macOS configuration system.
# Run via the main macos-setup.sh script or standalone.
#

set -e

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source helper functions if available
if [ -f "${SCRIPT_DIR}/helpers.sh" ]; then
    source "${SCRIPT_DIR}/helpers.sh"
else
    # Fallback logging functions
    log_section() { echo ""; echo "==> $1"; }
    log_info() { echo "  - $1"; }
    log_success() { echo "✓ $1"; }
    log_warning() { echo "⚠ $1"; }
fi

log_section "Applying Personal macOS Settings"

###############################################################################
# Regional Settings
###############################################################################

log_section "Regional & Language Settings"

# Set language and measurement units
# Customize these based on your location
log_info "Setting measurement units to metric"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true

# Set the timezone
# See `sudo systemsetup -listtimezones` for other values
log_info "Setting timezone to Europe/Lisbon"
sudo systemsetup -settimezone "Europe/Lisbon" > /dev/null 2>&1 || log_warning "Could not set timezone (may require manual setting)"

###############################################################################
# Appearance Customizations
###############################################################################

log_section "Appearance"

# Set appearance mode (Dark, Light, or Auto)
# Uncomment one of the following:

# Dark mode
# log_info "Setting Dark mode"
# defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# Light mode (default)
log_info "Using Light mode (default)"
defaults delete NSGlobalDomain AppleInterfaceStyle 2>/dev/null || true

# Set accent color
# Colors: -1=Graphite, 0=Red, 1=Orange, 2=Yellow, 3=Green, 4=Blue (default), 5=Purple, 6=Pink
# Uncomment to set a custom accent color:
# log_info "Setting accent color"
# defaults write NSGlobalDomain AppleAccentColor -int 4

# Set highlight color
# Uncomment and customize as needed:
# log_info "Setting custom highlight color"
# defaults write NSGlobalDomain AppleHighlightColor -string "0.764700 0.976500 0.568600"

###############################################################################
# Computer Identification
###############################################################################

log_section "Computer Name"

# Set computer name (customize these)
# Uncomment and set your preferred computer name:
# COMPUTER_NAME="YourMacName"
# log_info "Setting computer name to ${COMPUTER_NAME}"
# sudo scutil --set ComputerName "${COMPUTER_NAME}"
# sudo scutil --set HostName "${COMPUTER_NAME}"
# sudo scutil --set LocalHostName "${COMPUTER_NAME}"
# sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "${COMPUTER_NAME}"

log_info "Computer name not changed (customize in personal.sh if desired)"

###############################################################################
# Menu Bar
###############################################################################

log_section "Menu Bar"

# Show battery percentage
log_info "Showing battery percentage in menu bar"
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

# Show date and time in menu bar
# Customize the format as desired
# log_info "Setting menu bar clock format"
# defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d  h:mm a"
# defaults write com.apple.menuextra.clock FlashDateSeparators -bool false
# defaults write com.apple.menuextra.clock IsAnalog -bool false

# Auto-hide menu bar
# Uncomment to enable:
# log_info "Auto-hiding menu bar"
# defaults write NSGlobalDomain _HIHideMenuBar -bool true

###############################################################################
# Dock Personalization
###############################################################################

log_section "Dock Personalization"

# You can customize the Dock size, position, etc. here
# Most Dock settings are in base.sh, but you can override them here

# Set Dock position (left, bottom, right)
# log_info "Setting Dock position to left"
# defaults write com.apple.dock orientation -string "left"

# Adjust Dock size (already set in base.sh to 36, override if desired)
# log_info "Setting custom Dock size"
# defaults write com.apple.dock tilesize -int 48

# Enable Dock magnification
# log_info "Enabling Dock magnification"
# defaults write com.apple.dock magnification -bool true
# defaults write com.apple.dock largesize -int 64

###############################################################################
# Finder Customizations
###############################################################################

log_section "Finder Personalization"

# Set default Finder location for new windows
# Values: PfDe (Desktop), PfHm (Home), PfLo (Other), PfAF (All Files)
log_info "Setting new Finder windows to open in Home"
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Customize Finder sidebar favorites
# This is best done manually through Finder preferences

###############################################################################
# Desktop & Screen Saver
###############################################################################

log_section "Desktop & Screen Saver"

# Set a custom wallpaper (customize path)
# log_info "Setting desktop wallpaper"
# osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/path/to/your/wallpaper.jpg"'

# Screen saver settings
# Set screen saver to start after X seconds (e.g., 600 = 10 minutes)
# log_info "Setting screen saver idle time"
# defaults -currentHost write com.apple.screensaver idleTime -int 600

###############################################################################
# Hot Corners
###############################################################################

log_section "Hot Corners"

# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# 13: Lock Screen

# Uncomment and customize as desired:
# log_info "Setting up hot corners"

# Top left screen corner → Mission Control
# defaults write com.apple.dock wvous-tl-corner -int 2
# defaults write com.apple.dock wvous-tl-modifier -int 0

# Top right screen corner → Desktop
# defaults write com.apple.dock wvous-tr-corner -int 4
# defaults write com.apple.dock wvous-tr-modifier -int 0

# Bottom left screen corner → Lock Screen
# defaults write com.apple.dock wvous-bl-corner -int 13
# defaults write com.apple.dock wvous-bl-modifier -int 0

# Bottom right screen corner → (none)
# defaults write com.apple.dock wvous-br-corner -int 0
# defaults write com.apple.dock wvous-br-modifier -int 0

log_info "Hot corners not configured (customize in personal.sh if desired)"

###############################################################################
# Trackpad & Mouse Customization
###############################################################################

log_section "Trackpad & Mouse"

# Tracking speed (0.0 to 3.0, higher is faster)
# log_info "Setting trackpad tracking speed"
# defaults write NSGlobalDomain com.apple.trackpad.scaling -float 1.5

# Mouse tracking speed
# log_info "Setting mouse tracking speed"
# defaults write NSGlobalDomain com.apple.mouse.scaling -float 2.5

# Enable/disable natural scrolling (already handled in base.sh)
# Uncomment to disable natural scrolling:
# log_info "Disabling natural scrolling"
# defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

###############################################################################
# Energy & Display
###############################################################################

log_section "Energy Settings"

# Display sleep time (in minutes)
# log_info "Setting display sleep to 15 minutes"
# sudo pmset -a displaysleep 15

# Computer sleep time (0 = never)
# log_info "Disabling computer sleep"
# sudo pmset -a sleep 0

# Wake for network access
# log_info "Enabling wake for network access"
# sudo pmset -a womp 1

###############################################################################
# Notification Settings
###############################################################################

log_section "Notifications"

# Disable Notification Center
# Uncomment to disable (not recommended for most users):
# log_info "Disabling Notification Center"
# launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2>/dev/null

###############################################################################
# Siri
###############################################################################

log_section "Siri"

# Disable Siri (uncomment if you don't use it)
# log_info "Disabling Siri"
# defaults write com.apple.assistant.support "Assistant Enabled" -bool false
# defaults write com.apple.Siri StatusMenuVisible -bool false

###############################################################################
# Handoff & Continuity
###############################################################################

log_section "Continuity Features"

# Disable Handoff (uncomment if you don't use it)
# log_info "Disabling Handoff"
# defaults write ~/Library/Preferences/ByHost/com.apple.coreservices.useractivityd.plist ActivityAdvertisingAllowed -bool false
# defaults write ~/Library/Preferences/ByHost/com.apple.coreservices.useractivityd.plist ActivityReceivingAllowed -bool false

###############################################################################
# Sound
###############################################################################

log_section "Sound Settings"

# Set system volume (0-100)
# log_info "Setting system volume to 50%"
# osascript -e 'set volume output volume 50'

# Set alert volume (0-100)
# log_info "Setting alert volume to 25%"
# osascript -e 'set volume alert volume 25'

# Disable startup chime (already done in base.sh)

###############################################################################
# Security Preferences
###############################################################################

log_section "Security & Privacy"

# Enable FileVault (disk encryption)
# Note: This is interactive and requires user authentication
# Uncomment to check FileVault status:
# if ! fdesetup status | grep -q "On"; then
#     log_warning "FileVault is not enabled. Consider enabling it in System Preferences > Security & Privacy"
# fi

# Enable Firewall
log_info "Enabling Firewall"
sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1 2>/dev/null || log_warning "Could not enable firewall"

# Enable stealth mode
log_info "Enabling Firewall stealth mode"
sudo defaults write /Library/Preferences/com.apple.alf stealthenabled -bool true 2>/dev/null || log_warning "Could not enable stealth mode"

# Disable guest account
log_info "Disabling guest account"
sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false 2>/dev/null || log_warning "Could not disable guest account"

# Disable remote apple events
log_info "Disabling remote apple events"
sudo systemsetup -setremoteappleevents off >/dev/null 2>&1 || log_warning "Could not disable remote apple events"

# Keep remote login (SSH) disabled by default
# Uncomment to check status:
# REMOTE_LOGIN=$(sudo systemsetup -getremotelogin 2>/dev/null | grep -i "on" || echo "off")
# if [[ "$REMOTE_LOGIN" =~ "on" ]]; then
#     log_warning "Remote login (SSH) is enabled. Disable it if not needed."
# fi

###############################################################################
# Custom Application Preferences
###############################################################################

log_section "Custom Application Settings"

# Add your own custom application settings here
# Examples:

# iTerm2 preferences location
# defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/dotfiles/config/iterm2"
# defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

# VSCode settings sync
# Configure in VSCode UI

log_info "Add your custom app preferences in personal.sh"

###############################################################################
# Cleanup
###############################################################################

log_section "Cleanup"

# Clean up Launchpad database
log_info "Resetting Launchpad"
find "${HOME}/Library/Application Support/Dock" -name "*-*.db" -maxdepth 1 -delete 2>/dev/null || true

log_success "Personal settings applied successfully!"
echo ""
echo "Customization tips:"
echo "  - Edit scripts/macos/personal.sh to add your own preferences"
echo "  - Uncomment sections you want to enable"
echo "  - Check System Preferences for additional manual settings"
echo "  - Some changes require a logout or restart to take effect"
