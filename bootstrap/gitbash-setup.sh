#!/bin/bash
# ============================================================================
# Git Bash Portable Setup Script
# ============================================================================
#
# This script sets up portable dotfiles configuration for Git Bash on Windows
# in corporate/restricted environments.
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/jeromefaria/dotfiles/master/bootstrap/gitbash-setup.sh)
#
# Or with custom dotfiles directory:
#   DOTFILES_DIR=~/code/dotfiles bash <(curl -fsSL ...)
#
# ============================================================================

set -e  # Exit on error

echo "=== Dotfiles Portable Setup for Git Bash on Windows ==="
echo ""

# ============================================================================
# 1. Verify Git Bash Environment
# ============================================================================

echo "Checking environment..."
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*)
    echo "✓ Git Bash detected ($(uname -s))"
    ;;
  *)
    echo "✗ Error: This script is designed for Git Bash on Windows"
    echo "  Detected: $(uname -s)"
    echo ""
    echo "For other platforms, use:"
    echo "  macOS/Linux: Run scripts/install.sh"
    exit 1
    ;;
esac
echo ""

# ============================================================================
# 2. Clone or Update Dotfiles Repository
# ============================================================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/jeromefaria/dotfiles.git}"

if [[ -d "$DOTFILES_DIR/.git" ]]; then
  echo "Updating existing dotfiles at $DOTFILES_DIR..."
  if ! (cd "$DOTFILES_DIR" && git pull); then
    echo "⚠  Warning: git pull failed, continuing with existing files"
  fi
else
  echo "Cloning dotfiles to $DOTFILES_DIR..."
  if ! git clone "$DOTFILES_REPO" "$DOTFILES_DIR"; then
    echo "✗ Error: Failed to clone dotfiles repository"
    echo "  Make sure you have git installed and internet access"
    exit 1
  fi
fi
echo ""

# ============================================================================
# 3. Backup Existing Configuration Files
# ============================================================================

echo "Backing up existing configuration files..."
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

backed_up=0
for file in .bashrc .vimrc .gitconfig; do
  if [[ -f "$HOME/$file" && ! -L "$HOME/$file" ]]; then
    cp "$HOME/$file" "$BACKUP_DIR/"
    echo "  Backed up: ~/$file"
    backed_up=1
  fi
done

if [[ $backed_up -eq 0 ]]; then
  rmdir "$BACKUP_DIR"
  echo "  No files to backup"
else
  echo "  Backups saved to: $BACKUP_DIR"
fi
echo ""

# ============================================================================
# 4. Create Symlinks
# ============================================================================

echo "Creating symlinks..."

# Bash configuration (essential)
if ln -sf "$DOTFILES_DIR/terminal/bash/bashrc.portable" "$HOME/.bashrc"; then
  echo "  ✓ ~/.bashrc → terminal/bash/bashrc.portable"
else
  echo "  ✗ Failed to link ~/.bashrc"
fi

# Vim configuration (optional, if vim is available)
if command -v vim &>/dev/null; then
  if [[ -f "$DOTFILES_DIR/editors/vim/vimrc.portable" ]]; then
    if ln -sf "$DOTFILES_DIR/editors/vim/vimrc.portable" "$HOME/.vimrc"; then
      echo "  ✓ ~/.vimrc → editors/vim/vimrc.portable"
    else
      echo "  ✗ Failed to link ~/.vimrc"
    fi
  fi
else
  echo "  ⊘ Skipping vim (not installed)"
fi

# Git configuration
if command -v git &>/dev/null; then
  # Check if portable version exists, otherwise use full version
  if [[ -f "$DOTFILES_DIR/git/gitconfig.portable" ]]; then
    gitconfig_src="$DOTFILES_DIR/git/gitconfig.portable"
    gitconfig_label="git/gitconfig.portable"
  else
    gitconfig_src="$DOTFILES_DIR/git/gitconfig"
    gitconfig_label="git/gitconfig"
  fi

  if ln -sf "$gitconfig_src" "$HOME/.gitconfig"; then
    echo "  ✓ ~/.gitconfig → $gitconfig_label"
  else
    echo "  ✗ Failed to link ~/.gitconfig"
  fi
fi
echo ""

# ============================================================================
# 5. Install vim-plug (if vim is available)
# ============================================================================

if command -v vim &>/dev/null; then
  echo "Setting up vim-plug..."
  if [[ ! -f "$HOME/.vim/autoload/plug.vim" ]]; then
    echo "  Installing vim-plug..."
    if curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim 2>/dev/null; then
      echo "  ✓ vim-plug installed"
      echo "  Run :PlugInstall in vim to install plugins"
    else
      echo "  ⚠  Warning: Failed to install vim-plug (network issue?)"
      echo "     You can install it manually later"
    fi
  else
    echo "  ✓ vim-plug already installed"
  fi
  echo ""
fi

# ============================================================================
# 6. Detect Corporate SSL/Proxy Issues
# ============================================================================

echo "Checking for corporate proxy/SSL issues..."
if command -v curl &>/dev/null; then
  if curl -sI https://registry.npmjs.org > /dev/null 2>&1; then
    echo "  ✓ Network connectivity OK"
  else
    echo "  ⚠  Corporate SSL/proxy detected!"
    echo ""
    echo "  If you encounter SSL errors with npm or git, run:"
    echo ""
    echo "    # For npm"
    echo "    npm config set strict-ssl false"
    echo ""
    echo "    # For git (use with caution)"
    echo "    git config --global http.sslVerify false"
    echo ""
  fi
else
  echo "  ⊘ curl not available, skipping network check"
fi
echo ""

# ============================================================================
# 7. Report What's Available
# ============================================================================

echo "=== Setup Complete ==="
echo ""
echo "Configuration loaded:"
echo "  • bashrc.portable (732 lines)"
echo "    - Git-aware prompt with branch display"
echo "    - 40+ git aliases (ga, gc, gco, gd, gp, etc.)"
echo "    - 20+ portable functions (server, extract, qf, qg)"
echo "    - Platform-aware clipboard and file operations"
if command -v vim &>/dev/null; then
echo "  • vimrc.portable (832 lines)"
echo "    - CoC.nvim support (if Node.js available)"
echo "    - Pure Vimscript plugins only"
fi
echo ""

# Check for Node.js
if command -v node &>/dev/null && command -v npm &>/dev/null; then
  echo "Node.js detected: $(node --version)"
  echo "  • 30+ npm shortcuts enabled (ni, nrs, nrd, nrb, nrt)"
  echo "  • Package utilities (nscripts, nsetup, nclean)"
  echo "  • JSON formatting (cat file.json | json)"
else
  echo "Node.js not detected"
  echo "  Install Node.js to enable npm shortcuts and utilities"
fi
echo ""

echo "Next steps:"
echo "  1. Reload shell:  source ~/.bashrc"
echo "     Or restart Git Bash"
echo ""
echo "  2. Customize (optional):"
echo "     Edit ~/.bashrc.local for machine-specific overrides"
echo "     Edit ~/.gitconfig.local for git name/email"
echo ""
echo "  3. Learn shortcuts:"
echo "     alias | grep git    # See all git aliases"
echo "     nscripts            # Show npm scripts (if Node.js available)"
echo ""
echo "Documentation:"
echo "  • Full features: $DOTFILES_DIR/terminal/bash/bashrc.portable"
echo "  • Vim guide: $DOTFILES_DIR/editors/vim/README.md"
echo ""
