#!/bin/bash
#
# Sync Portable Configs
# For systems where symlinks don't work (e.g., Windows Git Bash without admin rights)
# Copies portable bash and vim configs from dotfiles repo to home directory
#
# Usage:
#   ./sync-portable-configs.sh
#
# This script is useful for Windows systems where symlinks require admin privileges.
# After pulling updates from the dotfiles repo, run this script to sync the configs.

set -euo pipefail

# Determine script directory and dotfiles root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "========================================"
echo "Syncing Portable Configs"
echo "========================================"
echo "Source: $DOTFILES_DIR"
echo "Target: $HOME"
echo ""

# Track success
SUCCESS_COUNT=0
FAIL_COUNT=0

# Function to copy config file
copy_config() {
  local source=$1
  local target=$2
  local description=$3

  if [[ -f "$source" ]]; then
    if cp -v "$source" "$target"; then
      echo "✓ Synced $description"
      ((SUCCESS_COUNT++))
    else
      echo "✗ Failed to sync $description"
      ((FAIL_COUNT++))
    fi
  else
    echo "✗ Source not found: $source"
    ((FAIL_COUNT++))
  fi
}

# Sync bash config
copy_config \
  "$DOTFILES_DIR/terminal/bash/bashrc.portable" \
  "$HOME/.bashrc" \
  ".bashrc (portable bash config)"

# Sync vim config
copy_config \
  "$DOTFILES_DIR/editors/vim/vimrc" \
  "$HOME/.vimrc" \
  ".vimrc (vim config)"

# Optional: Sync minttyrc if it exists
if [[ -f "$DOTFILES_DIR/terminal/mintty/minttyrc" ]]; then
  copy_config \
    "$DOTFILES_DIR/terminal/mintty/minttyrc" \
    "$HOME/.minttyrc" \
    ".minttyrc (mintty terminal config)"
fi

echo ""
echo "========================================"
echo "Summary"
echo "========================================"
echo "Synced: $SUCCESS_COUNT file(s)"
echo "Failed: $FAIL_COUNT file(s)"
echo ""

if [[ $FAIL_COUNT -eq 0 ]]; then
  echo "✓ All configs synced successfully!"
  echo ""
  echo "Next steps:"
  echo "  1. Restart your shell or run: source ~/.bashrc"
  echo "  2. Vim config will be active on next vim launch"
else
  echo "⚠ Some configs failed to sync - see errors above"
  exit 1
fi
