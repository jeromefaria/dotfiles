#!/usr/bin/env bash
#
# macOS Setup and Configuration
# Main orchestrator script for applying macOS settings
#
# This script coordinates the modular configuration system:
#   - backup-settings.sh: Backs up current settings
#   - restore-settings.sh: Restores from backup
#   - export-settings.sh: Exports settings in readable format
#   - base.sh: Core OS settings
#   - developer.sh: Developer-specific settings
#   - personal.sh: Personal preferences
#   - apps.sh: Third-party application settings
#
# Usage:
#   ./macos-setup.sh              # Interactive mode
#   ./macos-setup.sh --all        # Apply all settings
#   ./macos-setup.sh --base       # Apply only base settings
#   ./macos-setup.sh --dev        # Apply base + developer settings
#   ./macos-setup.sh --backup     # Create backup only
#   ./macos-setup.sh --export     # Export current settings
#   ./macos-setup.sh --help       # Show help
#

set -e

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MACOS_DIR="${SCRIPT_DIR}/macos"

# Source helper functions
if [ -f "${MACOS_DIR}/helpers.sh" ]; then
    source "${MACOS_DIR}/helpers.sh"
else
    echo "Error: Helper functions not found at ${MACOS_DIR}/helpers.sh"
    exit 1
fi

# Validate we're on macOS
if ! is_macos; then
    log_error "This script only works on macOS"
    exit 1
fi

# Show help
show_help() {
    cat << EOF
macOS Setup and Configuration Script

Usage:
  ./macos-setup.sh [OPTIONS]

Options:
  --all               Apply all settings (base, developer, personal, apps)
  --base              Apply only base settings
  --dev               Apply base + developer settings
  --personal          Apply only personal settings
  --apps              Apply only third-party app settings
  --backup [name]     Create a backup of current settings
  --restore <name>    Restore settings from backup
  --export [file]     Export current settings to file
  --no-backup         Skip automatic backup before applying settings
  --help              Show this help message

Interactive Mode:
  Running without options starts interactive mode with prompts.

Examples:
  ./macos-setup.sh --all              # Apply all settings
  ./macos-setup.sh --base --dev       # Apply base and developer settings
  ./macos-setup.sh --backup my-backup # Create named backup
  ./macos-setup.sh --export           # Export to macos-settings-export.txt

Configuration Files:
  scripts/macos/base.sh       - Core OS settings
  scripts/macos/developer.sh  - Developer tools and settings
  scripts/macos/personal.sh   - Personal preferences (customize this!)
  scripts/macos/apps.sh       - Third-party application settings

For more information, see: docs/macos-configuration.md

EOF
}

# Parse command line arguments
APPLY_BASE=false
APPLY_DEVELOPER=false
APPLY_PERSONAL=false
APPLY_APPS=false
DO_BACKUP=false
DO_RESTORE=false
DO_EXPORT=false
SKIP_BACKUP=false
INTERACTIVE=true
BACKUP_NAME=""
RESTORE_NAME=""
EXPORT_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            APPLY_BASE=true
            APPLY_DEVELOPER=true
            APPLY_PERSONAL=true
            APPLY_APPS=true
            INTERACTIVE=false
            shift
            ;;
        --base)
            APPLY_BASE=true
            INTERACTIVE=false
            shift
            ;;
        --dev|--developer)
            APPLY_BASE=true
            APPLY_DEVELOPER=true
            INTERACTIVE=false
            shift
            ;;
        --personal)
            APPLY_PERSONAL=true
            INTERACTIVE=false
            shift
            ;;
        --apps)
            APPLY_APPS=true
            INTERACTIVE=false
            shift
            ;;
        --backup)
            DO_BACKUP=true
            INTERACTIVE=false
            BACKUP_NAME="${2:-}"
            if [[ -n "$BACKUP_NAME" ]] && [[ ! "$BACKUP_NAME" =~ ^-- ]]; then
                shift
            else
                BACKUP_NAME=""
            fi
            shift
            ;;
        --restore)
            DO_RESTORE=true
            INTERACTIVE=false
            RESTORE_NAME="${2:-}"
            shift 2
            ;;
        --export)
            DO_EXPORT=true
            INTERACTIVE=false
            EXPORT_FILE="${2:-}"
            if [[ -n "$EXPORT_FILE" ]] && [[ ! "$EXPORT_FILE" =~ ^-- ]]; then
                shift
            else
                EXPORT_FILE=""
            fi
            shift
            ;;
        --no-backup)
            SKIP_BACKUP=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Main script header
print_header "macOS Configuration System"

# Show system information
log_section "System Information"
echo "  macOS Version: $(get_macos_version)"
echo "  Computer: $(scutil --get ComputerName 2>/dev/null || hostname)"
echo "  User: $(whoami)"
echo "  Date: $(date)"
echo ""

# Check macOS version
check_macos_version 11 || log_warning "Some settings may not be fully compatible"

# Handle backup-only mode
if $DO_BACKUP; then
    log_section "Creating Backup"
    if [ -n "$BACKUP_NAME" ]; then
        bash "${MACOS_DIR}/backup-settings.sh" "$BACKUP_NAME"
    else
        bash "${MACOS_DIR}/backup-settings.sh"
    fi
    exit 0
