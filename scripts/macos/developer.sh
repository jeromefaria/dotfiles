#!/usr/bin/env bash
#
# macOS Developer Settings
# Settings optimized for software development work
# Includes Safari dev tools, debug menus, and developer-friendly configurations
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

log_section "Applying Developer macOS Settings"

###############################################################################
# Safari & WebKit
###############################################################################

log_section "Safari & WebKit"

# Privacy: don't send search queries to Apple
log_info "Disabling Safari search suggestions"
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

# Press Tab to highlight each item on a web page
log_info "Enabling Tab to highlight web page items"
defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

# Show the full URL in the address bar
log_info "Showing full URL in Safari address bar"
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# Prevent Safari from opening 'safe' files automatically after downloading
log_info "Disabling auto-opening of safe downloads"
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Allow hitting the Backspace key to go to the previous page in history
log_info "Enabling Backspace for navigation"
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true

# Disable Safari's thumbnail cache for History and Top Sites
log_info "Disabling Safari thumbnail cache"
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

# Enable Safari's debug menu
log_info "Enabling Safari debug menu"
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

# Make Safari's search banners default to Contains instead of Starts With
log_info "Setting Safari search to 'Contains'"
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

# Enable the Develop menu and the Web Inspector in Safari
log_info "Enabling Safari Web Inspector and Develop menu"
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# Add a context menu item for showing the Web Inspector in web views
log_info "Enabling Web Inspector in all web views"
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

###############################################################################
# Mail
###############################################################################

log_section "Mail.app"

# Disable send and reply animations in Mail.app
log_info "Disabling Mail animations"
defaults write com.apple.mail DisableReplyAnimations -bool true
defaults write com.apple.mail DisableSendAnimations -bool true

# Copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>` in Mail.app
log_info "Copying email addresses without names"
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app
log_info "Adding Cmd+Enter to send emails"
defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" -string "@\\U21a9"

# Display emails in threaded mode, sorted by date (oldest at the top)
log_info "Configuring Mail threading"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "DisplayInThreadedMode" -string "yes"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortedDescending" -string "yes"
defaults write com.apple.mail DraftsViewerAttributes -dict-add "SortOrder" -string "received-date"

# Disable inline attachments (just show the icons)
log_info "Disabling inline attachment viewing"
defaults write com.apple.mail DisableInlineAttachmentViewing -bool true

# Disable automatic spell checking
log_info "Disabling Mail spell checking"
defaults write com.apple.mail SpellCheckingBehavior -string "NoSpellCheckingEnabled"

###############################################################################
# Messages
###############################################################################

log_section "Messages"

# Disable automatic emoji substitution (i.e. use plain text smileys)
log_info "Disabling emoji substitution"
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

# Disable smart quotes as it's annoying for messages that contain code
log_info "Disabling smart quotes in Messages"
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

###############################################################################
# Google Chrome
###############################################################################

log_section "Google Chrome"

# Allow installing user scripts via GitHub Gist or Userscripts.org
log_info "Allowing Chrome user script sources"
defaults write com.google.Chrome ExtensionInstallSources -array "https://gist.githubusercontent.com/" "http://userscripts.org/*"
defaults write com.google.Chrome.canary ExtensionInstallSources -array "https://gist.githubusercontent.com/" "http://userscripts.org/*"

# Use the system-native print preview dialog
log_info "Using system print preview in Chrome"
defaults write com.google.Chrome DisablePrintPreview -bool true
defaults write com.google.Chrome.canary DisablePrintPreview -bool true

# Expand the print dialog by default
log_info "Expanding Chrome print dialog"
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true

###############################################################################
# Mac App Store
###############################################################################

log_section "Mac App Store"

# Enable the WebKit Developer Tools in the Mac App Store
log_info "Enabling App Store WebKit dev tools"
defaults write com.apple.appstore WebKitDeveloperExtras -bool true

# Enable Debug Menu in the Mac App Store
log_info "Enabling App Store debug menu"
defaults write com.apple.appstore ShowDebugMenu -bool true

# Disable automatic app updates (let developers control when to update)
log_info "Disabling automatic app updates"
defaults write com.apple.commerce AutoUpdate -bool false

# Disable video autoplay in App Store
log_info "Disabling App Store video autoplay"
defaults write com.apple.AppStore AutoPlayVideoSetting -string "off"

###############################################################################
# Address Book & iCal
###############################################################################

log_section "Address Book & Calendar"

# Enable the debug menu in Address Book
log_info "Enabling Address Book debug menu"
defaults write com.apple.addressbook ABShowDebugMenu -bool true

