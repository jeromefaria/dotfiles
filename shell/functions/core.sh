#!/usr/bin/env zsh
# Core shell functions - essential utilities

# Create a new directory and enter it
# Usage: mkd <directory_name>
function mkd() {
  if [[ -z "$1" ]]; then
    echo "Usage: mkd <directory_name>"
    return 1
  fi
  mkdir -p "$@" && cd "$_"
}

# Change working directory to the top-most Finder window location
# Usage: cdf
function cdf() {
  cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')"
}

# Determine size of a file or total size of a directory
# Usage: fs [path]
function fs() {
  if du -b /dev/null > /dev/null 2>&1; then
    local arg=-sbh
  else
    local arg=-sh
  fi
  if [[ -n "$@" ]]; then
    du $arg -- "$@"
  else
    du $arg .[^.]* ./* 2>/dev/null
  fi
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

# Create a data URL from a file
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

# Read specific line from file
# Usage: rl <file> <line_number>
function rl() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: rl <file> <line_number>"
    return 1
  fi
  if [[ ! -f "$1" ]]; then
    echo "Error: File '$1' not found"
    return 1
  fi
  head -"$2" "$1" | tail -1
}

# Grab all href links from a webpage
# Usage: links <url>
function links() {
  if [[ -z "$1" ]]; then
    echo "Usage: links <url>"
    return 1
  fi
  curl -s "$1" | grep -o -E 'href="([^"#]+)"' | cut -d'"' -f2
}

# Generate a random number between min and max
# Usage: randNum <min> <max>
function randNum() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: randNum <min> <max>"
    return 1
  fi
  echo $(($1 + RANDOM % ($2 - $1 + 1)))
}

# rsync a file/folder to a new location and removes the origin once finished
# Usage: sync <source> <destination>
function sync() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: sync <source> <destination>"
    return 1
  fi
  rsync -rzHPX --append-verify --remove-source-files "$1" "$2"
}
