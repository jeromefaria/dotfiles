#!/bin/bash

################################################################################
# Dotfiles Installation Script
#
# This script automates the installation and configuration of dotfiles.
# It creates backups of existing files and symlinks dotfiles to the home directory.
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
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

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

# Check if running on macOS
check_os() {
  if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only."
    exit 1
  fi
  print_success "Running on macOS"
}

# Check if Homebrew is installed
check_homebrew() {
  print_header "Checking Dependencies"

  if ! command -v brew &> /dev/null; then
    print_warning "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    print_success "Homebrew installed"
  else
    print_success "Homebrew is already installed"
  fi
}

# Create backup directory
create_backup_dir() {
  if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    print_success "Created backup directory: $BACKUP_DIR"
  fi
}

# Backup existing file
backup_file() {
  local file=$1
  local filename=$(basename "$file")

  if [ -e "$file" ] && [ ! -L "$file" ]; then
    cp -r "$file" "$BACKUP_DIR/$filename"
    print_info "Backed up: $filename"
    return 0
  fi
  return 1
}

# Create symlink
create_symlink() {
  local source=$1
  local target=$2

  # Remove existing symlink or file
  if [ -e "$target" ] || [ -L "$target" ]; then
    backup_file "$target"
    rm -rf "$target"
  fi

  ln -s "$source" "$target"
  print_success "Linked: $(basename "$target")"
}

# Install Oh My Zsh
install_oh_my_zsh() {
  print_header "Installing Oh My Zsh"

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh My Zsh installed"
  else
    print_success "Oh My Zsh is already installed"
  fi

  # Install ZSH plugins
  local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  # zsh-syntax-highlighting
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    print_info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    print_success "zsh-syntax-highlighting installed"
  fi

  # zsh-autosuggestions
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    print_info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    print_success "zsh-autosuggestions installed"
  fi
}

# Install Vim Plug (for Vim only, not Neovim)
install_vim_plug() {
  print_header "Installing Vim Plug"

  if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    print_info "Installing vim-plug for Vim..."
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    print_success "vim-plug installed"
  else
    print_success "vim-plug is already installed"
  fi

  print_info "Neovim uses lazy.nvim (no manual installation required)"
}

# Install Tmux Plugin Manager
install_tpm() {
  print_header "Installing Tmux Plugin Manager"

  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    print_info "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    print_success "TPM installed"
  else
    print_success "TPM is already installed"
  fi
}

# Link dotfiles
link_dotfiles() {
  print_header "Linking Dotfiles"

  create_backup_dir

  # Main dotfiles (organized by category)
  create_symlink "$DOTFILES_DIR/shell/zshrc" "$HOME/.zshrc"
  create_symlink "$DOTFILES_DIR/editors/vim/vimrc" "$HOME/.vimrc"
  create_symlink "$DOTFILES_DIR/terminal/tmux.conf" "$HOME/.tmux.conf"
  create_symlink "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"

  # Vim directory (separate from Neovim for systems without Neovim)
  if [ ! -d "$HOME/.vim" ]; then
    mkdir -p "$HOME/.vim"
  fi
  create_symlink "$DOTFILES_DIR/editors/vim" "$HOME/.vim/config"

  # Create .config directory if it doesn't exist
  if [ ! -d "$HOME/.config" ]; then
    mkdir -p "$HOME/.config"
  fi

  # XDG-compliant configs - symlink individual directories from config/
  print_info "Linking XDG-compliant configurations..."

  # Symlink each config directory/file individually
  local config_items=(
    "nvim"
    "starship.toml"
    "aria2"
    "bat"
    "beets"
    "gh"
    "mpv"
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
    local source="$DOTFILES_DIR/config/$item"
    local target="$HOME/.config/$item"

    # Only create symlink if source exists
    if [ -e "$source" ] || [ -L "$source" ]; then
      create_symlink "$source" "$target"
    fi
  done

  # Handle mail configuration separately (moved to mail/ directory)
  if [ -e "$DOTFILES_DIR/mail/mutt" ]; then
    create_symlink "$DOTFILES_DIR/mail/mutt" "$HOME/.config/neomutt"
  fi

  print_success "All dotfiles linked successfully"
}

# Install packages from Brewfile
install_packages() {
  print_header "Installing Packages"

  read -p "Do you want to install packages from Brewfile? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Installing Homebrew packages..."
    cd "$DOTFILES_DIR/packages"
    brew bundle install
    print_success "Packages installed"
  else
    print_info "Skipping package installation"
  fi
}

# Apply macOS settings
apply_macos_settings() {
  print_header "macOS System Settings"

  read -p "Do you want to apply macOS system settings? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_warning "This will modify system settings. Review $DOTFILES_DIR/scripts/macos-setup.sh before proceeding."
    read -p "Continue? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      print_info "Applying macOS settings..."
      bash "$DOTFILES_DIR/scripts/macos-setup.sh"
      print_success "macOS settings applied"
      print_warning "Some changes may require a logout or restart"
    fi
  else
    print_info "Skipping macOS settings"
  fi
}

# Set ZSH as default shell
set_zsh_shell() {
  print_header "Setting Default Shell"

  if [ "$SHELL" != "$(which zsh)" ]; then
    print_info "Setting ZSH as default shell..."
    chsh -s "$(which zsh)"
    print_success "ZSH set as default shell"
    print_warning "Restart your terminal for changes to take effect"
  else
    print_success "ZSH is already the default shell"
  fi
}

# Main installation flow
main() {
  clear

  echo -e "${BLUE}"
  echo "╔═══════════════════════════════════════════════════════════╗"
  echo "║                                                           ║"
  echo "║              Dotfiles Installation Script                ║"
  echo "║                                                           ║"
  echo "╚═══════════════════════════════════════════════════════════╝"
  echo -e "${NC}\n"

  check_os
  check_homebrew
  install_oh_my_zsh
  install_vim_plug
  install_tpm
  link_dotfiles
  install_packages
  apply_macos_settings
  set_zsh_shell

  print_header "Installation Complete!"

  if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR")" ]; then
    print_info "Backups saved to: $BACKUP_DIR"
  fi

  echo -e "\n${GREEN}✨ Your dotfiles have been installed successfully!${NC}\n"
  echo -e "Next steps:"
  echo -e "  1. Restart your terminal"
  echo -e "  2. For Vim: Run ${BLUE}:PlugInstall${NC} to install plugins"
  echo -e "  3. For Neovim: Plugins will auto-install with ${BLUE}lazy.nvim${NC} on first launch"
  echo -e "  4. Open tmux and press ${BLUE}prefix + I${NC} to install tmux plugins"
  echo -e "  5. Enjoy your new environment! 🚀\n"
}

# Run main installation
main
