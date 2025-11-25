#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMP_BREWFILE="$SCRIPT_DIR/Brewfile.current"

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
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

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Sync currently installed packages to categorized Brewfiles.

This script will:
1. Generate a snapshot of currently installed packages
2. Compare with existing categorized Brewfiles
3. Show you what's new or changed
4. Help you categorize new packages

OPTIONS:
    --auto-update       Automatically update existing packages in their categories
                       (doesn't add new packages, only updates versions/taps)

    -h, --help          Show this help message

WORKFLOW:
    After installing new software, run this script to see what's changed.
    You'll need to manually add new packages to the appropriate category
    file (Brewfile.base, Brewfile.dev, etc.)

EXAMPLES:
    # See what's changed
    $0

    # Auto-update existing categories
    $0 --auto-update

EOF
}

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    print_error "Homebrew is not installed"
    exit 1
fi

# Parse arguments
AUTO_UPDATE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --auto-update)
            AUTO_UPDATE=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

print_info "Generating snapshot of currently installed packages..."
brew bundle dump --file="$TEMP_BREWFILE" --force

# Get all packages from categorized Brewfiles
print_info "Scanning categorized Brewfiles..."
KNOWN_PACKAGES=$(mktemp)

for brewfile in "$SCRIPT_DIR"/Brewfile.*; do
    if [ -f "$brewfile" ] && [[ ! "$brewfile" =~ \.current$ ]]; then
        grep '^brew\|^cask\|^mas\|^tap' "$brewfile" | sed 's/"//g' | awk '{print $1, $2}' >> "$KNOWN_PACKAGES"
    fi
done

# Sort and deduplicate
sort -u "$KNOWN_PACKAGES" -o "$KNOWN_PACKAGES"

# Find new packages
print_info "Finding new packages..."
NEW_PACKAGES=$(mktemp)

while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^#.*$ ]] && continue
    [[ -z "$line" ]] && continue

    # Extract package type and name
    pkg_type=$(echo "$line" | awk '{print $1}')
    pkg_name=$(echo "$line" | sed 's/"//g' | awk '{print $2}')

    # Check if this package exists in known packages
    if ! grep -q "$pkg_type $pkg_name" "$KNOWN_PACKAGES" 2>/dev/null; then
        echo "$line" >> "$NEW_PACKAGES"
    fi
done < "$TEMP_BREWFILE"

# Show results
echo ""
if [ -s "$NEW_PACKAGES" ]; then
    print_warning "New packages found (not in any category):"
    echo ""
    cat "$NEW_PACKAGES"
    echo ""
    print_info "To add these packages:"
    echo "  1. Determine which category each belongs to"
    echo "  2. Add them to the appropriate Brewfile.<category>"
    echo "  3. Commit the changes"
    echo ""
    print_info "Available categories:"
    echo "  - Brewfile.base         (essential tools)"
    echo "  - Brewfile.dev          (development)"
    echo "  - Brewfile.music        (music production)"
    echo "  - Brewfile.browsers     (web browsers)"
    echo "  - Brewfile.security     (security tools)"
    echo "  - Brewfile.communication (chat, email)"
    echo "  - Brewfile.productivity (personal apps)"
    echo "  - Brewfile.media        (media tools)"
    echo "  - Brewfile.utilities    (system utilities)"
    echo ""
else
    print_success "No new packages found - all packages are categorized!"
fi

# Check for removed packages
print_info "Checking for packages in Brewfiles but not installed..."
REMOVED_PACKAGES=$(mktemp)
CURRENT_PACKAGES=$(mktemp)

grep '^brew\|^cask\|^mas\|^tap' "$TEMP_BREWFILE" | sed 's/"//g' | awk '{print $1, $2}' | sort -u > "$CURRENT_PACKAGES"

while IFS= read -r known_pkg; do
    if ! grep -q "^${known_pkg}$" "$CURRENT_PACKAGES" 2>/dev/null; then
        echo "$known_pkg" >> "$REMOVED_PACKAGES"
    fi
done < "$KNOWN_PACKAGES"

if [ -s "$REMOVED_PACKAGES" ]; then
    echo ""
    print_warning "Packages in Brewfiles but not currently installed:"
    echo ""
    cat "$REMOVED_PACKAGES"
    echo ""
    print_info "These packages are in your Brewfiles but not installed."
    print_info "If you intentionally removed them, remove them from the Brewfiles too."
    echo ""
fi

# Summary
echo ""
print_info "Summary:"
new_count=$([ -s "$NEW_PACKAGES" ] && wc -l < "$NEW_PACKAGES" | xargs || echo "0")
removed_count=$([ -s "$REMOVED_PACKAGES" ] && wc -l < "$REMOVED_PACKAGES" | xargs || echo "0")

echo "  New packages:     $new_count"
echo "  Removed packages: $removed_count"
echo ""

if [ "$new_count" -eq 0 ] && [ "$removed_count" -eq 0 ]; then
    print_success "Everything is in sync!"
fi

# Cleanup temp files
rm -f "$KNOWN_PACKAGES" "$NEW_PACKAGES" "$REMOVED_PACKAGES" "$CURRENT_PACKAGES"

print_info "Current snapshot saved to: $TEMP_BREWFILE"
print_warning "Remember to delete Brewfile.current after categorizing new packages"
