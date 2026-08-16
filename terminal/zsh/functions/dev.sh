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
function update() {
  local skip_brew=false
  local skip_npm=false
  local skip_gems=false
  local skip_mas=false
  local skip_omz=false
  local skip_tldr=false

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
      *)
        echo "Unknown option: $1"
        echo "Run 'update --help' for usage information"
        return 1
        ;;
    esac
  done

  echo "=== System Update ==="
  echo ""

  # Refresh sudo timestamp and keep it alive throughout the update
  echo "→ Refreshing sudo credentials..."
  sudo -v
  # Keep sudo alive in background until this script finishes
  while true; do sudo -n true; sleep 50; done 2>/dev/null &
  local sudo_pid=$!

  # Mac App Store
  if [[ "$skip_mas" == false ]] && command -v mas &> /dev/null; then
    echo ""
    echo "→ Updating Mac App Store apps..."
    if sudo MAS_NO_AUTO_INDEX=1 mas upgrade; then
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
    if brew upgrade --formulae --yes; then
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

  # Kill the sudo keep-alive process
  kill "$sudo_pid" 2>/dev/null

  echo ""
  echo "=== Update Complete ==="
}

# Switch into a project under the configured work tree's src/
# Usage: sel [project] (default: $WORK_DEFAULT_PROJECT)
# Configure in ~/.zshrc.local:
#   export WORK_PROJECT_BASE="$HOME/path/to/work/tree"
#   export WORK_DEFAULT_PROJECT="default-project-name"
function sel() {
  if [[ -z "$WORK_PROJECT_BASE" || -z "$WORK_DEFAULT_PROJECT" ]]; then
    echo "Error: set WORK_PROJECT_BASE and WORK_DEFAULT_PROJECT in ~/.zshrc.local"
    return 1
  fi
  local project="${1:-$WORK_DEFAULT_PROJECT}"
  local target="$WORK_PROJECT_BASE/src/$project"
  if [[ ! -d "$target" ]]; then
    echo "Error: $target does not exist"
    return 1
  fi
  builtin cd "$target"
}

# Scaffold a new gig folder under $WORK. Client root is a plain dir (NOT a
# repo), with doc/ + optional src/<project>/ inside. Claude Code picks up the
# client-level CLAUDE.md when invoked from anywhere under the gig, layering
# above per-project CLAUDE.md files inside the repos.
#
# Usage: newgig <client> [project]
#
# Args:
#   client   Client/gig name (no slashes, no leading dots).
#   project  Optional first project name; creates src/<project>/ ready for git.
#
# Examples:
#   newgig acme                 # ~/Work/acme with README, CLAUDE, doc/
#   newgig acme frontend        # ...plus src/frontend/ ready for git clone|init
#   newgig -h                   # show this help
#
# Creates under $WORK/<client>/:
#   README.md            local landing page (contacts, deliverables, links)
#   CLAUDE.md            gig-level Claude Code context (stays above repo boundary)
#   doc/                 unversioned knowledge base
#     README.md            naming + subdir conventions cheat sheet
#     active_tasks.md      living work list
#     archive/             rotated-out stale content
#   src/<project>/       only if project arg given; empty for git clone|init
#
# After scaffolding, paste the printed WORK_PROJECT_BASE line into
# ~/.zshrc.local so `mux w` points at the new gig on next session start.
function newgig() {
  emulate -L zsh
  setopt local_options err_return

  local client="$1" project="$2"
  if [[ "$client" == "-h" || "$client" == "--help" ]]; then
    cat <<'EOF'
Usage: newgig <client> [project]

Scaffold a new gig folder under $WORK. Client root is a plain dir (not a repo).

Args:
  client   Client/gig name (no slashes, no leading dots).
  project  Optional first project name; creates src/<project>/ ready for git.

Examples:
  newgig acme                 # ~/Work/acme with README, CLAUDE, doc/
  newgig acme frontend        # ...plus src/frontend/ ready for git clone|init

Creates $WORK/<client>/ with README.md, CLAUDE.md (client-level Claude
context), doc/{README.md,active_tasks.md,archive/}, and optionally
src/<project>/. Post-scaffold, prints the WORK_PROJECT_BASE export line
to paste into ~/.zshrc.local so `mux w` picks up the new gig.
EOF
    return 0
  fi
  if [[ -z "$client" ]]; then
    echo "usage: newgig <client> [project]  (run 'newgig -h' for details)"
    return 1
  fi
  if [[ "$client" == */* || "$client" == .* ]]; then
    echo "invalid client name: '$client' (no slashes or leading dots)"
    return 1
  fi
  if [[ -n "$project" && ( "$project" == */* || "$project" == .* ) ]]; then
    echo "invalid project name: '$project' (no slashes or leading dots)"
    return 1
  fi

  local root="${WORK:-$HOME/Work}/$client"
  if [[ -e "$root" ]]; then
    echo "already exists: $root"
    return 1
  fi

  # Rollback any partial scaffold on error / interrupt.
  trap "rm -rf ${(q)root}; trap - EXIT INT TERM" EXIT INT TERM

  mkdir -p "$root/doc/archive"
  [[ -n "$project" ]] && mkdir -p "$root/src/$project"

  cat >"$root/README.md" <<EOF
