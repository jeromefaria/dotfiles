#!/usr/bin/env zsh
# macOS-specific functions - system utilities and maintenance

# Font cache reset to fix an old bug in Chrome
# Usage: resetfontcache
function resetfontcache() {
  echo "Resetting font cache..."
  atsutil databases -removeUser
  sudo atsutil databases -remove
  atsutil server -shutdown
  atsutil server -ping
  echo "Font cache reset complete"
}

# Run maintenance scripts and purge used memory
# Usage: periodic
function periodic() {
  echo "Running maintenance scripts..."
  sudo periodic daily weekly monthly
  echo "Purging memory..."
  purge
  echo "Maintenance complete"
}

# Run dig and display the most useful info
# Usage: digga <domain>
function digga() {
  if [[ -z "$1" ]]; then
    echo "Usage: digga <domain>"
    return 1
  fi
  dig +nocmd "$1" any +multiline +noall +answer
}

# Tree command with hidden files and color enabled, ignoring common directories
# Usage: tre [path]
function tre() {
  if ! command -v tree &> /dev/null; then
    echo "Error: tree not installed. Install with: brew install tree"
    return 1
  fi
  tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX
}

# Clear Finder Go To History
# Usage: clearFinderHistory
function clearFinderHistory() {
  defaults delete com.apple.finder GoToField 2>/dev/null
  defaults delete com.apple.finder GoToFieldHistory 2>/dev/null
  echo "Finder history cleared"
}

# Kill and restart Touch Bar
# Usage: restartTouchBar
function restartTouchBar() {
  echo "Restarting Touch Bar..."
  sudo pkill "Touch Bar agent"
  sudo killall "ControlStrip"
  echo "Touch Bar restarted"
}

# Spotifyd daemon management
SPOTIFYD="/Library/LaunchDaemons/rustlang.spotifyd.plist"

# Start spotifyd daemon
# Usage: startspotifyd
function startspotifyd() {
  if [[ ! -f "$SPOTIFYD" ]]; then
    echo "Error: Spotifyd plist not found at $SPOTIFYD"
    return 1
  fi
  sudo launchctl load -w "$SPOTIFYD" && sudo launchctl start "$SPOTIFYD"
  echo "Spotifyd started"
}

# Stop spotifyd daemon
# Usage: stopspotifyd
function stopspotifyd() {
  if [[ ! -f "$SPOTIFYD" ]]; then
    echo "Error: Spotifyd plist not found at $SPOTIFYD"
    return 1
  fi
  sudo launchctl unload -w "$SPOTIFYD" && sudo launchctl stop "$SPOTIFYD"
  echo "Spotifyd stopped"
}
