#!/bin/bash
# ============================================================================
# Shared Configuration for Dotfiles Scripts
# ============================================================================
# This file defines common configurations used across multiple scripts.
# Source this file at the beginning of scripts: source "$(dirname "$0")/config.sh"
# ============================================================================

# Dotfiles directory location
# Repo root, derived from this script's own location so the checkout works from
# any directory. An explicit DOTFILES_DIR still wins, which is how bootstrap.sh
# hands down its --dir value.
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Required system commands
REQUIRED_COMMANDS=(
  "git"
  "curl"
  "zsh"
)

# Optional but recommended commands
OPTIONAL_COMMANDS=(
  "brew"
  "nvim"
  "tmux"
)

# ============================================================================
# Symlink Definitions — deliberately absent
# ============================================================================
# This file used to carry HOME_SYMLINKS, CONFIG_SYMLINKS and ALL_SYMLINKS
# arrays describing every link the installer creates. Nothing ever read them:
# install.sh declares its own list inline, so the arrays here were a second
# source of truth that silently drifted out of agreement with the first — by
# the time they were removed they still named ncmpcpp, neofetch, ranger and
# yarn (none of which exist in config/) and pointed .config/nvim at
# editors/neovim rather than config/nvim. A stale map of the filesystem is
# worse than no map, because it reads like documentation. If this ever needs to
# be shared, move install.sh's list here and have install.sh source it, so
# there is exactly one definition.

# ============================================================================
# Color Output Functions — provided by lib/io.sh
# ============================================================================
source "$(dirname "${BASH_SOURCE[0]}")/lib/io.sh"

# ============================================================================
# Helper Functions
# ============================================================================

# Check if command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Check if we're on macOS
is_macos() {
  [[ "$OSTYPE" == "darwin"* ]]
}

# Get current timestamp for backups
get_timestamp() {
  date +"%Y%m%d-%H%M%S"
}

# ============================================================================
# Validation Functions
# ============================================================================

# Validate dotfiles directory exists
validate_dotfiles_dir() {
  if [ ! -d "$DOTFILES_DIR" ]; then
    print_error "Dotfiles directory not found: $DOTFILES_DIR"
    return 1
  fi

  if [ ! -d "$DOTFILES_DIR/.git" ]; then
    print_warning "Dotfiles directory is not a git repository"
  fi

  return 0
}

# Check all required commands are available
check_required_commands() {
  local missing=()

  for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if ! command_exists "$cmd"; then
      missing+=("$cmd")
    fi
  done

  if [ ${#missing[@]} -gt 0 ]; then
    print_error "Missing required commands: ${missing[*]}"
    print_info "Please install missing commands and try again"
    return 1
  fi

  return 0
}

# Check optional commands
check_optional_commands() {
  local missing=()

  for cmd in "${OPTIONAL_COMMANDS[@]}"; do
    if ! command_exists "$cmd"; then
      missing+=("$cmd")
    fi
  done

  if [ ${#missing[@]} -gt 0 ]; then
    print_warning "Optional commands not found: ${missing[*]}"
    print_info "Installation will continue, but some features may not work"
  fi

  return 0
}

# ============================================================================
# Export Functions for Use in Other Scripts
# ============================================================================

export -f command_exists
export -f is_macos
export -f get_timestamp
export -f print_header
export -f print_success
export -f print_error
export -f print_warning
export -f print_info
export -f print_step
export -f validate_dotfiles_dir
export -f check_required_commands
export -f check_optional_commands