fi

# Handle restore mode
if $DO_RESTORE; then
    if [ -z "$RESTORE_NAME" ]; then
        log_error "Backup name required for --restore"
        echo "Usage: ./macos-setup.sh --restore <backup-name>"
        exit 1
    fi
    log_section "Restoring Settings"
    bash "${MACOS_DIR}/restore-settings.sh" "$RESTORE_NAME"
    exit 0
fi

# Handle export mode
if $DO_EXPORT; then
    log_section "Exporting Settings"
    if [ -n "$EXPORT_FILE" ]; then
        bash "${MACOS_DIR}/export-settings.sh" "$EXPORT_FILE"
    else
        bash "${MACOS_DIR}/export-settings.sh"
    fi
    exit 0
fi

# Interactive mode
if $INTERACTIVE; then
    log_section "Interactive Configuration"
    echo "This script will configure macOS settings according to your preferences."
    echo "You can choose which categories to apply."
    echo ""

    if confirm "Apply base settings? (recommended for all users)" "y"; then
        APPLY_BASE=true
    fi

    if confirm "Apply developer settings?" "y"; then
        APPLY_DEVELOPER=true
    fi

    if confirm "Apply personal settings?" "y"; then
        APPLY_PERSONAL=true
    fi

    if confirm "Configure third-party applications?" "y"; then
        APPLY_APPS=true
    fi

    echo ""

    if ! $APPLY_BASE && ! $APPLY_DEVELOPER && ! $APPLY_PERSONAL && ! $APPLY_APPS; then
        log_warning "No settings selected. Exiting."
        exit 0
    fi
fi

# Show what will be applied
log_section "Configuration Plan"
$APPLY_BASE && echo "  ✓ Base settings (core macOS improvements)"
$APPLY_DEVELOPER && echo "  ✓ Developer settings (dev tools and workflows)"
$APPLY_PERSONAL && echo "  ✓ Personal settings (regional, appearance, etc.)"
$APPLY_APPS && echo "  ✓ Third-party app settings"
echo ""

# Create automatic backup unless skipped
if ! $SKIP_BACKUP; then
    if $INTERACTIVE; then
        if confirm "Create backup before applying settings?" "y"; then
            log_section "Creating Automatic Backup"
            bash "${MACOS_DIR}/backup-settings.sh" "pre-setup-$(date +%Y%m%d_%H%M%S)"
            echo ""
        fi
    else
        log_section "Creating Automatic Backup"
        bash "${MACOS_DIR}/backup-settings.sh" "pre-setup-$(date +%Y%m%d_%H%M%S)"
        echo ""
    fi
fi

# Final confirmation
if $INTERACTIVE; then
    if ! confirm "Apply selected settings now?" "y"; then
        log_warning "Configuration cancelled"
        exit 0
    fi
    echo ""
fi

# Request sudo access
request_sudo

# Apply settings
if $APPLY_BASE; then
    log_section "Applying Base Settings"
    if [ -f "${MACOS_DIR}/base.sh" ]; then
        bash "${MACOS_DIR}/base.sh"
    else
        log_error "Base settings script not found"
        exit 1
    fi
    echo ""
fi

if $APPLY_DEVELOPER; then
    log_section "Applying Developer Settings"
    if [ -f "${MACOS_DIR}/developer.sh" ]; then
        bash "${MACOS_DIR}/developer.sh"
    else
        log_error "Developer settings script not found"
        exit 1
    fi
    echo ""
fi

if $APPLY_PERSONAL; then
    log_section "Applying Personal Settings"
    if [ -f "${MACOS_DIR}/personal.sh" ]; then
        bash "${MACOS_DIR}/personal.sh"
    else
        log_error "Personal settings script not found"
        exit 1
    fi
    echo ""
fi

if $APPLY_APPS; then
    log_section "Applying Third-Party App Settings"
    if [ -f "${MACOS_DIR}/apps.sh" ]; then
        bash "${MACOS_DIR}/apps.sh"
    else
        log_error "Apps settings script not found"
        exit 1
    fi
    echo ""
fi

# Restart affected applications
log_section "Applying Changes"
log_info "Restarting affected applications..."

APPS_TO_RESTART=(
    "Dock"
    "Finder"
    "SystemUIServer"
    "cfprefsd"
)

for app in "${APPS_TO_RESTART[@]}"; do
    safe_killall "$app"
done

# Final summary
print_completion "macOS configuration complete!"

echo "Summary:"
echo "  ✓ Settings applied successfully"
echo ""
echo "Next steps:"
echo "  1. Log out and log back in for all changes to take effect"
echo "  2. Review System Preferences for any manual adjustments"
echo "  3. Restart your computer if you experience any issues"
echo ""
echo "Backup location: ~/.macos-backups/"
echo "To restore a backup: ./macos-setup.sh --restore <backup-name>"
echo "To export settings: ./macos-setup.sh --export"
echo ""

# Optional: Ask to logout
if $INTERACTIVE; then
    if confirm "Would you like to log out now?" "n"; then
        log_info "Logging out..."
        osascript -e 'tell application "System Events" to log out'
    fi
fi
