#!/usr/bin/env bash
#
# macOS Third-Party Application Settings
# Configure settings for installed third-party applications
# Only configures apps that are actually installed
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
    log_skip() { echo "⊘ $1"; }
fi

log_section "Configuring Third-Party Applications"

###############################################################################
# Helper function to check if an app is installed
###############################################################################

app_installed() {
    [ -d "/Applications/$1.app" ] || [ -d "$HOME/Applications/$1.app" ]
}

###############################################################################
# Google Chrome
###############################################################################

if app_installed "Google Chrome"; then
    log_section "Google Chrome"

    # Disable backswipe on trackpads (can be annoying)
    log_info "Disabling trackpad backswipe navigation"
    defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false

    # Disable backswipe on Magic Mouse
    log_info "Disabling Magic Mouse backswipe navigation"
    defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false
else
    log_skip "Google Chrome not installed, skipping"
fi

###############################################################################
# Google Chrome Canary
###############################################################################

if app_installed "Google Chrome Canary"; then
    log_section "Google Chrome Canary"

    defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false
    defaults write com.google.Chrome.canary AppleEnableMouseSwipeNavigateWithScrolls -bool false
    log_info "Configured Chrome Canary navigation settings"
else
    log_skip "Google Chrome Canary not installed, skipping"
fi

###############################################################################
# Opera
###############################################################################

if app_installed "Opera"; then
    log_section "Opera"

    log_info "Expanding print dialog by default"
    defaults write com.operasoftware.Opera PMPrintingExpandedStateForPrint2 -bool true
else
    log_skip "Opera not installed, skipping"
fi

###############################################################################
# Opera Developer
###############################################################################

if app_installed "Opera Developer"; then
    log_section "Opera Developer"

    defaults write com.operasoftware.OperaDeveloper PMPrintingExpandedStateForPrint2 -bool true
    log_info "Configured Opera Developer print settings"
else
    log_skip "Opera Developer not installed, skipping"
fi

###############################################################################
# Transmission
###############################################################################

if app_installed "Transmission"; then
    log_section "Transmission"

    # Create Torrents directory if it doesn't exist
    TORRENTS_DIR="${HOME}/Documents/Torrents"
    if [ ! -d "$TORRENTS_DIR" ]; then
        log_info "Creating Torrents directory"
        mkdir -p "$TORRENTS_DIR"
    fi

    # Use ~/Documents/Torrents to store incomplete downloads
    log_info "Setting incomplete download folder"
    defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
    defaults write org.m0k.transmission IncompleteDownloadFolder -string "$TORRENTS_DIR"

    # Don't prompt for confirmation before downloading
    log_info "Disabling download confirmation"
    defaults write org.m0k.transmission DownloadAsk -bool false

    # Trash original torrent files
    log_info "Auto-deleting original torrent files"
    defaults write org.m0k.transmission DeleteOriginalTorrent -bool true

    # Hide the donate message
    log_info "Hiding donate message"
    defaults write org.m0k.transmission WarningDonate -bool false

    # Hide the legal disclaimer
    log_info "Hiding legal disclaimer"
    defaults write org.m0k.transmission WarningLegal -bool false
else
    log_skip "Transmission not installed, skipping"
fi

###############################################################################
# Twitter (legacy)
###############################################################################

if app_installed "Twitter"; then
    log_section "Twitter"

    log_info "Disabling smart quotes"
    defaults write com.twitter.twitter-mac AutomaticQuoteSubstitutionEnabled -bool false

    log_info "Setting menu bar icon behavior"
    defaults write com.twitter.twitter-mac MenuItemBehavior -int 1

    log_info "Enabling develop menu"
    defaults write com.twitter.twitter-mac ShowDevelopMenu -bool true

    log_info "Opening links in background"
    defaults write com.twitter.twitter-mac openLinksInBackground -bool true

    log_info "Enabling Esc to close compose window"
    defaults write com.twitter.twitter-mac ESCClosesComposeWindow -bool true

    log_info "Showing full names"
    defaults write com.twitter.twitter-mac ShowFullNames -bool true

    log_info "Hiding in background when not front-most"
    defaults write com.twitter.twitter-mac HideInBackground -bool true
else
    log_skip "Twitter app not installed, skipping"
fi

###############################################################################
# Sublime Text
###############################################################################

