#!/usr/bin/env bash
#
# macOS Settings Export Script
# Exports current macOS settings in a human-readable format
# Useful for documentation and understanding what's currently configured
#
# Usage: ./export-settings.sh [output-file]
#

# Configuration
OUTPUT_FILE="${1:-macos-settings-export.txt}"

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Helper function to safely read defaults
read_default() {
    local domain="$1"
    local key="$2"
    local default_value="${3:-(not set)}"

    defaults read "$domain" "$key" 2>/dev/null || echo "$default_value"
}

log_info "Exporting macOS settings to: ${OUTPUT_FILE}"

# Start export
{
cat << 'EOF'
================================================================================
macOS Settings Export
================================================================================
EOF

echo "Generated: $(date)"
echo "System: $(sw_vers -productName) $(sw_vers -productVersion) ($(sw_vers -buildVersion))"
echo "Hostname: $(hostname)"
echo "User: $(whoami)"
echo ""

cat << 'EOF'
================================================================================
SYSTEM INFORMATION
================================================================================
EOF

echo "Hardware Model: $(sysctl -n hw.model)"
echo "Processor: $(sysctl -n machdep.cpu.brand_string)"
echo "Memory: $(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 )) GB"
echo "Boot Volume: $(diskutil info / | grep 'Volume Name' | awk -F: '{print $2}' | xargs)"
echo ""

cat << 'EOF'
================================================================================
APPEARANCE & INTERFACE
================================================================================
EOF

echo "Interface Style: $(read_default NSGlobalDomain AppleInterfaceStyle 'Light')"
echo "Accent Color: $(read_default NSGlobalDomain AppleAccentColor 'Blue (default)')"
echo "Highlight Color: $(read_default NSGlobalDomain AppleHighlightColor '(default)')"
echo "Sidebar Icon Size: $(read_default NSGlobalDomain NSTableViewDefaultSizeMode '(default)')"
echo "Show Scroll Bars: $(read_default NSGlobalDomain AppleShowScrollBars)"
echo "Menu Bar Auto-hide: $(read_default NSGlobalDomain _HIHideMenuBar 'false')"
echo "Reduce Transparency: $(read_default com.apple.universalaccess reduceTransparency 'false')"
echo "Reduce Motion: $(read_default com.apple.universalaccess reduceMotion 'false')"
echo ""

cat << 'EOF'
================================================================================
DOCK
================================================================================
EOF

echo "Tile Size: $(read_default com.apple.dock tilesize '(default)')"
echo "Magnification: $(read_default com.apple.dock magnification 'false')"
echo "Auto-hide: $(read_default com.apple.dock autohide)"
echo "Auto-hide Delay: $(read_default com.apple.dock autohide-delay '(default)') seconds"
echo "Show Indicators: $(read_default com.apple.dock show-process-indicators)"
echo "Show Recent Apps: $(read_default com.apple.dock show-recents)"
echo "Minimize Effect: $(read_default com.apple.dock mineffect)"
echo "Minimize to App Icon: $(read_default com.apple.dock minimize-to-application)"
echo "Launch Animation: $(read_default com.apple.dock launchanim)"
echo "Show Hidden Apps: $(read_default com.apple.dock showhidden)"
echo "Mission Control Animation: $(read_default com.apple.dock expose-animation-duration) seconds"
echo "Rearrange Spaces: $(read_default com.apple.dock mru-spaces)"
echo "Displays Have Separate Spaces: $(read_default com.apple.spaces spans-displays)"
echo ""

cat << 'EOF'
================================================================================
FINDER
================================================================================
EOF

echo "Show Hidden Files: $(read_default com.apple.finder AppleShowAllFiles)"
echo "Show All Extensions: $(read_default NSGlobalDomain AppleShowAllExtensions)"
echo "Show Status Bar: $(read_default com.apple.finder ShowStatusBar)"
echo "Show Path Bar: $(read_default com.apple.finder ShowPathbar)"
echo "Show POSIX Path in Title: $(read_default com.apple.finder _FXShowPosixPathInTitle)"
echo "Default View Style: $(read_default com.apple.finder FXPreferredViewStyle)"
echo "New Window Target: $(read_default com.apple.finder NewWindowTarget)"
echo "Search Scope: $(read_default com.apple.finder FXDefaultSearchScope)"
echo "Extension Change Warning: $(read_default com.apple.finder FXEnableExtensionChangeWarning)"
echo "Trash Warning: $(read_default com.apple.finder WarnOnEmptyTrash)"
echo "Empty Trash Securely: $(read_default com.apple.finder EmptyTrashSecurely)"
echo "Desktop Icons - Hard Drives: $(read_default com.apple.finder ShowHardDrivesOnDesktop)"
echo "Desktop Icons - External: $(read_default com.apple.finder ShowExternalHardDrivesOnDesktop)"
echo "Desktop Icons - Removable: $(read_default com.apple.finder ShowRemovableMediaOnDesktop)"
echo "Desktop Icons - Servers: $(read_default com.apple.finder ShowMountedServersOnDesktop)"
echo "Sort Folders First: $(read_default com.apple.finder _FXSortFoldersFirst)"
echo "QuickLook Text Selection: $(read_default com.apple.finder QLEnableTextSelection)"
echo ""

cat << 'EOF'
================================================================================
KEYBOARD & INPUT
================================================================================
EOF

echo "Key Repeat Rate: $(read_default NSGlobalDomain KeyRepeat)"
echo "Initial Key Repeat: $(read_default NSGlobalDomain InitialKeyRepeat)"
echo "Press and Hold: $(read_default NSGlobalDomain ApplePressAndHoldEnabled)"
echo "Full Keyboard Access: $(read_default NSGlobalDomain AppleKeyboardUIMode)"
echo "Auto-Correct: $(read_default NSGlobalDomain NSAutomaticSpellingCorrectionEnabled)"
echo "Smart Quotes: $(read_default NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled)"
echo "Smart Dashes: $(read_default NSGlobalDomain NSAutomaticDashSubstitutionEnabled)"
echo "Period Substitution: $(read_default NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled)"
echo "Capitalization: $(read_default NSGlobalDomain NSAutomaticCapitalizationEnabled)"
echo "Show Control Characters: $(read_default NSGlobalDomain NSTextShowsControlCharacters)"
echo ""

cat << 'EOF'
================================================================================
TRACKPAD & MOUSE
================================================================================
EOF

echo "Tap to Click: $(read_default com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking)"
echo "Natural Scrolling: $(read_default NSGlobalDomain com.apple.swipescrolldirection)"
echo "Secondary Click: $(read_default com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick)"
echo "Tracking Speed: $(read_default NSGlobalDomain com.apple.trackpad.scaling)"
echo "Zoom with Ctrl: $(read_default com.apple.universalaccess closeViewScrollWheelToggle)"
echo ""

cat << 'EOF'
================================================================================
SCREENSHOTS
================================================================================
EOF

echo "Location: $(read_default com.apple.screencapture location)"
echo "Format: $(read_default com.apple.screencapture type)"
echo "Show Thumbnail: $(read_default com.apple.screencapture show-thumbnail)"
echo "Include Date: $(read_default com.apple.screencapture include-date)"
echo "Disable Shadow: $(read_default com.apple.screencapture disable-shadow)"
echo ""

cat << 'EOF'
================================================================================
SECURITY & PRIVACY
================================================================================
EOF

echo "Screen Saver Password: $(read_default com.apple.screensaver askForPassword)"
echo "Password Delay: $(read_default com.apple.screensaver askForPasswordDelay) seconds"
echo "Gatekeeper: $(spctl --status 2>/dev/null || echo '(error reading)')"
echo "FileVault Status: $(fdesetup status 2>/dev/null || echo '(error reading)')"
if [ -r /Library/Preferences/com.apple.alf.plist ]; then
    echo "Firewall Status: $(sudo defaults read /Library/Preferences/com.apple.alf globalstate 2>/dev/null || echo '(requires sudo)')"
else
    echo "Firewall Status: (requires sudo)"
fi
echo ""

cat << 'EOF'
================================================================================
SAFARI
================================================================================
EOF

echo "Show Full URL: $(read_default com.apple.Safari ShowFullURLInSmartSearchField)"
echo "Auto-Open Safe Downloads: $(read_default com.apple.Safari AutoOpenSafeDownloads)"
echo "Include Debug Menu: $(read_default com.apple.Safari IncludeInternalDebugMenu)"
echo "Include Develop Menu: $(read_default com.apple.Safari IncludeDevelopMenu)"
echo "Search Suggestions: $(read_default com.apple.Safari SuppressSearchSuggestions)"
echo "Universal Search: $(read_default com.apple.Safari UniversalSearchEnabled)"
echo "Tab to Links: $(read_default com.apple.Safari WebKitTabToLinksPreferenceKey)"
echo ""

cat << 'EOF'
================================================================================
MAIL
================================================================================
EOF

echo "Reply Animations: $(read_default com.apple.mail DisableReplyAnimations)"
echo "Send Animations: $(read_default com.apple.mail DisableSendAnimations)"
echo "Include Name on Paste: $(read_default com.apple.mail AddressesIncludeNameOnPasteboard)"
echo "Inline Attachments: $(read_default com.apple.mail DisableInlineAttachmentViewing)"
echo "Spell Checking: $(read_default com.apple.mail SpellCheckingBehavior)"
echo ""

cat << 'EOF'
================================================================================
ACTIVITY MONITOR
================================================================================
EOF

echo "Open Main Window: $(read_default com.apple.ActivityMonitor OpenMainWindow)"
echo "Dock Icon Type: $(read_default com.apple.ActivityMonitor IconType)"
echo "Show Category: $(read_default com.apple.ActivityMonitor ShowCategory)"
echo "Sort Column: $(read_default com.apple.ActivityMonitor SortColumn)"
echo ""

cat << 'EOF'
================================================================================
TEXT EDIT
================================================================================
EOF

echo "Rich Text Mode: $(read_default com.apple.TextEdit RichText)"
echo "Plain Text Encoding: $(read_default com.apple.TextEdit PlainTextEncoding)"
echo ""

cat << 'EOF'
================================================================================
TIME MACHINE
================================================================================
EOF

echo "Prompt for New Disks: $(read_default com.apple.TimeMachine DoNotOfferNewDisksForBackup)"
echo ""

cat << 'EOF'
================================================================================
APP STORE
================================================================================
EOF

echo "WebKit Developer Tools: $(read_default com.apple.appstore WebKitDeveloperExtras)"
echo "Debug Menu: $(read_default com.apple.appstore ShowDebugMenu)"
echo "Auto Updates: $(read_default com.apple.commerce AutoUpdate)"
echo "Video Autoplay: $(read_default com.apple.AppStore AutoPlayVideoSetting)"
echo ""

cat << 'EOF'
================================================================================
GENERAL SETTINGS
================================================================================
EOF

echo "Window Resize Speed: $(read_default NSGlobalDomain NSWindowResizeTime) seconds"
echo "Save Panel Expanded: $(read_default NSGlobalDomain NSNavPanelExpandedStateForSaveMode)"
echo "Print Panel Expanded: $(read_default NSGlobalDomain PMPrintingExpandedStateForPrint)"
echo "Save to Disk (not iCloud): $(read_default NSGlobalDomain NSDocumentSaveNewDocumentsToCloud)"
echo "Resume System-wide: $(read_default com.apple.systempreferences NSQuitAlwaysKeepsWindows)"
echo "Auto-terminate Apps: $(read_default NSGlobalDomain NSDisableAutomaticTermination)"
echo "Printer Auto-Quit: $(read_default com.apple.print.PrintingPrefs 'Quit When Finished')"
echo "Quarantine Warning: $(read_default com.apple.LaunchServices LSQuarantine)"
echo ""

cat << 'EOF'
================================================================================
POWER MANAGEMENT
================================================================================
EOF

pmset -g 2>/dev/null || echo "(error reading power settings)"
echo ""

cat << 'EOF'
================================================================================
SYSTEM SETUP
================================================================================
EOF

echo "Computer Name: $(scutil --get ComputerName 2>/dev/null || echo '(not set)')"
echo "Host Name: $(scutil --get HostName 2>/dev/null || echo '(not set)')"
echo "Local Host Name: $(scutil --get LocalHostName 2>/dev/null || echo '(not set)')"
echo "Time Zone: $(systemsetup -gettimezone 2>/dev/null | cut -d: -f2 | xargs)"
echo "Restart on Freeze: $(systemsetup -getrestartfreeze 2>/dev/null | cut -d: -f2 | xargs)"
echo "Remote Login (SSH): $(systemsetup -getremotelogin 2>/dev/null | cut -d: -f2 | xargs)"
echo "Remote Apple Events: $(systemsetup -getremoteappleevents 2>/dev/null | cut -d: -f2 | xargs)"
echo ""

cat << 'EOF'
================================================================================
THIRD-PARTY APPLICATIONS
================================================================================
EOF

echo "=== Google Chrome ==="
echo "Disable Print Preview: $(read_default com.google.Chrome DisablePrintPreview)"
echo ""

echo "=== Transmission ==="
echo "Use Incomplete Folder: $(read_default org.m0k.transmission UseIncompleteDownloadFolder)"
echo "Delete Original Torrent: $(read_default org.m0k.transmission DeleteOriginalTorrent)"
echo ""

cat << 'EOF'
================================================================================
END OF EXPORT
================================================================================
EOF

} > "$OUTPUT_FILE"

log_success "Settings exported to: ${OUTPUT_FILE}"
echo ""
echo "You can view the export with:"
echo "  cat ${OUTPUT_FILE}"
echo "  or"
echo "  less ${OUTPUT_FILE}"