# $client

## Contacts

## Deliverables

## Links
EOF

  cat >"$root/CLAUDE.md" <<EOF
# CLAUDE.md — $client

Gig-level context. Not versioned. Sits above the repo boundary so nothing
here leaks on push. Per-project overrides live in \`src/<project>/CLAUDE.md\`.

## The gig
- Type:
- Started: $(date +%Y-%m-%d)
- Scope:

## Contacts
- {name} — {role} — {channel}

## Ticket system
- {Jira | Linear | GitHub Issues}: {URL}
- Prefix: \`{KEY-}\`

## Review
- Default reviewer: {@handle}
- PR body template: {URL}

## Docs
- \`doc/\` — see \`doc/README.md\` for conventions

---
> This dir isn't a repo — backups depend entirely on whatever backup layer
> covers \`~/Work\` (Time Machine, etc.). Verify before treating anything
> here as durable.
EOF

  cat >"$root/doc/README.md" <<'EOF'
# Documentation conventions

## Naming
- `{TICKET-KEY}_{topic}.md` — per-ticket working notes
- `{scope}_{topic}_{YYYY-MM-DD}.md` — dated snapshots (audits, reports, handoffs)
- `{scope}_{topic}.md` — living reference (component_inventory, active_tasks)
- `*.md.gpg` — encrypted (creds, tokens)

## Optional subdirs — create on demand
- `audits/`     — dated audit outputs (a11y, coverage, deps, i18n, perf, refactor)
- `reports/`    — with `_raw/`, `_raw_baseline_{date}/` for before/after
- `reviews/`    — code review notes
- `pr-drafts/`  — PR body drafts
- `screenshots/{figma,current,{ticket}/}` — reference images
- `scripts/`    — doc-related tooling
- `API doc/`    — external API references

## Rotation
- Move stale content into `archive/` on gig milestones.
- On long-running gigs, further split `archive/{YYYY}/` per year.

## Claude Code
- Client-level CLAUDE.md lives at `../CLAUDE.md`.
- Point Claude at specific docs with `@doc/{filename}` in prompts.
EOF

  cat >"$root/doc/active_tasks.md" <<EOF
# Active tasks — $client

_Living list. Add as work starts, prune as it lands._

## In flight

## Queued

## Blocked
EOF

  # All writes succeeded — disarm the rollback trap.
  trap - EXIT INT TERM

  echo "Scaffolded $root."
  echo ""
  echo "Next:"
  echo "  1. Set WORK_PROJECT_BASE in ~/.zshrc.local:"
  echo "     export WORK_PROJECT_BASE=\"$root${project:+/src/$project}\""
  if [[ -n "$project" ]]; then
    echo "  2. cd $root/src/$project && git clone|init as needed."
  else
    echo "  2. mkdir -p $root/src/<project> when ready to start on code."
  fi
}