# Enable the debug menu in iCal (pre-10.8)
log_info "Enabling iCal debug menu"
defaults write com.apple.iCal IncludeDebugMenu -bool true

###############################################################################
# Finder Developer Features
###############################################################################

log_section "Finder Developer Features"

# Enable QuickLook text selection
log_info "Enabling QuickLook text selection"
defaults write com.apple.finder QLEnableTextSelection -bool true

# Show hidden files by default (useful for developers)
log_info "Showing hidden files in Finder"
defaults write com.apple.finder AppleShowAllFiles -bool true

# Enable AirDrop over Ethernet and on unsupported Macs
log_info "Enabling AirDrop over Ethernet"
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

###############################################################################
# Xcode & Development Tools
###############################################################################

log_section "Development Tools"

# Clean up Xcode Simulator unavailable devices
if command -v xcrun &> /dev/null; then
    log_info "Cleaning up Xcode simulators"
    xcrun simctl delete unavailable 2>/dev/null || true
fi

# Show build times in Xcode
if [ -d "/Applications/Xcode.app" ]; then
    log_info "Enabling Xcode build times"
    defaults write com.apple.dt.Xcode ShowBuildOperationDuration -bool true
fi

###############################################################################
# Security & Privacy (Developer-friendly)
###############################################################################

log_section "Developer Security Settings"

# Disable the warning when running unsigned applications (useful for development)
# Note: Only do this if you're careful about what you run
log_info "Note: Quarantine warning already disabled in base.sh"

# Enable remote login (SSH) - useful for development
# Commented out by default for security, uncomment if needed
# log_info "Enabling remote login (SSH)"
# sudo systemsetup -setremotelogin on >/dev/null 2>&1

###############################################################################
# Performance Tweaks for Development
###############################################################################

log_section "Performance Optimizations"

# Disable Spotlight indexing for development folders (optional)
# This can speed up builds significantly
# Uncomment and customize paths as needed
# log_info "Adding Spotlight exclusions for dev folders"
# sudo mdutil -i off ~/Projects 2>/dev/null || true
# sudo mdutil -i off ~/Code 2>/dev/null || true

# Disable sudden motion sensor (not needed on SSDs, all modern Macs)
log_info "Disabling sudden motion sensor"
sudo pmset -a sms 0 2>/dev/null || true

###############################################################################
# Git Configuration Helpers
###############################################################################

log_section "Git Configuration"

# Check if git is installed
if command -v git &> /dev/null; then
    # Set up diff-so-fancy or delta if available
    if command -v delta &> /dev/null; then
        log_info "Configuring git to use delta for diffs"
        git config --global core.pager "delta"
        git config --global interactive.diffFilter "delta --color-only"
    elif command -v diff-so-fancy &> /dev/null; then
        log_info "Configuring git to use diff-so-fancy"
        git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
    fi

    # Set up better git defaults
    log_info "Setting recommended git defaults"
    git config --global pull.rebase false 2>/dev/null || true
    git config --global init.defaultBranch main 2>/dev/null || true
    git config --global color.ui auto 2>/dev/null || true
else
    log_info "Git not found, skipping git configuration"
fi

###############################################################################
# Homebrew Configuration
###############################################################################

log_section "Homebrew Configuration"

# Set up Homebrew environment if installed
if command -v brew &> /dev/null; then
    log_info "Disabling Homebrew analytics"
    brew analytics off 2>/dev/null || true

    log_info "Configuring Homebrew auto-update"
    # Disable auto-update on every command (can be annoying during development)
    export HOMEBREW_NO_AUTO_UPDATE=1
    echo "export HOMEBREW_NO_AUTO_UPDATE=1" >> ~/.zshrc.local 2>/dev/null || true
else
    log_info "Homebrew not found, skipping Homebrew configuration"
fi

###############################################################################
# Node.js & npm Configuration
###############################################################################

log_section "Node.js Configuration"

# Create .npmrc if it doesn't exist
if command -v npm &> /dev/null && [ ! -f ~/.npmrc ]; then
    log_info "Creating ~/.npmrc with recommended settings"
    cat > ~/.npmrc << 'EOF'
# Recommended npm settings for developers
progress=false
save-exact=true
engine-strict=true
EOF
fi

log_success "Developer settings applied successfully!"
echo ""
echo "Additional recommendations:"
echo "  - Consider enabling FileVault encryption"
echo "  - Set up SSH keys for GitHub/GitLab"
echo "  - Configure your preferred code editor settings"
echo "  - Install essential development tools via Homebrew"