if app_installed "Sublime Text"; then
    log_section "Sublime Text"

    # Check if init directory exists with Sublime Text settings
    SUBLIME_INIT_DIR="${SCRIPT_DIR}/../../init"
    if [ -f "${SUBLIME_INIT_DIR}/Preferences.sublime-settings" ]; then
        # Find Sublime Text settings directory
        SUBLIME_DIR=$(find "${HOME}/Library/Application Support" -name "Sublime Text*" -type d -maxdepth 1 | head -n 1)

        if [ -n "$SUBLIME_DIR" ]; then
            log_info "Copying Sublime Text preferences"
            cp "${SUBLIME_INIT_DIR}/Preferences.sublime-settings" "${SUBLIME_DIR}/Packages/User/Preferences.sublime-settings" 2>/dev/null || true
        fi
    else
        log_info "No custom Sublime Text settings found in init/"
    fi
else
    log_skip "Sublime Text not installed, skipping"
fi

###############################################################################
# Visual Studio Code
###############################################################################

if app_installed "Visual Studio Code" || command -v code &> /dev/null; then
    log_section "Visual Studio Code"

    # VSCode settings are typically synced via Settings Sync or stored in dotfiles
    # We can symlink settings if they exist
    VSCODE_CONFIG_DIR="${HOME}/Library/Application Support/Code/User"
    DOTFILES_VSCODE="${SCRIPT_DIR}/../../config/vscode"

    if [ -d "$DOTFILES_VSCODE" ] && [ -f "${DOTFILES_VSCODE}/settings.json" ]; then
        log_info "Linking VSCode settings from dotfiles"
        mkdir -p "$VSCODE_CONFIG_DIR"
        ln -sf "${DOTFILES_VSCODE}/settings.json" "${VSCODE_CONFIG_DIR}/settings.json" 2>/dev/null || true
        ln -sf "${DOTFILES_VSCODE}/keybindings.json" "${VSCODE_CONFIG_DIR}/keybindings.json" 2>/dev/null || true
    else
        log_info "No VSCode settings found in dotfiles, using Settings Sync or defaults"
    fi
else
    log_skip "Visual Studio Code not installed, skipping"
fi

###############################################################################
# iTerm2
###############################################################################

if app_installed "iTerm" || app_installed "iTerm2"; then
    log_section "iTerm2"

    # Check if we have iTerm2 preferences in dotfiles
    ITERM_PREFS="${SCRIPT_DIR}/../../config/iterm2"

    if [ -d "$ITERM_PREFS" ]; then
        log_info "Setting iTerm2 to load preferences from dotfiles"
        defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$ITERM_PREFS"
        defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
    else
        log_info "No iTerm2 preferences found in dotfiles"
    fi
else
    log_skip "iTerm2 not installed, skipping"
fi

###############################################################################
# Spectacle / Rectangle (Window Management)
###############################################################################

if app_installed "Spectacle"; then
    log_section "Spectacle"

    log_info "Starting Spectacle at login"
    defaults write com.irradiatedsoftware.Spectacle StartAtLogin -bool true

    log_info "Hiding preferences window on next start"
    defaults write com.irradiatedsoftware.Spectacle ShowPrefsOnNextStart -bool false
else
    log_skip "Spectacle not installed, skipping"
fi

if app_installed "Rectangle"; then
    log_section "Rectangle"

    log_info "Starting Rectangle at login"
    defaults write com.knollsoft.Rectangle launchOnLogin -bool true
else
    log_skip "Rectangle not installed, skipping"
fi

###############################################################################
# Alfred
###############################################################################

if app_installed "Alfred 5" || app_installed "Alfred 4" || app_installed "Alfred"; then
    log_section "Alfred"

    # Alfred settings are typically managed through the app's sync feature
    # We can set the preferences folder if we have it in dotfiles
    ALFRED_PREFS="${SCRIPT_DIR}/../../config/alfred"

    if [ -d "$ALFRED_PREFS" ]; then
        log_info "Alfred preferences found in dotfiles"
        # This would need to be set through Alfred's UI or via plist
        log_info "Note: Set Alfred sync folder to $ALFRED_PREFS in Alfred preferences"
    else
        log_info "No Alfred preferences found in dotfiles"
    fi
else
    log_skip "Alfred not installed, skipping"
fi

###############################################################################
# Docker Desktop
###############################################################################

