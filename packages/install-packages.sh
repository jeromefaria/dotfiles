#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILES_DIR="$SCRIPT_DIR/profiles"

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

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Install packages using categorized Brewfiles.

OPTIONS:
    --profile PROFILE       Install from a predefined profile
                           Available: minimal, dev, music, full

    --categories CATS       Install specific categories (comma-separated)
                           Available: base, dev, music, browsers, security,
                                    communication, productivity, media, utilities

    --list                 List available profiles and categories

    --dry-run              Show what would be installed without installing

    -h, --help             Show this help message

EXAMPLES:
    # Install the dev profile (base + dev + browsers + utilities)
    $0 --profile dev

    # Install specific categories
    $0 --categories base,dev,browsers

    # See what would be installed
    $0 --profile full --dry-run

    # List all available options
    $0 --list

NOTES:
    - All profiles include the 'base' category automatically
    - You can create custom profiles in: $PROFILES_DIR
    - Run 'brew bundle cleanup' to uninstall packages not in your Brewfile

EOF
}

# Function to list available profiles and categories
list_options() {
    echo ""
    print_info "Available Profiles:"
    echo ""
    for profile in "$PROFILES_DIR"/*.txt; do
        if [ -f "$profile" ]; then
            profile_name=$(basename "$profile" .txt)
            echo -e "  ${GREEN}$profile_name${NC}"
            # Show what's in the profile
            grep -v '^#' "$profile" | grep -v '^$' | sed 's/^/    - /'
            echo ""
        fi
    done

    echo ""
    print_info "Available Categories:"
    echo ""
    for brewfile in "$SCRIPT_DIR"/Brewfile.*; do
        if [ -f "$brewfile" ]; then
            category=$(basename "$brewfile" | sed 's/Brewfile\.//')
            package_count=$(grep -c '^brew\|^cask\|^mas' "$brewfile" || echo "0")
            echo -e "  ${GREEN}$category${NC} - $package_count packages"
        fi
    done
    echo ""
}

# Function to install a category
install_category() {
    local category=$1
    local brewfile="$SCRIPT_DIR/Brewfile.$category"

    if [ ! -f "$brewfile" ]; then
        print_error "Category '$category' not found"
        return 1
    fi

    if [ "$DRY_RUN" = true ]; then
        print_info "Would install: $category"
        echo ""
        grep '^brew\|^cask\|^mas' "$brewfile" | sed 's/^/  /'
        echo ""
    else
        print_info "Installing category: $category"
        brew bundle install --file="$brewfile"
        print_success "Completed: $category"
        echo ""
    fi
}

# Function to install from profile
install_profile() {
    local profile=$1
    local profile_file="$PROFILES_DIR/$profile.txt"

    if [ ! -f "$profile_file" ]; then
        print_error "Profile '$profile' not found at: $profile_file"
        print_info "Run '$0 --list' to see available profiles"
        exit 1
    fi

    print_info "Installing profile: $profile"
    echo ""

    # Read categories from profile (skip comments and empty lines)
    local categories=()
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue
        categories+=("$line")
    done < "$profile_file"

    # Install each category
    for category in "${categories[@]}"; do
        install_category "$category"
    done
}

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    print_error "Homebrew is not installed"
    print_info "Install it from: https://brew.sh"
    exit 1
fi

# Parse arguments
PROFILE=""
CATEGORIES=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --profile)
            PROFILE="$2"
            shift 2
            ;;
        --categories)
            CATEGORIES="$2"
            shift 2
            ;;
        --list)
            list_options
            exit 0
            ;;
        --dry-run)
            DRY_RUN=true
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

# Check if either profile or categories is provided
if [ -z "$PROFILE" ] && [ -z "$CATEGORIES" ]; then
    print_error "You must specify either --profile or --categories"
    echo ""
    show_usage
    exit 1
fi

# Check if both are provided
if [ -n "$PROFILE" ] && [ -n "$CATEGORIES" ]; then
    print_error "Cannot use both --profile and --categories together"
    echo ""
    show_usage
    exit 1
fi

# Show dry-run notice
if [ "$DRY_RUN" = true ]; then
    print_warning "DRY RUN MODE - No packages will be installed"
    echo ""
fi

# Install from profile or categories
if [ -n "$PROFILE" ]; then
    install_profile "$PROFILE"
else
    # Split categories by comma and install each
    IFS=',' read -ra CATS <<< "$CATEGORIES"
    for category in "${CATS[@]}"; do
        # Trim whitespace
        category=$(echo "$category" | xargs)
        install_category "$category"
    done
fi

if [ "$DRY_RUN" = false ]; then
    print_success "Installation complete!"
    echo ""
    print_info "Next steps:"
    echo "  - Run 'brew bundle cleanup --file=packages/Brewfile.<category>' to remove unused packages"
    echo "  - Run './packages/sync-packages.sh' after installing new software to update Brewfiles"
fi
