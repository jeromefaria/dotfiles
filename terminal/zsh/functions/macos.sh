#!/usr/bin/env zsh
# macOS-specific functions - system utilities and maintenance
# These functions use macOS-only tools like osascript, pbcopy, pbpaste

# Change working directory to the top-most Finder window location
# Usage: cdf
function cdf() {
  cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')"
}

# Base64 encoding - encodes file and copies to clipboard
# Usage: enc <file>
function enc() {
  if [[ -z "$1" ]]; then
    echo "Usage: enc <file>"
    return 1
  fi
  if [[ ! -f "$1" ]]; then
    echo "Error: File '$1' not found"
    return 1
  fi
  openssl base64 -in "$1" | tr -d '\n' | pbcopy
  echo "Encoded and copied to clipboard"
}

# Base64 decoding - decodes clipboard and saves to file
# Usage: dec <output_file>
function dec() {
  if [[ -z "$1" ]]; then
    echo "Usage: dec <output_file>"
    return 1
  fi
  pbpaste | openssl base64 -d > "$1"
  echo "Decoded and saved to $1"
}

# Create a data URL from a file (uses pbcopy for clipboard)
# Usage: dataurl <file>
function dataurl() {
  if [[ -z "$1" ]]; then
    echo "Usage: dataurl <file>"
    return 1
  fi
  if [[ ! -f "$1" ]]; then
    echo "Error: File '$1' not found"
    return 1
  fi
  local mimeType=$(file -b --mime-type "$1")
  if [[ $mimeType == text/* ]]; then
    mimeType="${mimeType};charset=utf-8"
  fi
  echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')"
}

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

# Wipe Max 9's cached DB files so Max rebuilds them on next launch —
# covers both standalone Max and Live 12's Max-for-Live. Use when Live 12
# loads slowly because Max re-inits every time (a stale `_lock.maxdb`
# with no main `.maxdb` is the signal — previous rebuild aborted mid-write).
# Usage: maxrebuilddb
function maxrebuilddb() {
  local db="$HOME/Library/Application Support/Cycling '74/Max 9/Database"
  if [[ ! -d "$db" ]]; then
    echo "maxrebuilddb: Max 9 DB dir not found at $db"
    return 1
  fi

  setopt local_options null_glob
  local files=(
    "$db"/macintosh\ hd--applications-max.x64*.maxdb*
    "$db"/macintosh\ hd--applications-ableton\ live\ 12\ suite.app-contents-app-resources-max-max.x64*.maxdb*
  )

  if (( ${#files} == 0 )); then
    echo "maxrebuilddb: nothing to remove — DBs already cleared."
    return 0
  fi

  rm -v "${files[@]}"
}

