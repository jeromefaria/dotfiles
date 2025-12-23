#!/bin/bash
#
# Windows/Git Bash Portable Setup
# For systems where symlinks don't work (Windows without admin rights)
#
# This script:
#   1. Configures DOTFILES environment variable in .bash_profile
#   2. Syncs portable bash and vim configs to home directory
#   3. Sets up the sync workflow for future updates
#
# Usage:
#   cd ~/path/to/your/dotfiles
#   ./scripts/setup-portable-windows.sh
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

# Determine dotfiles directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

print_header "Windows Portable Setup for Dotfiles"

print_info "Dotfiles location: $DOTFILES_DIR"
print_info "Home directory: $HOME"
echo ""

# Step 1: Check for existing .bash_profile
print_header "Step 1: Configure .bash_profile"

BASH_PROFILE="$HOME/.bash_profile"
BACKUP_MADE=false

if [[ -f "$BASH_PROFILE" ]]; then
  print_warning ".bash_profile already exists"

  # Check if DOTFILES is already set
  if grep -q "export DOTFILES=" "$BASH_PROFILE"; then
    print_info "DOTFILES variable already set in .bash_profile"

    # Check if it's correct
    CURRENT_DOTFILES=$(grep "export DOTFILES=" "$BASH_PROFILE" | head -1)
    print_info "Current setting: $CURRENT_DOTFILES"

    read -p "Update DOTFILES to point to $DOTFILES_DIR? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      print_info "Skipping .bash_profile update"
    else
      # Backup existing
      cp "$BASH_PROFILE" "$BASH_PROFILE.backup-$(date +%Y%m%d-%H%M%S)"
      BACKUP_MADE=true
      print_success "Backed up existing .bash_profile"

      # Update DOTFILES line
      sed -i.tmp "s|export DOTFILES=.*|export DOTFILES=\"$DOTFILES_DIR\"|" "$BASH_PROFILE"
      rm -f "$BASH_PROFILE.tmp"
      print_success "Updated DOTFILES in .bash_profile"
    fi
  else
    print_info "Adding DOTFILES variable to .bash_profile"

    # Backup existing
    cp "$BASH_PROFILE" "$BASH_PROFILE.backup-$(date +%Y%m%d-%H%M%S)"
    BACKUP_MADE=true
    print_success "Backed up existing .bash_profile"

    # Add DOTFILES at the beginning
    {
      echo "# Dotfiles location"
      echo "export DOTFILES=\"$DOTFILES_DIR\""
      echo ""
      cat "$BASH_PROFILE"
    } > "$BASH_PROFILE.new"
    mv "$BASH_PROFILE.new" "$BASH_PROFILE"
    print_success "Added DOTFILES to .bash_profile"
  fi
else
  print_info "Creating new .bash_profile"

  cat > "$BASH_PROFILE" << EOF
# Dotfiles location
export DOTFILES="$DOTFILES_DIR"

# Source profile and bashrc
test -f ~/.profile && . ~/.profile
test -f ~/.bashrc && . ~/.bashrc
EOF

  print_success "Created .bash_profile"
fi

if [[ "$BACKUP_MADE" == true ]]; then
  print_info "Backup saved to: ${BASH_PROFILE}.backup-*"
fi

# Step 2: Create helper script in home directory
print_header "Step 2: Create Sync Helper Script"

SYNC_HELPER="$HOME/sync-dotfiles.sh"

cat > "$SYNC_HELPER" << EOF
#!/bin/bash
# Quick sync helper - pulls latest changes and syncs configs
cd "$DOTFILES_DIR" || exit 1
echo "Pulling latest changes..."
git pull
echo ""
echo "Syncing portable configs..."
"$DOTFILES_DIR/scripts/sync-portable-configs.sh"
EOF

chmod +x "$SYNC_HELPER"
print_success "Created ~/sync-dotfiles.sh"

# Step 3: Run initial sync
print_header "Step 3: Sync Portable Configs"

if [[ -f "$DOTFILES_DIR/scripts/sync-portable-configs.sh" ]]; then
  "$DOTFILES_DIR/scripts/sync-portable-configs.sh"
else
  print_error "sync-portable-configs.sh not found!"
  exit 1
fi

# Final instructions
print_header "Setup Complete!"

echo "Your portable configs are now set up!"
echo ""
echo "Next steps:"
echo "  1. Restart Git Bash (or run: source ~/.bash_profile)"
echo "  2. Verify with: echo \$DOTFILES"
echo ""
echo "To update configs after pulling changes:"
echo "  Run: ~/sync-dotfiles.sh"
echo "  Or:  cd $DOTFILES_DIR && ./scripts/sync-portable-configs.sh"
echo ""
print_success "All done!"
