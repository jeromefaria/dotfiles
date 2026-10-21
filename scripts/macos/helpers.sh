#!/usr/bin/env bash
#
# Helper functions for macOS configuration scripts
# Provides consistent logging, error handling, and utilities
#

# Colors for output
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export MAGENTA='\033[0;35m'
export CYAN='\033[0;36m'
export NC='\033[0m' # No Color

# ============================================================================
# Dry run
# ============================================================================
# These modules apply 192 `defaults write` calls plus systemsetup, pmset,
# scutil, nvram and friends. Until now there was no way to see what they would
# do without doing it, which is a poor property for the one part of this repo
# that rewrites system preferences with no undo.
#
# Rather than edit 192 call sites, the mutating commands are shadowed by shell
# functions. Every module sources this file, so the shadows are in scope for
# all of them, and each call site stays exactly as it reads today.
#
# `sudo` is shadowed for the same reason: it execs the real binary, so a
# function named `defaults` cannot intercept `sudo defaults write`. In a dry
# run nothing needs root, so the whole call is reported and skipped.
#
# Reads pass through, because some logic branches on current state and a
# dry run that lies about what is set would be worse than none.

MACOS_DRY_RUN="${MACOS_DRY_RUN:-0}"

macos_dry_run() {
    [ "$MACOS_DRY_RUN" = "1" ]
}

# Report a skipped mutation, and record it where the caller can count it.
#
# The modules run as separate bash processes, so a shell variable incremented
# here cannot be read back by macos-setup.sh — the first version of this
# reported 4 skips out of 95 for exactly that reason. A file shared via the
# environment is the simplest thing that actually counts.
_macos_skip() {
    if [ -n "${MACOS_DRY_RUN_TALLY:-}" ]; then
        echo "$*" >> "$MACOS_DRY_RUN_TALLY" 2>/dev/null || true
    fi
    echo -e "${YELLOW}[DRY RUN]${NC} $*"
}

# How many mutations have been reported so far.
macos_dry_run_count() {
    if [ -n "${MACOS_DRY_RUN_TALLY:-}" ] && [ -f "$MACOS_DRY_RUN_TALLY" ]; then
        wc -l < "$MACOS_DRY_RUN_TALLY" | tr -d ' '
    else
        echo 0
    fi
}

defaults() {
    if macos_dry_run; then
        case "${1:-}" in
            write|delete|import|rename)
                _macos_skip "defaults $*"
                return 0
                ;;
        esac
    fi
    command defaults "$@"
}

sudo() {
    if macos_dry_run; then
        _macos_skip "sudo $*"
        return 0
    fi
    command sudo "$@"
}

# systemsetup is the one of these with reads worth preserving (-get*).
systemsetup() {
    if macos_dry_run; then
        case "${1:-}" in
            -get*) ;;
            *)
                _macos_skip "systemsetup $*"
                return 0
                ;;
        esac
    fi
    command systemsetup "$@"
}

# scutil reads the machine's names with --get and sets them with --set. The
# reads feed the "Computer:" lines in the summary, so swallowing them made a
# dry run misreport the current hostname rather than just the pending change.
scutil() {
    if macos_dry_run; then
        case "${1:-}" in
            --get) ;;
            *)
                _macos_skip "scutil $*"
                return 0
                ;;
        esac
    fi
    command scutil "$@"
}

# The rest appear only as mutations in the apply modules.
for _macos_cmd in killall pmset nvram mdutil chflags spctl diskutil; do
    eval "
${_macos_cmd}() {
    if macos_dry_run; then
        _macos_skip \"${_macos_cmd} \$*\"
        return 0
    fi
    command ${_macos_cmd} \"\$@\"
}
"
done
unset _macos_cmd

# Logging functions
log_section() {
    echo ""
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}▶ $1${NC}"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

log_info() {
    echo -e "${BLUE}  ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}  ✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}  ⚠${NC} $1"
}

log_error() {
    echo -e "${RED}  ✗${NC} $1"
}

log_skip() {
    echo -e "${CYAN}  ⊘${NC} $1"
}

# Ask for confirmation
confirm() {
    local prompt="$1"
    local default="${2:-n}"

    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n] "
    else
        prompt="$prompt [y/N] "
    fi

    read -p "$prompt" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    elif [[ $REPLY =~ ^[Nn]$ ]]; then
        return 1
    else
        # Use default
        [[ "$default" == "y" ]] && return 0 || return 1
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if application is installed
app_installed() {
    [ -d "/Applications/$1.app" ] || [ -d "$HOME/Applications/$1.app" ]
}

# Get macOS version
get_macos_version() {
    sw_vers -productVersion
}

# Get major macOS version (e.g., 13 for Ventura)
get_macos_major_version() {
    sw_vers -productVersion | cut -d '.' -f 1
}

# Check if running on macOS
is_macos() {
    [[ "$OSTYPE" == "darwin"* ]]
}

# Kill an application safely
safe_killall() {
    local app="$1"
    if pgrep -x "$app" > /dev/null; then
        log_info "Restarting $app..."
        killall "$app" >/dev/null 2>&1 || true
    fi
}

# Backup a file before modifying
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        cp "$file" "${file}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
}

# Print a separator line
print_separator() {
    echo -e "${NC}────────────────────────────────────────────────────────────────${NC}"
}

# Print script header
print_header() {
    local title="$1"
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                                ║${NC}"
    printf "${CYAN}║${NC}%-64s${CYAN}║${NC}\n" "$(printf "%*s" $(( (64 + ${#title}) / 2)) "$title" | sed 's/^/ /')"
    echo -e "${CYAN}║                                                                ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Print completion message
print_completion() {
    local message="${1:-Configuration complete!}"
    echo ""
    print_separator
    log_success "$message"
    print_separator
    echo ""
}

# Validate macOS version
check_macos_version() {
    local min_version="${1:-11}"  # Default to Big Sur (11)
    local current_version
    current_version=$(get_macos_major_version)

    if [ "$current_version" -lt "$min_version" ]; then
        log_warning "Some settings may not work on macOS versions older than $min_version"
        log_warning "Current version: $(get_macos_version)"
        return 1
    fi
    return 0
}

# Request sudo and keep it alive
request_sudo() {
    log_info "Requesting administrator privileges..."
    sudo -v

    # Keep-alive: update existing `sudo` time stamp until script finishes
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null &
}

# Export functions so they're available in sourced scripts
export -f log_section
export -f log_info
export -f log_success
export -f log_warning
export -f log_error
export -f log_skip
export -f confirm
export -f command_exists
export -f app_installed
export -f get_macos_version
export -f get_macos_major_version
export -f is_macos
export -f safe_killall
export -f backup_file
export -f print_separator
export -f print_header
export -f print_completion
export -f check_macos_version
export -f request_sudo
