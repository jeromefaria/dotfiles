#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Plugin managers configuration (compatible with bash 3.2)
# Format: "key|App Name.app|Custom Path (optional)"
PLUGIN_MANAGERS=(
    "native|Native Access.app"
    "arturia|Arturia Software Center.app|/Applications/Arturia/Arturia Software Center.app"
    "splice|Splice INSTRUMENT.app"
    "izotope|iZotope Product Portal.app"
    "output|Output Hub.app"
    "softube|Softube Central.app"
    "spitfire|Spitfire Audio.app"
    "xln|XLN Online Installer.app"
    "ua|UA Connect.app"
    "plugin-alliance|PA-InstallationManager.app"
    "ilok|iLok License Manager.app"
)

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

print_header() {
    echo -e "${CYAN}==>${NC} ${BOLD}$1${NC}"
}

# Get app name from key
get_app_name() {
    local key="$1"
    for entry in "${PLUGIN_MANAGERS[@]}"; do
        local entry_key="${entry%%|*}"
        local rest="${entry#*|}"
        local entry_app="${rest%%|*}"
        if [ "$entry_key" = "$key" ]; then
            echo "$entry_app"
            return 0
        fi
    done
    return 1
}

# Get custom path from key (if exists)
get_custom_path() {
    local key="$1"
    for entry in "${PLUGIN_MANAGERS[@]}"; do
        local entry_key="${entry%%|*}"
        if [ "$entry_key" = "$key" ]; then
            # Check if there's a third field (custom path)
            local rest="${entry#*|}"
            rest="${rest#*|}"
            if [ "$rest" != "${entry#*|}" ]; then
                echo "$rest"
                return 0
            fi
        fi
    done
    return 1
}

# Get key from entry
get_key_from_entry() {
    echo "${1%%|*}"
}

# Get app from entry
get_app_from_entry() {
    local rest="${1#*|}"
    echo "${rest%%|*}"
}

# Get custom path from entry (if exists)
get_custom_path_from_entry() {
    local rest="${1#*|}"
    rest="${rest#*|}"
    if [ "$rest" != "${1#*|}" ]; then
        echo "$rest"
    fi
}

show_usage() {
    cat << 'EOF'
Usage: update-music-plugins [OPTIONS]

Update music production plugin managers one at a time.

This script will open each plugin manager application sequentially,
allowing you to update your plugins. Each app will open and wait for
you to close it before proceeding to the next one.

OPTIONS:
    --all               Run all available plugin managers (default)
    --native            Run Native Access only
    --arturia           Run Arturia Software Center only
    --splice            Run Splice INSTRUMENT only
    --izotope           Run iZotope Product Portal only
    --output            Run Output Hub only
    --softube           Run Softube Central only
    --spitfire          Run Spitfire Audio only
    --xln               Run XLN Online Installer only
    --ua                Run UA Connect only
    --plugin-alliance   Run Plugin Alliance only
    --ilok              Run iLok License Manager only
    --list              List all available plugin managers
    -h, --help          Show this help message

EXAMPLES:
    # Run all plugin managers interactively
    update-music-plugins

    # Run specific managers
    update-music-plugins --native --izotope --output

    # List available managers and their status
    update-music-plugins --list

WORKFLOW:
    1. Script opens the first plugin manager
    2. You update your plugins in the application
    3. Close the application when done
    4. Script automatically opens the next manager
    5. Repeat until all managers are processed

EOF
}

# Check if an application exists
check_app_exists() {
    local app_name="$1"
    local app_path="$2"

    # If a custom path is provided, use it; otherwise use /Applications
    if [ -n "$app_path" ]; then
        [ -d "$app_path" ]
    else
        [ -d "/Applications/$app_name" ]
    fi
}

# Get available managers
get_available_managers() {
    local available=()
    for entry in "${PLUGIN_MANAGERS[@]}"; do
        local key
        key=$(get_key_from_entry "$entry")
        local app
        app=$(get_app_from_entry "$entry")
        local custom_path
        custom_path=$(get_custom_path_from_entry "$entry")
        if check_app_exists "$app" "$custom_path"; then
            available+=("$key")
        fi
    done
    echo "${available[@]}"
}

