#!/usr/bin/env bash
#
# macOS Base Settings
# Core system settings that improve the default macOS experience
# These are opinionated but generally useful for most users
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
fi

log_section "Applying Base macOS Settings"

###############################################################################
# General UI/UX
###############################################################################

log_section "General UI/UX"

# Disable the sound effects on boot
log_info "Disabling boot sound"
sudo nvram SystemAudioVolume=" "

# Always show scrollbars
log_info "Setting scroll bars to always show"
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Increase window resize speed for Cocoa applications
log_info "Increasing window resize speed"
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Expand save panel by default
log_info "Expanding save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
log_info "Expanding print panel by default"
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Save to disk (not to iCloud) by default
log_info "Setting default save location to disk (not iCloud)"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Automatically quit printer app once the print jobs complete
log_info "Auto-quitting printer app when jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Disable the "Are you sure you want to open this application?" dialog
log_info "Disabling quarantine warning for applications"
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Display ASCII control characters using caret notation in standard text views
log_info "Showing ASCII control characters"
defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

# Disable Resume system-wide
log_info "Disabling Resume system-wide"
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

# Disable automatic termination of inactive apps
log_info "Disabling automatic termination of inactive apps"
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# Set Help Viewer windows to non-floating mode
log_info "Setting Help Viewer to non-floating mode"
defaults write com.apple.helpviewer DevMode -bool true

# Reveal IP address, hostname, OS version, etc. when clicking the clock in login window
log_info "Showing system info in login window clock"
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Restart automatically if the computer freezes
log_info "Enabling auto-restart on system freeze"
sudo systemsetup -setrestartfreeze on >/dev/null 2>&1

# Check for software updates daily, not just once per week
log_info "Setting software update check to daily"
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Disable smart quotes as they're annoying when typing code
log_info "Disabling smart quotes"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable smart dashes as they're annoying when typing code
log_info "Disabling smart dashes"
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution
log_info "Disabling automatic period substitution"
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable automatic capitalization
log_info "Disabling automatic capitalization"
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

###############################################################################
# Trackpad, Mouse, Keyboard, Bluetooth accessories, and input
###############################################################################

log_section "Keyboard & Input"

# Trackpad: enable tap to click for this user and for the login screen
log_info "Enabling tap to click"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Trackpad: map bottom right corner to right-click
log_info "Enabling trackpad right-click"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

# Increase sound quality for Bluetooth headphones/headsets
log_info "Increasing Bluetooth audio quality"
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Max (editable)" -int 80

# Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
log_info "Enabling full keyboard access"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Use scroll gesture with the Ctrl (^) modifier key to zoom
log_info "Enabling scroll-to-zoom with Ctrl"
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

# Disable press-and-hold for keys in favor of key repeat
log_info "Disabling press-and-hold for key repeat"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set a fast keyboard repeat rate
log_info "Setting fast keyboard repeat rate"
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable auto-correct
log_info "Disabling auto-correct"
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

###############################################################################
# Screen
###############################################################################

log_section "Screen & Screenshots"

# Require password immediately after sleep or screen saver begins
log_info "Requiring password after sleep/screensaver"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Create Screenshots directory if it doesn't exist
SCREENSHOT_DIR="${HOME}/Pictures/Screenshots"
if [ ! -d "$SCREENSHOT_DIR" ]; then
    log_info "Creating Screenshots directory"
    mkdir -p "$SCREENSHOT_DIR"
fi

# Save screenshots to the Screenshots folder
log_info "Setting screenshot location to ~/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$SCREENSHOT_DIR"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
log_info "Setting screenshot format to PNG"
defaults write com.apple.screencapture type -string "png"

# Disable screenshot thumbnail preview (macOS Mojave+)
log_info "Disabling screenshot thumbnail preview"
defaults write com.apple.screencapture show-thumbnail -bool false

# Enable subpixel font rendering on non-Apple LCDs (0-3, 2 is good for most)
log_info "Enabling subpixel font rendering"
defaults write NSGlobalDomain AppleFontSmoothing -int 2

###############################################################################
# Finder
###############################################################################

log_section "Finder"

# Show icons for hard drives, servers, and removable media on the desktop
log_info "Showing desktop icons for drives and media"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Finder: show all filename extensions
log_info "Showing all filename extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show status bar
log_info "Showing Finder status bar"
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
log_info "Showing Finder path bar"
defaults write com.apple.finder ShowPathbar -bool true

# Display full POSIX path as Finder window title
log_info "Showing full POSIX path in Finder title"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Keep folders on top when sorting by name
log_info "Keeping folders on top in Finder"
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder _FXSortFoldersFirstOnDesktop -bool true

# When performing a search, search the current folder by default
log_info "Setting Finder search scope to current folder"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
log_info "Disabling file extension change warning"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Enable spring loading for directories
log_info "Enabling spring loading for directories"
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# Remove the spring loading delay for directories
log_info "Removing spring loading delay"
defaults write NSGlobalDomain com.apple.springing.delay -float 0

# Avoid creating .DS_Store files on network or USB volumes
log_info "Preventing .DS_Store on network/USB volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Disable disk image verification
log_info "Disabling disk image verification"
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Use list view in all Finder windows by default
log_info "Setting Finder default view to list"
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Disable the warning before emptying the Trash
log_info "Disabling Trash warning"
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Show the ~/Library folder
log_info "Showing ~/Library folder"
chflags nohidden ~/Library

# Show the /Volumes folder
log_info "Showing /Volumes folder"
sudo chflags nohidden /Volumes 2>/dev/null || true

