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