if app_installed "Docker"; then
    log_section "Docker Desktop"

    # Docker Desktop settings are managed through its settings file
    DOCKER_SETTINGS="${HOME}/Library/Group Containers/group.com.docker/settings.json"

    if [ -f "$DOCKER_SETTINGS" ]; then
        log_info "Docker Desktop is configured"
        # Settings are managed through Docker Desktop UI
    else
        log_info "Docker Desktop not yet configured"
    fi
else
    log_skip "Docker Desktop not installed, skipping"
fi

###############################################################################
# Dropbox
###############################################################################

if app_installed "Dropbox"; then
    log_section "Dropbox"

    # Remove Dropbox's green checkmark icons in Finder
    log_info "Removing Dropbox checkmark icons"
    DROPBOX_ICON="/Applications/Dropbox.app/Contents/Resources/emblem-dropbox-uptodate.icns"
    if [ -e "$DROPBOX_ICON" ]; then
        mv -f "$DROPBOX_ICON" "${DROPBOX_ICON}.bak" 2>/dev/null || true
    fi
else
    log_skip "Dropbox not installed, skipping"
fi

###############################################################################
# Bartender (Menu Bar Organization)
###############################################################################

if app_installed "Bartender 4" || app_installed "Bartender 5"; then
    log_section "Bartender"

    log_info "Starting Bartender at login"
    # Bartender settings are managed through the app
    defaults write com.surteesstudios.Bartender launchAtLogin -bool true 2>/dev/null || true
else
    log_skip "Bartender not installed, skipping"
fi

###############################################################################
# Karabiner-Elements
###############################################################################

if app_installed "Karabiner-Elements"; then
    log_section "Karabiner-Elements"

    # Karabiner-Elements config is typically in ~/.config/karabiner/
    KARABINER_CONFIG="${HOME}/.config/karabiner"
    DOTFILES_KARABINER="${SCRIPT_DIR}/../../config/karabiner"

    if [ -d "$DOTFILES_KARABINER" ]; then
        log_info "Linking Karabiner-Elements configuration"
        mkdir -p "$KARABINER_CONFIG"
        ln -sf "${DOTFILES_KARABINER}/karabiner.json" "${KARABINER_CONFIG}/karabiner.json" 2>/dev/null || true
    else
        log_info "No Karabiner-Elements config found in dotfiles"
    fi
else
    log_skip "Karabiner-Elements not installed, skipping"
fi

###############################################################################
# 1Password
###############################################################################

if app_installed "1Password 7" || app_installed "1Password"; then
    log_section "1Password"

    log_info "1Password settings are managed through the app and sync"
    # 1Password settings are typically synced via their service
else
    log_skip "1Password not installed, skipping"
fi

###############################################################################
# Hammerspoon
###############################################################################

if app_installed "Hammerspoon"; then
    log_section "Hammerspoon"

    # Hammerspoon config is typically in ~/.hammerspoon/
    HAMMERSPOON_CONFIG="${HOME}/.hammerspoon"
    DOTFILES_HAMMERSPOON="${SCRIPT_DIR}/../../config/hammerspoon"

    if [ -d "$DOTFILES_HAMMERSPOON" ]; then
        log_info "Linking Hammerspoon configuration"
        ln -sf "${DOTFILES_HAMMERSPOON}" "$HAMMERSPOON_CONFIG" 2>/dev/null || true
    else
        log_info "No Hammerspoon config found in dotfiles"
    fi
else
    log_skip "Hammerspoon not installed, skipping"
fi

###############################################################################
# Additional Apps
###############################################################################

log_section "Additional Applications"

# Add configuration for any other apps you use
# Examples:

# Notion
if app_installed "Notion"; then
    log_info "Notion installed (settings synced via account)"
fi

# Slack
if app_installed "Slack"; then
    log_info "Slack installed (settings synced via account)"
fi

# Zoom
if app_installed "zoom.us"; then
    log_info "Zoom installed"
fi

# Spotify
if app_installed "Spotify"; then
    log_info "Spotify installed"
fi

log_success "Third-party application settings applied!"
echo ""
echo "Application configuration notes:"
echo "  - Many apps sync settings via their own services"
echo "  - Check individual app preferences for additional customization"
echo "  - Add your own app configurations to scripts/macos/apps.sh"