# Expand File Info panes: "General", "Open with", and "Sharing & Permissions"
log_info "Expanding Finder Info panes"
defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true

###############################################################################
# Dock, Dashboard, and Mission Control
###############################################################################

log_section "Dock & Mission Control"

# Set the icon size of Dock items
log_info "Setting Dock icon size to 36 pixels"
defaults write com.apple.dock tilesize -int 36

# Change minimize/maximize window effect to scale
log_info "Setting minimize effect to scale"
defaults write com.apple.dock mineffect -string "scale"

# Minimize windows into their application's icon
log_info "Minimizing windows into app icon"
defaults write com.apple.dock minimize-to-application -bool true

# Show indicator lights for open applications in the Dock
log_info "Showing app indicators in Dock"
defaults write com.apple.dock show-process-indicators -bool true

# Don't animate opening applications from the Dock
log_info "Disabling Dock launch animation"
defaults write com.apple.dock launchanim -bool false

# Speed up Mission Control animations
log_info "Speeding up Mission Control animations"
defaults write com.apple.dock expose-animation-duration -float 0.1

# Don't automatically rearrange Spaces based on most recent use
log_info "Disabling automatic Space rearrangement"
defaults write com.apple.dock mru-spaces -bool false

# Remove the auto-hiding Dock delay
log_info "Removing Dock auto-hide delay"
defaults write com.apple.dock autohide-delay -float 0

# Automatically hide and show the Dock
log_info "Enabling Dock auto-hide"
defaults write com.apple.dock autohide -bool true

# Make Dock icons of hidden applications translucent
log_info "Making hidden app icons translucent"
defaults write com.apple.dock showhidden -bool true

# Don't show recent applications in Dock
log_info "Hiding recent applications in Dock"
defaults write com.apple.dock show-recents -bool false

# Disable Dashboard
log_info "Disabling Dashboard"
defaults write com.apple.dashboard mcx-disabled -bool true

###############################################################################
# Spotlight
###############################################################################

log_section "Spotlight"

# Disable Spotlight indexing for mounted volumes
log_info "Configuring Spotlight exclusions"
sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes" 2>/dev/null || true

# Change indexing order and disable some search results
log_info "Configuring Spotlight categories"
defaults write com.apple.spotlight orderedItems -array \
    '{"enabled" = 1;"name" = "APPLICATIONS";}' \
    '{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
    '{"enabled" = 1;"name" = "DIRECTORIES";}' \
    '{"enabled" = 1;"name" = "PDF";}' \
    '{"enabled" = 1;"name" = "FONTS";}' \
    '{"enabled" = 0;"name" = "DOCUMENTS";}' \
    '{"enabled" = 0;"name" = "MESSAGES";}' \
    '{"enabled" = 0;"name" = "CONTACT";}' \
    '{"enabled" = 0;"name" = "EVENT_TODO";}' \
    '{"enabled" = 0;"name" = "IMAGES";}' \
    '{"enabled" = 0;"name" = "BOOKMARKS";}' \
    '{"enabled" = 0;"name" = "MUSIC";}' \
    '{"enabled" = 0;"name" = "MOVIES";}' \
    '{"enabled" = 0;"name" = "PRESENTATIONS";}' \
    '{"enabled" = 0;"name" = "SPREADSHEETS";}' \
    '{"enabled" = 0;"name" = "SOURCE";}' \
    '{"enabled" = 0;"name" = "MENU_DEFINITION";}' \
    '{"enabled" = 0;"name" = "MENU_OTHER";}' \
    '{"enabled" = 0;"name" = "MENU_CONVERSION";}' \
    '{"enabled" = 0;"name" = "MENU_EXPRESSION";}' \
    '{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
    '{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'

# Rebuild Spotlight index
log_info "Reloading Spotlight settings"
killall mds > /dev/null 2>&1 || true
sudo mdutil -i on / > /dev/null 2>&1 || true

###############################################################################
# Terminal
###############################################################################

log_section "Terminal"

# Only use UTF-8 in Terminal.app
log_info "Setting Terminal to UTF-8"
defaults write com.apple.terminal StringEncodings -array 4

###############################################################################
# Time Machine
###############################################################################

log_section "Time Machine"

# Prevent Time Machine from prompting to use new hard drives as backup volume
log_info "Preventing Time Machine new disk prompts"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

###############################################################################
# Activity Monitor
###############################################################################

log_section "Activity Monitor"

# Show the main window when launching Activity Monitor
log_info "Showing Activity Monitor main window on launch"
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Visualize CPU usage in the Activity Monitor Dock icon
log_info "Setting Activity Monitor Dock icon to CPU usage"
defaults write com.apple.ActivityMonitor IconType -int 5

# Show all processes in Activity Monitor
log_info "Showing all processes in Activity Monitor"
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort Activity Monitor results by CPU usage
log_info "Sorting Activity Monitor by CPU usage"
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

###############################################################################
# TextEdit
###############################################################################

log_section "TextEdit"

# Use plain text mode for new TextEdit documents
log_info "Setting TextEdit to plain text mode"
defaults write com.apple.TextEdit RichText -int 0

# Open and save files as UTF-8 in TextEdit
log_info "Setting TextEdit encoding to UTF-8"
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

###############################################################################
# Disk Utility
###############################################################################

log_section "Disk Utility"

# Enable the debug menu in Disk Utility
log_info "Enabling Disk Utility debug menu"
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true

log_success "Base settings applied successfully!"
