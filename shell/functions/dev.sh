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
# Prefers fnm/volta over deprecated sudo npm approach
function upgradenode() {
  if command -v fnm &>/dev/null; then
    echo "→ Upgrading Node.js via fnm..."
    fnm install --lts
    fnm use lts-latest
    fnm default lts-latest
    echo "✓ Node.js updated to $(node --version)"
  elif command -v volta &>/dev/null; then
    echo "→ Upgrading Node.js via volta..."
    volta install node@latest
    echo "✓ Node.js updated to $(node --version)"
  else
    echo "Error: Neither fnm nor volta found."
    echo "Install fnm: brew install fnm"
    echo "  or volta: brew install volta"
    return 1
  fi
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
# Configure JIRA_BASE_URL in ~/.zshrc.local, e.g.:
#   export JIRA_BASE_URL="https://yourcompany.atlassian.net/browse"
function oj() {
  if [[ ! -d .git ]]; then
    echo "Error: Not in a git repository"
    return 1
  fi
  if [[ -z "$JIRA_BASE_URL" ]]; then
    echo "Error: JIRA_BASE_URL not set. Add to ~/.zshrc.local:"
    echo '  export JIRA_BASE_URL="https://yourcompany.atlassian.net/browse"'
    return 1
  fi
  local branch=$(git branch | grep '\*' | grep -o '/\w\+-\d\+')
  if [[ -z "$branch" ]]; then
    echo "Error: Branch name doesn't contain a Jira ticket reference"
    return 1
  fi
  open "${JIRA_BASE_URL}${branch}"
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

# Update all system package managers and tools
# Usage: update [options]
#   -h, --help          Show help message
#   -s, --skip-brew     Skip Homebrew updates
#   -n, --skip-npm      Skip npm updates
#   -g, --skip-gems     Skip Ruby gem updates
#   -m, --skip-mas      Skip Mac App Store updates
#   -o, --skip-omz      Skip Oh My Zsh updates
#   -t, --skip-tldr     Skip tldr updates
#   -y, --yes           Skip confirmations (auto-yes)
function update() {
  local skip_brew=false
  local skip_npm=false
  local skip_gems=false
  local skip_mas=false
  local skip_omz=false
  local skip_tldr=false
  local auto_yes=false

  # Parse command-line arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        echo "Update all system package managers and tools"
        echo ""
        echo "Usage: update [options]"
        echo ""
        echo "Options:"
        echo "  -h, --help          Show this help message"
        echo "  -s, --skip-brew     Skip Homebrew updates"
        echo "  -n, --skip-npm      Skip npm updates"
        echo "  -g, --skip-gems     Skip Ruby gem updates"
        echo "  -m, --skip-mas      Skip Mac App Store updates"
        echo "  -o, --skip-omz      Skip Oh My Zsh updates"
        echo "  -t, --skip-tldr     Skip tldr updates"
        echo "  -y, --yes           Skip confirmations (auto-yes)"
        return 0
        ;;
      -s|--skip-brew)
        skip_brew=true
        shift
        ;;
      -n|--skip-npm)
        skip_npm=true
        shift
        ;;
      -g|--skip-gems)
        skip_gems=true
        shift
        ;;
      -m|--skip-mas)
        skip_mas=true
        shift
        ;;
      -o|--skip-omz)
        skip_omz=true
        shift
        ;;
      -t|--skip-tldr)
        skip_tldr=true
        shift
        ;;
      -y|--yes)
        auto_yes=true
        shift
        ;;
      *)
        echo "Unknown option: $1"
        echo "Run 'update --help' for usage information"
        return 1
        ;;
    esac
  done

  echo "=== System Update ==="
  echo ""

  # Refresh sudo timestamp
  echo "→ Refreshing sudo credentials..."
  sudo -v

  # Mac App Store
  if [[ "$skip_mas" == false ]] && command -v mas &> /dev/null; then
    echo ""
    echo "→ Updating Mac App Store apps..."
    if mas upgrade; then
      echo "✓ Mac App Store apps updated"
    else
      echo "✗ Mac App Store update failed (exit code: $?)"
    fi
  fi

  # Homebrew
  if [[ "$skip_brew" == false ]] && command -v brew &> /dev/null; then
    echo ""
    echo "→ Updating Homebrew..."
    if brew update; then
      echo "✓ Homebrew updated"
    else
      echo "✗ Homebrew update failed (exit code: $?)"
    fi

    echo ""
    echo "→ Upgrading Homebrew formulae..."
    if brew upgrade --formulae; then
      echo "✓ Formulae upgraded"
    else
      echo "✗ Formulae upgrade failed (exit code: $?)"
    fi

    echo ""
    echo "→ Upgrading Homebrew casks..."
    if command -v brew-cu &> /dev/null || brew tap | grep -q "buo/cask-upgrade"; then
      if brew cu -ay; then
        echo "✓ Casks upgraded"
      else
        echo "✗ Cask upgrade failed (exit code: $?)"
      fi
    else
      echo "ℹ Skipping cask upgrade (brew-cu not available)"
      echo "  Install with: brew tap buo/cask-upgrade"
    fi

    echo ""
    echo "→ Cleaning up Homebrew..."
    if brew cleanup; then
      echo "✓ Homebrew cleaned up"
    else
      echo "✗ Homebrew cleanup failed (exit code: $?)"
    fi
  fi

  # npm (without sudo - uses fnm/volta managed node)
  if [[ "$skip_npm" == false ]] && command -v npm &> /dev/null; then
    echo ""
    echo "→ Updating npm itself..."
    if npm install -g npm; then
      echo "✓ npm updated"
    else
      echo "✗ npm update failed (exit code: $?)"
    fi

    echo ""
    echo "→ Updating global npm packages..."
    if npm update -g; then
      echo "✓ Global npm packages updated"
    else
      echo "✗ Global npm packages update failed (exit code: $?)"
    fi
  fi

  # Ruby gems
  if [[ "$skip_gems" == false ]] && command -v gem &> /dev/null; then
    echo ""
    echo "→ Updating RubyGems system..."
    if gem update --system; then
      echo "✓ RubyGems system updated"
    else
      echo "✗ RubyGems system update failed (exit code: $?)"
    fi

    echo ""
    echo "→ Updating gems..."
    if gem update; then
      echo "✓ Gems updated"
    else
      echo "✗ Gem update failed (exit code: $?)"
    fi

    echo ""
    echo "→ Cleaning up old gems..."
    if gem cleanup; then
      echo "✓ Gems cleaned up"
    else
      echo "✗ Gem cleanup failed (exit code: $?)"
    fi
  fi

  # Oh My Zsh
  if [[ "$skip_omz" == false ]] && [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo ""
    echo "→ Updating Oh My Zsh..."
    if omz update; then
      echo "✓ Oh My Zsh updated"
    else
      echo "✗ Oh My Zsh update failed (exit code: $?)"
    fi
  fi

  # tldr
  if [[ "$skip_tldr" == false ]] && command -v tldr &> /dev/null; then
    echo ""
    echo "→ Updating tldr pages..."
    if tldr --update; then
      echo "✓ tldr pages updated"
    else
      echo "✗ tldr update failed (exit code: $?)"
    fi
  fi

  echo ""
  echo "=== Update Complete ==="
}
