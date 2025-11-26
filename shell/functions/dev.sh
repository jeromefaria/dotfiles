#!/usr/bin/env zsh
# Development-related functions

# Start an HTTP server from a directory, optionally specifying the port
# Usage: server [port] (default: 8000)
function server() {
  local port="${1:-8000}"
  sleep 1 && open "http://localhost:${port}/" &
  python3 -c $'import http.server;\nmap = http.server.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nhttp.server.test(HandlerClass=http.server.SimpleHTTPRequestHandler, port=int("'"$port"'"));' "$port"
}

# Start a PHP server from a directory, optionally specifying the port
# Requires PHP 5.4.0+
# Usage: phpserver [port] (default: 4000)
function phpserver() {
  local port="${1:-4000}"
  local ip=$(ipconfig getifaddr en1)
  if [[ -z "$ip" ]]; then
    echo "Error: Could not determine IP address for en1"
    return 1
  fi
  sleep 1 && open "http://${ip}:${port}/" &
  php -S "${ip}:${port}"
}

# Self update Node.js to latest stable version
# Usage: upgradenode
function upgradenode() {
  sudo npm cache clean -f
  sudo npm install -g n
  sudo n stable
}

# Runs a Processing project from the command line
# Usage: p5
function p5() {
  if [[ ! -d "$PWD" ]]; then
    echo "Error: Not in a valid directory"
    return 1
  fi
  processing-java --sketch="$PWD" --run
}

# Open the Jira ticket for the current branch
# Usage: oj
function oj() {
  if [[ ! -d .git ]]; then
    echo "Error: Not in a git repository"
    return 1
  fi
  local branch=$(git branch | grep '\*' | grep -o '/\w\+-\d\+')
  if [[ -z "$branch" ]]; then
    echo "Error: Branch name doesn't contain a Jira ticket reference"
    return 1
  fi
  open "https://linkfire.atlassian.net/browse${branch}"
}

# Get the date of the current latest commit
# Usage: ggd
function ggd() {
  if [[ ! -d .git ]]; then
    echo "Error: Not in a git repository"
    return 1
  fi
  git show | awk 'NR==3' | grep "Date:" | cut -d " " -f4-9 | tr "\n" " "
}

# Remove tracking branches no longer on remote
# Usage: gdb
function gdb() {
  if [[ ! -d .git ]]; then
    echo "Error: Not in a git repository"
    return 1
  fi
  git fetch -p
  for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do
    git branch -D "$branch"
  done
}

# Get app version from macOS application
# Usage: appver <AppName>
function appver() {
  if [[ -z "$1" ]]; then
    echo "Usage: appver <AppName>"
    return 1
  fi
  if [[ ! -d "/Applications/$1.app" ]]; then
    echo "Error: Application '$1' not found in /Applications"
    return 1
  fi
  plutil -p "/Applications/$1.app/Contents/Info.plist" | grep -i CFBundleShortVersionString | awk '{print $3}'
}

# Optimise and inline svg icons. Output to stdout. Pipe into $EDITOR to clean up.
# Usage: svg2css (run in directory with SVG files)
function svg2css() {
  if ! command -v svgo &> /dev/null; then
    echo "Error: svgo not installed. Install with: npm install -g svgo"
    return 1
  fi
  svgo * 1>/dev/null 2>&1
  for i in *.svg; do
    if [[ -f "$i" ]]; then
      echo ".${i%.*} {"
      echo "  background-image: url('data:image/svg+xml;base64,$(cat "$i" | base64)');"
      echo "}"
      echo ""
    fi
  done
}
