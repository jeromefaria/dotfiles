#!/bin/bash
# ============================================================================
# Dotfiles Bootstrap Script
# ============================================================================
# This script provides a one-liner installation method for the dotfiles.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/USER/dotfiles/master/scripts/bootstrap.sh | bash
#
# Or with custom options:
#   curl -fsSL https://raw.githubusercontent.com/USER/dotfiles/master/scripts/bootstrap.sh | bash -s -- --yes
# ============================================================================

set -e

# Configuration
REPO_URL="${DOTFILES_REPO:-https://github.com/jeromefaria/dotfiles.git}"
INSTALL_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
BRANCH="${DOTFILES_BRANCH:-master}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Print functions
print_header() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }

# Error handler
error_exit() {
  print_error "$1"
  exit 1
}

# Main bootstrap function
main() {
  print_header "Dotfiles Bootstrap"

  echo ""
  print_info "This script will:"
  echo "  1. Check system requirements"
  echo "  2. Clone dotfiles repository to $INSTALL_DIR"
  echo "  3. Run the installation script"
  echo ""

  # Check if we're on macOS
  if [[ "$OSTYPE" != "darwin"* ]]; then
    error_exit "This script is designed for macOS only"
  fi

  print_success "Running on macOS"

  # Check for required commands
  print_header "Checking Requirements"

  local missing=()

  for cmd in git curl zsh; do
    if command -v "$cmd" &> /dev/null; then
      print_success "$cmd is installed"
    else
      missing+=("$cmd")
      print_error "$cmd is not installed"
    fi
  done

  if [ ${#missing[@]} -gt 0 ]; then
    error_exit "Please install missing requirements: ${missing[*]}"
  fi

  # Check if install directory already exists
  if [ -d "$INSTALL_DIR" ]; then
    print_warning "Directory $INSTALL_DIR already exists"

    if [ -d "$INSTALL_DIR/.git" ]; then
      print_info "Existing installation detected"
      read -p "Update existing installation? (y/N) " -n 1 -r
      echo

      if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Updating repository..."
        cd "$INSTALL_DIR"
        git pull origin "$BRANCH" || error_exit "Failed to update repository"
        print_success "Repository updated"
      else
        print_info "Skipping update, using existing installation"
      fi
    else
      error_exit "Directory exists but is not a git repository. Please remove it or choose a different location."
    fi
  else
    # Clone the repository
    print_header "Cloning Repository"
    print_info "Cloning from: $REPO_URL"
    print_info "Installing to: $INSTALL_DIR"

    if ! git clone "$REPO_URL" "$INSTALL_DIR"; then
      error_exit "Failed to clone repository"
    fi

    print_success "Repository cloned successfully"
  fi

  # Run the installation script
  print_header "Running Installation"

  cd "$INSTALL_DIR"

  # Check if install script exists
  if [ ! -f "scripts/install.sh" ]; then
    error_exit "Installation script not found: scripts/install.sh"
  fi

  # Make install script executable
  chmod +x scripts/install.sh

  # Pass any arguments to the install script
  print_info "Starting installation..."
  echo ""

  if bash scripts/install.sh "$@"; then
    print_header "Bootstrap Complete!"
    print_success "Dotfiles installed successfully"
    echo ""
    print_info "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Review the configuration in: $INSTALL_DIR"
    echo "  3. Run health check: $INSTALL_DIR/scripts/health-check.sh"
    echo ""
  else
    error_exit "Installation failed. Check the output above for errors."
  fi
}

# Parse command line arguments
INSTALL_ARGS=()
while [[ $# -gt 0 ]]; do
  case $1 in
    --repo)
      REPO_URL="$2"
      shift 2
      ;;
    --dir)
      INSTALL_DIR="$2"
      shift 2
      ;;
    --branch)
      BRANCH="$2"
      shift 2
      ;;
    *)
      # Pass unknown args to install script
      INSTALL_ARGS+=("$1")
      shift
      ;;
  esac
done

# Run main function
main "${INSTALL_ARGS[@]}"
