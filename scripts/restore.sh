#!/bin/bash
# ============================================================================
# Dotfiles Restore Script
# ============================================================================
# Restores configuration files from a backup directory created by install.sh
#
# Usage:
#   ./restore.sh                    # Interactive: shows backups and prompts
#   ./restore.sh --backup <dir>     # Restore from specific backup
#   ./restore.sh --latest           # Restore from most recent backup
#   ./restore.sh --list             # List available backups
# ============================================================================

set -e

# Source shared configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Script-specific variables
BACKUP_PATTERN="$HOME/.dotfiles-backup-*"
SELECTED_BACKUP=""
DRY_RUN=false

# ============================================================================
# Helper Functions
# ============================================================================

show_usage() {
  cat << EOF
Usage: $0 [OPTIONS]

Restore dotfiles configuration from a backup.

OPTIONS:
    --backup <dir>      Restore from specific backup directory
    --latest            Restore from most recent backup
    --list              List available backups and exit
    --dry-run           Show what would be restored without making changes
    -h, --help          Show this help message

EXAMPLES:
    # Interactive mode (prompts for backup selection)
    $0

    # Restore from specific backup
    $0 --backup ~/.dotfiles-backup-20241126-143022

    # Restore from latest backup
    $0 --latest

    # Preview what would be restored
    $0 --latest --dry-run

EOF
}

# List all backup directories
list_backups() {
  local backups=($(find "$HOME" -maxdepth 1 -type d -name ".dotfiles-backup-*" | sort -r))

  if [ ${#backups[@]} -eq 0 ]; then
    print_warning "No backup directories found"
    print_info "Backup directories match pattern: $BACKUP_PATTERN"
    return 1
  fi

  echo ""
  print_header "Available Backups"
  echo ""

  local count=1
  for backup in "${backups[@]}"; do
    local backup_name=$(basename "$backup")
    local backup_date=${backup_name#.dotfiles-backup-}
    local file_count=$(find "$backup" -type f 2>/dev/null | wc -l | xargs)

    echo -e "${CYAN}[$count]${NC} $backup_name"
    echo "    Date: $backup_date"
    echo "    Files: $file_count"
    echo "    Path: $backup"
    echo ""

    ((count++))
  done

  return 0
}

# Get latest backup directory
get_latest_backup() {
  find "$HOME" -maxdepth 1 -type d -name ".dotfiles-backup-*" | sort -r | head -n 1
}

# Validate backup directory
validate_backup() {
  local backup_dir=$1

  if [ ! -d "$backup_dir" ]; then
    print_error "Backup directory does not exist: $backup_dir"
    return 1
  fi

  local file_count=$(find "$backup_dir" -type f 2>/dev/null | wc -l | xargs)
  if [ "$file_count" -eq 0 ]; then
    print_warning "Backup directory is empty: $backup_dir"
    return 1
  fi

  return 0
}

# Restore a single file
restore_file() {
  local backup_file=$1
  local target_file=$2

  if [ "$DRY_RUN" = true ]; then
    print_info "[DRY RUN] Would restore: $target_file"
    return 0
  fi

  # Create parent directory if needed
  local target_dir=$(dirname "$target_file")
  if [ ! -d "$target_dir" ]; then
    mkdir -p "$target_dir" || {
      print_error "Failed to create directory: $target_dir"
      return 1
    }
  fi

  # Backup current file if it exists and is different
  if [ -e "$target_file" ]; then
    if ! diff -q "$backup_file" "$target_file" &>/dev/null; then
      local safety_backup="${target_file}.before-restore-$(get_timestamp)"
      cp "$target_file" "$safety_backup"
      print_info "Created safety backup: $safety_backup"
    fi
  fi

  # Restore the file
  if cp -p "$backup_file" "$target_file"; then
    print_success "Restored: $target_file"
    return 0
  else
    print_error "Failed to restore: $target_file"
    return 1
  fi
}

# Restore all files from backup
restore_from_backup() {
  local backup_dir=$1

  print_header "Restoring from Backup"
  echo ""
  print_info "Backup: $backup_dir"
  echo ""

  # Find all files in backup
  local files=($(find "$backup_dir" -type f))

  if [ ${#files[@]} -eq 0 ]; then
    print_warning "No files found in backup"
    return 1
  fi

  print_info "Found ${#files[@]} file(s) to restore"
  echo ""

  if [ "$DRY_RUN" = false ]; then
    read -p "Continue with restore? (y/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      print_info "Restore cancelled"
      return 0
    fi
    echo ""
  fi

  local success_count=0
  local fail_count=0

  for backup_file in "${files[@]}"; do
    # Determine target path (remove backup dir prefix, add HOME)
    local rel_path="${backup_file#$backup_dir/}"
    local target_file="$HOME/$rel_path"

    if restore_file "$backup_file" "$target_file"; then
      ((success_count++))
    else
      ((fail_count++))
    fi
  done

  echo ""
  print_header "Restore Summary"
  echo ""
  print_success "Successfully restored: $success_count file(s)"
  if [ $fail_count -gt 0 ]; then
    print_error "Failed to restore: $fail_count file(s)"
    return 1
  fi

  return 0
}

# Interactive backup selection
interactive_select() {
  if ! list_backups; then
    return 1
  fi

  local backups=($(find "$HOME" -maxdepth 1 -type d -name ".dotfiles-backup-*" | sort -r))

  read -p "Select backup number (1-${#backups[@]}) or 'q' to quit: " selection

  if [[ "$selection" == "q" ]]; then
    print_info "Restore cancelled"
    return 1
  fi

  if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#backups[@]} ]; then
    print_error "Invalid selection: $selection"
    return 1
  fi

  local index=$((selection - 1))
  SELECTED_BACKUP="${backups[$index]}"

  print_success "Selected: $(basename "$SELECTED_BACKUP")"
  return 0
}

# ============================================================================
# Main Script
# ============================================================================

main() {
  print_header "Dotfiles Restore Utility"

  # Parse command line arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --backup)
        SELECTED_BACKUP="$2"
        shift 2
        ;;
      --latest)
        SELECTED_BACKUP=$(get_latest_backup)
        if [ -z "$SELECTED_BACKUP" ]; then
          print_error "No backups found"
          exit 1
        fi
        print_info "Using latest backup: $(basename "$SELECTED_BACKUP")"
        shift
        ;;
      --list)
        list_backups
        exit 0
        ;;
      --dry-run)
        DRY_RUN=true
        print_info "Dry run mode enabled (no changes will be made)"
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

  # If no backup specified, go interactive
  if [ -z "$SELECTED_BACKUP" ]; then
    if ! interactive_select; then
      exit 1
    fi
  fi

  # Validate backup
  if ! validate_backup "$SELECTED_BACKUP"; then
    exit 1
  fi

  # Perform restore
  if restore_from_backup "$SELECTED_BACKUP"; then
    echo ""
    print_success "Restore completed successfully"
    echo ""
    print_info "Next steps:"
    echo "  1. Review restored files"
    echo "  2. Restart your terminal or run: source ~/.zshrc"
    echo "  3. Run health check: $SCRIPT_DIR/health-check.sh"
    echo ""
    exit 0
  else
    echo ""
    print_error "Restore failed or was incomplete"
    exit 1
  fi
}

# Run main function
main "$@"
