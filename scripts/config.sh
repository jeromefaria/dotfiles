#!/bin/bash
# ============================================================================
# Shared Configuration for Dotfiles Scripts
# ============================================================================
# This file defines common configurations used across multiple scripts.
# Source this file at the beginning of scripts: source "$(dirname "$0")/config.sh"
# ============================================================================

# Dotfiles directory location
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# Backup directory pattern
BACKUP_DIR_PREFIX="$HOME/.dotfiles-backup"

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
# Symlink Definitions
# ============================================================================
# Format: "target:source_relative_to_dotfiles"
# Target is the symlink location, source is relative to $DOTFILES_DIR

# Home directory symlinks
HOME_SYMLINKS=(
  "$HOME/.zshrc:shell/zshrc"
  "$HOME/.vimrc:editors/vim/vimrc"
  "$HOME/.tmux.conf:terminal/tmux.conf"
  "$HOME/.gitconfig:git/gitconfig"
)

# XDG config directory symlinks
CONFIG_SYMLINKS=(
  "$HOME/.config/nvim:editors/neovim"
  "$HOME/.config/starship.toml:config/starship.toml"
  "$HOME/.config/aria2:config/aria2"
  "$HOME/.config/bat:config/bat"
  "$HOME/.config/beets:config/beets"
  "$HOME/.config/gh:config/gh"
  "$HOME/.config/mpv:config/mpv"
  "$HOME/.config/neomutt:mail/mutt"
  "$HOME/.config/musikcube:config/musikcube"
  "$HOME/.config/ncmpcpp:config/ncmpcpp"
  "$HOME/.config/neofetch:config/neofetch"
  "$HOME/.config/ranger:config/ranger"
  "$HOME/.config/skhd:config/skhd"
  "$HOME/.config/tmuxinator:config/tmuxinator"
  "$HOME/.config/yabai:config/yabai"
  "$HOME/.config/yarn:config/yarn"
)

# All symlinks combined
ALL_SYMLINKS=("${HOME_SYMLINKS[@]}" "${CONFIG_SYMLINKS[@]}")

# ============================================================================
# Color Output Functions
# ============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print functions
print_header() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

print_step() {
  echo -e "${CYAN}→${NC} $1"
}

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
