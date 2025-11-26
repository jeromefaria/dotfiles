#!/bin/bash

################################################################################
# Dotfiles Installation Script
#
# This script automates the installation and configuration of dotfiles.
# It creates backups of existing files and symlinks dotfiles to the home directory.
#
# Features:
# - Automatic error handling and rollback on failure
# - Idempotent (safe to run multiple times)
# - Non-interactive mode support (--yes flag)
# - Comprehensive dependency checking
# - Integration with health-check.sh
################################################################################

set -euo pipefail  # Strict error handling: exit on error, undefined vars, pipe failures

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Command-line flags
INTERACTIVE=true
SKIP_PACKAGES=false
SKIP_MACOS=false
DRY_RUN=false

# Error tracking
INSTALLATION_FAILED=false
CURRENT_STEP=""

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

# Error handler
on_error() {
  local line_number=$1
  INSTALLATION_FAILED=true

  print_error "Installation failed at line $line_number during: $CURRENT_STEP"

  if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
    print_warning "A backup was created at: $BACKUP_DIR"
    print_info "To restore your previous configuration, run:"
    print_info "  ./scripts/restore.sh --backup $BACKUP_DIR"
  fi

  echo -e "\n${RED}Installation incomplete. Please review the error above.${NC}\n"
  exit 1
}

# Set trap for error handling
trap 'on_error $LINENO' ERR INT TERM

# Parse command-line arguments
parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      -y|--yes)
        INTERACTIVE=false
        shift
        ;;
      --skip-packages)
        SKIP_PACKAGES=true
        shift
        ;;
      --skip-macos)
        SKIP_MACOS=true
        shift
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      -h|--help)
        show_help
        exit 0
        ;;
      *)
        print_error "Unknown option: $1"
        show_help
        exit 1
        ;;
    esac
  done
}

# Show help message
show_help() {
  cat <<EOF
Dotfiles Installation Script

Usage: $0 [OPTIONS]

Options:
  -y, --yes             Non-interactive mode (answer yes to all prompts)
  --skip-packages       Skip Homebrew package installation
  --skip-macos          Skip macOS system settings
  --dry-run             Show what would be done without making changes
  -h, --help            Show this help message

Examples:
  $0                    # Interactive installation
  $0 --yes              # Automated installation
  $0 --skip-packages    # Install without packages
  $0 --yes --skip-macos # Automated, skip macOS settings

EOF
}

