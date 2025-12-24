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

# Execute command with error handling
execute() {
    local cmd="$1"
    local error_msg="${2:-Command failed}"

    if ! eval "$cmd" 2>/dev/null; then
        log_warning "$error_msg"
        return 1
    fi
    return 0
}

# Safely set a default value
safe_defaults_write() {
    local domain="$1"
    local key="$2"
    local type="$3"
    local value="$4"

    if defaults write "$domain" "$key" -"$type" "$value" 2>/dev/null; then
        return 0
    else
        log_warning "Could not set $domain $key"
        return 1
    fi
}

# Safely read a default value
safe_defaults_read() {
    local domain="$1"
    local key="$2"
    local default="${3:-(not set)}"

    defaults read "$domain" "$key" 2>/dev/null || echo "$default"
}

# Create directory if it doesn't exist
ensure_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
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
    local current_version=$(get_macos_major_version)

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
export -f execute
export -f safe_defaults_write
export -f safe_defaults_read
export -f ensure_dir
export -f backup_file
export -f print_separator
export -f print_header
export -f print_completion
export -f check_macos_version
export -f request_sudo