# List all plugin managers with status
list_managers() {
    echo ""
    print_header "Plugin Manager Status"
    echo ""

    local available_count=0
    local missing_count=0

    for entry in "${PLUGIN_MANAGERS[@]}"; do
        local key
        key=$(get_key_from_entry "$entry")
        local app_name
        app_name=$(get_app_from_entry "$entry")
        local custom_path
        custom_path=$(get_custom_path_from_entry "$entry")
        if check_app_exists "$app_name" "$custom_path"; then
            print_success "$app_name (${key})"
            ((available_count++))
        else
            print_error "$app_name (${key}) - Not installed"
            ((missing_count++))
        fi
    done

    echo ""
    print_info "Summary: $available_count available, $missing_count not installed"
    echo ""
}

# Open a plugin manager and wait for it to close
open_plugin_manager() {
    local key="$1"
    local app_name
    app_name=$(get_app_name "$key")

    if [ -z "$app_name" ]; then
        print_error "Unknown plugin manager: $key"
        return 1
    fi

    # Get custom path or use default
    local custom_path
    custom_path=$(get_custom_path "$key")
    local app_path="${custom_path:-/Applications/$app_name}"

    if ! check_app_exists "$app_name" "$custom_path"; then
        print_warning "$app_name is not installed, skipping..."
        return 1
    fi

    echo ""
    print_header "Opening $app_name"
    print_info "Update your plugins, then close the app to continue..."
    echo ""

    # Open the app and wait for it to close
    # Disable exit-on-error for this command to handle force-quit gracefully
    set +e
    open -W "$app_path"
    local exit_code=$?
    set -e

    # Handle different exit scenarios
    if [ $exit_code -eq 0 ]; then
        print_success "$app_name closed normally"
        return 0
    elif [ $exit_code -eq 137 ] || [ $exit_code -eq 143 ]; then
        # 137 = SIGKILL (kill -9), 143 = SIGTERM (kill)
        print_warning "$app_name was force-quit or killed"
        return 0
    else
        print_warning "$app_name exited with code $exit_code"
        return 0
    fi
}

# Main update function
run_updates() {
    local managers=("$@")
    local total=${#managers[@]}
    local current=0
    local success=0
    local skipped=0

    echo ""
    print_header "Music Plugin Manager Updates"
    print_info "Will process $total plugin manager(s)"
    echo ""

    for manager in "${managers[@]}"; do
        ((current++))

        local app_name
        app_name=$(get_app_name "$manager")
        echo ""
        print_info "[$current/$total] Processing: $app_name"

        # Ask for confirmation
        read -p "$(echo -e "${CYAN}?${NC}") Open $app_name? [Y/n/q] " -n 1 -r
        echo ""

        if [[ $REPLY =~ ^[Qq]$ ]]; then
            print_warning "Update process cancelled"
            break
        elif [[ $REPLY =~ ^[Nn]$ ]]; then
            print_warning "Skipped $app_name"
            ((skipped++))
            continue
        fi

        if open_plugin_manager "$manager"; then
            ((success++))
        else
            ((skipped++))
        fi
    done

    # Summary
    echo ""
    print_header "Update Summary"
    echo "  Total managers:    $total"
    echo "  Processed:         $success"
    echo "  Skipped:           $skipped"
    echo ""

    if [ "$success" -eq "$total" ]; then
        print_success "All plugin managers processed successfully!"
    else
        print_info "Plugin manager updates completed"
    fi
    echo ""
}

# Parse arguments
SELECTED_MANAGERS=()
LIST_ONLY=false

if [ $# -eq 0 ]; then
    # No arguments, run all available
    # Bash 3.2 compatible: read space-separated output into array
    IFS=' ' read -r -a SELECTED_MANAGERS <<< "$(get_available_managers)"
else
    while [[ $# -gt 0 ]]; do
        case $1 in
            --all)
                IFS=' ' read -r -a SELECTED_MANAGERS <<< "$(get_available_managers)"
                shift
                ;;
            --native|--arturia|--splice|--izotope|--output|--softube|--spitfire|--xln|--ua|--plugin-alliance|--ilok)
                key="${1#--}"
                SELECTED_MANAGERS+=("$key")
                shift
                ;;
            --list)
                LIST_ONLY=true
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
fi

# Main execution
if [ "$LIST_ONLY" = true ]; then
    list_managers
    exit 0
fi

if [ ${#SELECTED_MANAGERS[@]} -eq 0 ]; then
    print_error "No plugin managers selected or available"
    print_info "Run 'update-music-plugins --list' to see available managers"
    exit 1
fi

# Run the updates
run_updates "${SELECTED_MANAGERS[@]}"
