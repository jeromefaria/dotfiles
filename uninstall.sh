#!/bin/bash

################################################################################
# Dotfiles Uninstallation Script
#
# This script removes symlinks created by the installation script.
# It does NOT remove installed packages or applications.
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="$HOME/dotfiles"

# Print colored output
print_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_header() {
  echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

# Remove symlink if it exists and points to dotfiles
remove_symlink() {
  local link=$1
  local expected_target=$2

  if [ -L "$link" ]; then
    local current_target=$(readlink "$link")
    # Check if symlink points to our dotfiles
    if [[ "$current_target" == *"$DOTFILES_DIR"* ]] || [[ "$current_target" == "$expected_target" ]]; then
      rm "$link"
      print_success "Removed: $link"
      return 0
    else
      print_warning "Skipped (points elsewhere): $link -> $current_target"
      return 1
    fi
  elif [ -e "$link" ]; then
    print_warning "Skipped (not a symlink): $link"
    return 1
  else
    print_info "Not found: $link"
    return 1
  fi
}

# Unlink main dotfiles
unlink_dotfiles() {
  print_header "Removing Dotfile Symlinks"

  # Main dotfiles
  remove_symlink "$HOME/.zshrc" "$DOTFILES_DIR/zshrc"
  remove_symlink "$HOME/.vimrc" "$DOTFILES_DIR/vimrc"
  remove_symlink "$HOME/.tmux.conf" "$DOTFILES_DIR/tmux.conf"
  remove_symlink "$HOME/.gitconfig" "$DOTFILES_DIR/gitconfig"

  # Vim config directory
  remove_symlink "$HOME/.vim/config" "$DOTFILES_DIR/vim"

  print_success "Main dotfiles unlinked"
}

# Unlink XDG config files
unlink_config_files() {
  print_header "Removing XDG Config Symlinks"

  local config_items=(
    "nvim"
    "starship.toml"
    "aria2"
    "bat"
    "beets"
    "gh"
    "mpv"
    "mutt"
    "musikcube"
    "ncmpcpp"
    "neofetch"
    "ranger"
    "skhd"
    "tmuxinator"
    "yabai"
    "yarn"
  )

  for item in "${config_items[@]}"; do
    remove_symlink "$HOME/.config/$item" "$DOTFILES_DIR/config/$item"
  done

  print_success "XDG config files unlinked"
}

# Main uninstallation flow
main() {
  clear

  echo -e "${BLUE}"
  echo "╔═══════════════════════════════════════════════════════════╗"
  echo "║                                                           ║"
  echo "║            Dotfiles Uninstallation Script                ║"
  echo "║                                                           ║"
  echo "╚═══════════════════════════════════════════════════════════╝"
  echo -e "${NC}\n"

  print_warning "This will remove symlinks to your dotfiles."
  print_warning "Your actual dotfiles in $DOTFILES_DIR will NOT be deleted."
  print_warning "Installed packages and applications will NOT be removed."
  echo

  read -p "Do you want to continue? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Uninstallation cancelled"
    exit 0
  fi

  unlink_dotfiles
  unlink_config_files

  print_header "Uninstallation Complete!"

  echo -e "\n${GREEN}✓ Dotfile symlinks have been removed${NC}\n"
  echo -e "Note:"
  echo -e "  - Your dotfiles repository at ${BLUE}$DOTFILES_DIR${NC} is unchanged"
  echo -e "  - Installed packages and applications remain on your system"
  echo -e "  - Oh My Zsh, Homebrew, and other tools are still installed"
  echo -e "  - Check for backup directories in your home folder if needed\n"
}

# Run main uninstallation
main