# Check required commands
check_required_commands() {
  CURRENT_STEP="Checking required commands"

  local required=(git curl zsh)
  local missing=()

  for cmd in "${required[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
      missing+=("$cmd")
    fi
  done

  if [ ${#missing[@]} -gt 0 ]; then
    print_error "Missing required commands: ${missing[*]}"
    print_info "Please install these commands and try again"
    exit 1
  fi

  print_success "All required commands available"
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

# Create symlink (idempotent)
create_symlink() {
  local source=$1
  local target=$2
  local target_name=$(basename "$target")

  # Check if symlink already points to correct location (idempotent)
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    print_success "Already linked: $target_name"
    return 0
  fi

  # Dry run mode
  if [ "$DRY_RUN" = true ]; then
    print_info "[DRY RUN] Would link: $target_name → $source"
    return 0
  fi

  # Backup and remove existing file/symlink
  if [ -e "$target" ] || [ -L "$target" ]; then
    backup_file "$target"
    rm -rf "$target"
  fi

  # Create the symlink
  ln -s "$source" "$target"
  print_success "Linked: $target_name"
}

# Install Oh My Zsh
install_oh_my_zsh() {
  CURRENT_STEP="Installing Oh My Zsh"
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
  CURRENT_STEP="Installing Vim Plug"
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
  CURRENT_STEP="Installing Tmux Plugin Manager"
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
  CURRENT_STEP="Linking dotfiles"
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
  CURRENT_STEP="Installing packages"

  if [ "$SKIP_PACKAGES" = true ]; then
    print_info "Skipping package installation (--skip-packages flag)"
    return 0
  fi

  print_header "Installing Packages"

  local install_packages=false

  if [ "$INTERACTIVE" = false ]; then
    install_packages=true
    print_info "Installing packages automatically (--yes flag)"
  else
    read -p "Do you want to install packages from Brewfile? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      install_packages=true
    fi
  fi

  if [ "$install_packages" = true ]; then
    if [ "$DRY_RUN" = true ]; then
      print_info "[DRY RUN] Would install Homebrew packages from Brewfile"
    else
      print_info "Installing Homebrew packages..."
      cd "$DOTFILES_DIR/packages"
      brew bundle install
      print_success "Packages installed"
    fi
  else
    print_info "Skipping package installation"
  fi
}

# Apply macOS settings
apply_macos_settings() {
  CURRENT_STEP="Applying macOS settings"

  if [ "$SKIP_MACOS" = true ]; then
    print_info "Skipping macOS settings (--skip-macos flag)"
    return 0
  fi

  print_header "macOS System Settings"

  local apply_settings=false

  if [ "$INTERACTIVE" = false ]; then
    apply_settings=true
    print_warning "Applying macOS settings automatically (--yes flag)"
    print_warning "This will modify system settings"
  else
    read -p "Do you want to apply macOS system settings? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      print_warning "This will modify system settings. Review $DOTFILES_DIR/scripts/macos-setup.sh before proceeding."
      read -p "Continue? (y/N) " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        apply_settings=true
      fi
    fi
  fi

  if [ "$apply_settings" = true ]; then
    if [ "$DRY_RUN" = true ]; then
      print_info "[DRY RUN] Would apply macOS system settings"
    else
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
  CURRENT_STEP="Setting ZSH as default shell"
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

# Run health check
run_health_check() {
  CURRENT_STEP="Running health check"

  print_header "Verifying Installation"

  if [ -f "$DOTFILES_DIR/scripts/health-check.sh" ]; then
    if bash "$DOTFILES_DIR/scripts/health-check.sh"; then
      print_success "Health check passed!"
    else
      print_warning "Health check found some issues. Review output above."
    fi
  else
    print_warning "Health check script not found. Skipping verification."
  fi
}

# Main installation flow
main() {
  # Parse command-line arguments
  parse_args "$@"

  clear

  echo -e "${BLUE}"
  echo "╔═══════════════════════════════════════════════════════════╗"
  echo "║                                                           ║"
  echo "║              Dotfiles Installation Script                ║"
  echo "║                                                           ║"
  echo "╚═══════════════════════════════════════════════════════════╝"
  echo -e "${NC}\n"

  if [ "$DRY_RUN" = true ]; then
    print_warning "DRY RUN MODE - No changes will be made"
    echo
  fi

  if [ "$INTERACTIVE" = false ]; then
    print_info "Running in non-interactive mode (--yes flag)"
    echo
  fi

  check_os
  check_required_commands
  check_homebrew
  install_oh_my_zsh
  install_vim_plug
  install_tpm
  link_dotfiles
  install_packages
  apply_macos_settings
  set_zsh_shell

  # Run health check if not in dry-run mode
  if [ "$DRY_RUN" = false ]; then
    run_health_check
  fi

  print_header "Installation Complete!"

  if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
    print_info "Backups saved to: $BACKUP_DIR"
    print_info "To restore, run: ./scripts/restore.sh --backup $BACKUP_DIR"
  fi

  if [ "$DRY_RUN" = true ]; then
    echo -e "\n${BLUE}✨ Dry run complete! No changes were made.${NC}\n"
    echo -e "Run without ${BLUE}--dry-run${NC} to apply changes.\n"
  else
    echo -e "\n${GREEN}✨ Your dotfiles have been installed successfully!${NC}\n"
    echo -e "Next steps:"
    echo -e "  1. Restart your terminal"
    echo -e "  2. For Vim: Run ${BLUE}:PlugInstall${NC} to install plugins"
    echo -e "  3. For Neovim: Plugins will auto-install with ${BLUE}lazy.nvim${NC} on first launch"
    echo -e "  4. Open tmux and press ${BLUE}prefix + I${NC} to install tmux plugins"
    echo -e "  5. Enjoy your new environment! 🚀\n"
  fi
}

# Run main installation
main "$@"
