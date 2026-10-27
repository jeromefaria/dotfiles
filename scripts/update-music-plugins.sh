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
    "izotope|iZotope Product Portal.app"
    "output|Output Hub.app"
    "softube|Softube Central.app"
    "spitfire|Spitfire Audio.app"
    "xln|XLN Online Installer.app"
    "ua|UA Connect.app"
    "plugin-alliance|PA-InstallationManager.app"
    "ilok|iLok License Manager.app"
    "vcv-rack|VCV Rack 2 Pro.app"
    "grm-atelier|GRM Tools Atelier.app"
    "soundthread|SoundThread.app"
)

# Managers whose vendor library lives on the Audio volume, reached through a
# symlink out of /Library. Launching one of these while the volume is unmounted
# lets the installer write its payload to the boot disk and leaves a directory
# squatting on /Volumes/Audio, which then blocks the real volume from mounting.
# scripts/audio-volume-guard.sh --check refuses that state before it happens.
VOLUME_DEPENDENT_MANAGERS=(
    "arturia"
    "izotope"
    "softube"
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUDIO_VOLUME_GUARD="${SCRIPT_DIR}/audio-volume-guard.sh"

# Softube update dance — macOS 26.7.1+ blocks installer writes to
# /Library/Application Support/Softube when it is a symlink to an external
# drive (and also when it is a mount point backed by an external APFS
# container). The workaround: before launching Softube Central, ditto the
# Audio-drive library onto boot as a real directory; after Softube Central
# closes, rsync any updates back to the Audio drive and restore the symlink.
# Runtime reads through the symlink are not blocked.
SOFTUBE_SYSTEM_PATH="/Library/Application Support/Softube"
SOFTUBE_SYMLINK_BACKUP="/Library/Application Support/Softube.symlink.pre-update.bak"
SOFTUBE_AUDIO_LIBRARY="/Volumes/Audio/Audio/Libraries/Softube"
SOFTUBE_STAGING="/tmp/softube-staging"
SOFTUBE_MIN_BOOT_FREE_GIB=15

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
    --izotope           Run iZotope Product Portal only
    --output            Run Output Hub only
    --softube           Run Softube Central only
    --spitfire          Run Spitfire Audio only
    --xln               Run XLN Online Installer only
    --ua                Run UA Connect only
    --plugin-alliance   Run Plugin Alliance only
    --ilok              Run iLok License Manager only
    --vcv-rack          Run VCV Rack 2 Pro only
    --grm-atelier       Run GRM Tools Atelier only
    --soundthread       Run Soundthread only
    --list              List all available plugin managers
    --softube-status    Inspect the Softube pre/post dance state (no sudo)
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
            available_count=$((available_count + 1))
        else
            print_error "$app_name (${key}) - Not installed"
            missing_count=$((missing_count + 1))
        fi
    done

    echo ""
    print_info "Summary: $available_count available, $missing_count not installed"
    echo ""
}

# True (0) iff this manager installs into the Audio volume.
is_volume_dependent() {
    local key="$1"
    for dependent in "${VOLUME_DEPENDENT_MANAGERS[@]}"; do
        [ "$dependent" = "$key" ] && return 0
    done
    return 1
}

# Refuse to launch a volume-dependent manager unless the Audio volume is
# actually mounted. Absent the guard script the check is skipped rather than
# blocking, so a partial checkout cannot make the whole script unusable — but
# it says so, because a silent skip looks identical to a passing pre-flight.
audio_volume_is_ready() {
    local key="$1"

    is_volume_dependent "$key" || return 0

    if [ ! -x "$AUDIO_VOLUME_GUARD" ]; then
        print_warning "Audio volume pre-flight skipped — $AUDIO_VOLUME_GUARD not executable"
        return 0
    fi

    "$AUDIO_VOLUME_GUARD" --check
}

# True (0) iff Softube is currently a symlink to the Audio drive — the shape
# the dance expects to see at idle. Any other shape means a previous run of
# the dance was interrupted; refuse to start fresh in that case.
softube_cycle_is_idle() {
    [ -L "$SOFTUBE_SYSTEM_PATH" ] && [ ! -e "$SOFTUBE_SYMLINK_BACKUP" ]
}

softube_cycle_is_pre_complete() {
    [ -d "$SOFTUBE_SYSTEM_PATH" ] && [ ! -L "$SOFTUBE_SYSTEM_PATH" ] && [ -L "$SOFTUBE_SYMLINK_BACKUP" ]
}

# Report where the Softube install path is in the pre/post cycle.
softube_cycle_status() {
    print_header "Softube update-cycle state"
    echo ""

    # A glob rather than `ls | grep`, so a no-match is actually detectable: a
    # pipeline ending in sed always exits 0, which left the fallback below
    # unreachable. An unmatched glob stays literal, so -e on it is false.
    local softube_install_paths=("/Library/Application Support/"*[Ss]oftube*)

    if [ -e "${softube_install_paths[0]}" ]; then
        ls -lad "${softube_install_paths[@]}" | sed 's/^/    /'
    else
        echo "    (nothing matches softube)"
    fi

    echo ""
    if softube_cycle_is_idle; then
        print_success "IDLE — symlink in place. '--softube' will run pre, open, and post."
    elif softube_cycle_is_pre_complete; then
        print_warning "PRE-COMPLETE — real dir on boot. '--softube' will open Softube Central, then post."
    else
        print_warning "UNKNOWN state — inspect manually before running --softube"
    fi
    echo ""
    print_info "boot headroom:"
    df -h / | awk 'NR==2{print "    "$0}'
    echo ""
    print_info "Audio drive Softube library:"
    du -sh "$SOFTUBE_AUDIO_LIBRARY" 2>&1 | sed 's/^/    /'
}

# Write the admin half of the pre dance to a temp bash script.
# Positional args: $1 system path, $2 symlink backup path, $3 staging dir.
# Exit codes identify where it stopped so the caller can report clearly
# and the caller's trap can clean up correctly.
#   10 — state check: system path is not a symlink (re-check under root)
#   11 — state check: backup path already exists
#   12 — state check: staging missing
#   20 — mv symlink aside failed (nothing changed)
#   21 — mv staging into place failed (rolled back)
_softube_write_pre_admin_script() {
    local out="$1"
    cat > "$out" <<'ADMIN_PRE'
#!/bin/bash
set -euo pipefail
cd /
sys_path="$1"
bak_path="$2"
staging="$3"
[ -L "$sys_path" ]  || { echo "ERR:not-symlink"   >&2; exit 10; }
[ ! -e "$bak_path" ] || { echo "ERR:backup-exists" >&2; exit 11; }
[ -d "$staging" ]   || { echo "ERR:no-staging"    >&2; exit 12; }
if ! mv "$sys_path" "$bak_path"; then
    echo "ERR:mv-symlink-aside" >&2
    exit 20
fi
if ! mv "$staging" "$sys_path"; then
    # Rollback: put the symlink back
    mv "$bak_path" "$sys_path" 2>/dev/null || true
    echo "ERR:mv-staging-into-place" >&2
    exit 21
fi
echo "OK"
ADMIN_PRE
}

# Write the admin half of the post dance.
# Positional args: $1 system path, $2 symlink backup path, $3 trash target.
# Exit codes:
#   10 — system path not a real dir
#   11 — symlink backup missing (can't restore)
#   20 — mv system path to trash failed (nothing destructive done)
#   21 — mv backup to system path failed (CRITICAL: no path at target —
#        caller must warn the user and try to recover manually)
# Positional arg 4: real user name — the trash target is in that user's
# ~/.Trash and ownership of the moved dir is chown'd back to them so
# Finder shows it and `trash` can empty it without sudo.
_softube_write_post_admin_script() {
    local out="$1"
    cat > "$out" <<'ADMIN_POST'
#!/bin/bash
set -euo pipefail
cd /
sys_path="$1"
bak_path="$2"
trash_target="$3"
owner="$4"
[ -d "$sys_path" ] && [ ! -L "$sys_path" ] || { echo "ERR:not-real-dir"    >&2; exit 10; }
[ -L "$bak_path" ]                          || { echo "ERR:backup-missing" >&2; exit 11; }
mkdir -p "$(dirname "$trash_target")" 2>/dev/null || true
if ! mv "$sys_path" "$trash_target"; then
    echo "ERR:mv-sys-to-trash" >&2
    exit 20
fi
# Chown so the user can see/empty it from Finder without sudo.
chown -R "$owner:staff" "$trash_target" 2>/dev/null || true
if ! mv "$bak_path" "$sys_path"; then
    # Rollback: try to put the trash copy back so the user doesn't have an
    # empty path. The chown is irrelevant to the rollback itself.
    chown -R root:wheel "$trash_target" 2>/dev/null || true
    mv "$trash_target" "$sys_path" 2>/dev/null || true
    echo "ERR:mv-backup-to-sys" >&2
    exit 21
fi
echo "OK"
ADMIN_POST
}

# Stage the Softube library on boot before Softube Central opens.
# Writes to /Library require root → the mv steps run under osascript admin
# for a native password dialog. The ditto itself needs no sudo.
softube_cycle_pre() {
    # Pre-flight: all checks are read-only; failure here changes nothing.
    softube_cycle_is_idle || {
        print_error "softube pre — path not idle; refuse to run (use --softube-status to inspect)"
        return 1
    }
    [ -d "$SOFTUBE_AUDIO_LIBRARY" ] || {
        print_error "softube pre — $SOFTUBE_AUDIO_LIBRARY not reachable (Audio drive mounted?)"
        return 1
    }

    local boot_free_kib boot_free_gib
    boot_free_kib=$(df -k / | awk 'NR==2{print $4}')
    boot_free_gib=$((boot_free_kib / 1024 / 1024))
    if [ "$boot_free_gib" -lt "$SOFTUBE_MIN_BOOT_FREE_GIB" ]; then
        print_error "softube pre — boot has only ${boot_free_gib} GiB free; need ${SOFTUBE_MIN_BOOT_FREE_GIB}"
        return 1
    fi

    # Clean up any leftover staging from a prior interrupted run before copying
    # fresh content. Idempotent; the dir only ever holds throwaway staged bytes.
    [ -d "$SOFTUBE_STAGING" ] && rm -rf "$SOFTUBE_STAGING"

    print_info "softube pre — ditto Audio → boot staging (~12 GB, 2 min)"
    if ! /usr/bin/ditto "$SOFTUBE_AUDIO_LIBRARY" "$SOFTUBE_STAGING" 2>&1; then
        print_error "softube pre — ditto failed; cleaning up (nothing in /Library changed)"
        [ -d "$SOFTUBE_STAGING" ] && rm -rf "$SOFTUBE_STAGING"
        return 1
    fi

    print_info "softube pre — swap symlink + move staging into place (sudo prompt)"
    local admin_script
    admin_script=$(mktemp -t softube-pre-admin.XXXXXX)
    _softube_write_pre_admin_script "$admin_script"
    local admin_output rc
    admin_output=$(osascript -e "do shell script \"/bin/bash $admin_script '$SOFTUBE_SYSTEM_PATH' '$SOFTUBE_SYMLINK_BACKUP' '$SOFTUBE_STAGING'\" with administrator privileges" 2>&1)
    rc=$?
    rm -f "$admin_script"

    if [ "$rc" -eq 0 ] && [ "${admin_output: -2}" = "OK" ]; then
        print_success "softube pre — ready for updates"
        return 0
    fi

    # Admin step failed or was cancelled. Clean up any orphan staging —
    # it may be gone (admin succeeded in moving it) or still present (admin
    # failed before the mv). Either way, don't leave garbage on boot.
    [ -d "$SOFTUBE_STAGING" ] && rm -rf "$SOFTUBE_STAGING"

    case "$admin_output" in
        *ERR:not-symlink*)         print_error "softube pre — $SOFTUBE_SYSTEM_PATH is not a symlink under root; manual check needed" ;;
        *ERR:backup-exists*)       print_error "softube pre — $SOFTUBE_SYMLINK_BACKUP already exists; a prior run was interrupted" ;;
        *ERR:no-staging*)          print_error "softube pre — staging dir vanished before admin step; retry" ;;
        *ERR:mv-symlink-aside*)    print_error "softube pre — couldn't move the symlink; nothing changed in /Library" ;;
        *ERR:mv-staging-into-place*) print_error "softube pre — mv staging failed; symlink was rolled back, state preserved" ;;
        *"User cancelled"*)        print_warning "softube pre — password dialog cancelled; staging cleaned up" ;;
        *)                         print_error "softube pre — admin step failed: $admin_output" ;;
    esac
    return 1
}

# Mirror updates back to the Audio drive and restore the symlink.
# Two phases: user-shell rsync (shows progress, no sudo), then admin
# osascript to atomically swap the boot copy for the restored symlink.
softube_cycle_post() {
    softube_cycle_is_pre_complete || {
        print_error "softube post — path not in pre-complete state; nothing to mirror back"
        return 1
    }
    [ -d "$SOFTUBE_AUDIO_LIBRARY" ] || {
        print_error "softube post — $SOFTUBE_AUDIO_LIBRARY not reachable (Audio drive mounted?)"
        return 1
    }

    print_info "softube post — mirror boot → Audio drive (rsync --delete)"
    # Root-owned files under $SOFTUBE_SYSTEM_PATH are world-readable (installer
    # convention); Audio drive is noowners so writes land fine. No sudo needed.
    if ! rsync -aEH --delete "$SOFTUBE_SYSTEM_PATH/" "$SOFTUBE_AUDIO_LIBRARY/"; then
        print_error "softube post — rsync failed; boot copy and symlink backup intact, retry safe"
        return 1
    fi
    print_success "softube post — mirror complete"

    local real_user trash_target
    real_user="$(logname 2>/dev/null || echo "$USER")"
    trash_target="/Users/$real_user/.Trash/Softube.post-update-$(date +%Y%m%d-%H%M%S)"
    print_info "softube post — swap boot copy for symlink (sudo prompt)"

    local admin_script
    admin_script=$(mktemp -t softube-post-admin.XXXXXX)
    _softube_write_post_admin_script "$admin_script"
    local admin_output rc
    admin_output=$(osascript -e "do shell script \"/bin/bash $admin_script '$SOFTUBE_SYSTEM_PATH' '$SOFTUBE_SYMLINK_BACKUP' '$trash_target' '$real_user'\" with administrator privileges" 2>&1)
    rc=$?
    rm -f "$admin_script"

    if [ "$rc" -eq 0 ] && [ "${admin_output: -2}" = "OK" ]; then
        print_success "softube post — symlink restored; boot copy stashed in Trash as $(basename "$trash_target")"
        print_warning "empty the Trash to reclaim ~12 GB once Softube is confirmed working"
        return 0
    fi

    case "$admin_output" in
        *ERR:not-real-dir*)      print_error "softube post — $SOFTUBE_SYSTEM_PATH is not a real dir under root; manual check needed" ;;
        *ERR:backup-missing*)    print_error "softube post — $SOFTUBE_SYMLINK_BACKUP missing; cannot restore symlink safely" ;;
        *ERR:mv-sys-to-trash*)   print_error "softube post — couldn't move boot copy to trash; nothing destructive done, boot still has install" ;;
        *ERR:mv-backup-to-sys*)
            print_error "softube post — CRITICAL: symlink restore failed and the auto-rollback may not have run."
            print_error "  Expected final state: $SOFTUBE_SYSTEM_PATH is a symlink → $SOFTUBE_AUDIO_LIBRARY"
            print_error "  Check with: ls -la '$SOFTUBE_SYSTEM_PATH' '$SOFTUBE_SYMLINK_BACKUP' '$trash_target'"
            ;;
        *"User cancelled"*)      print_warning "softube post — password dialog cancelled; boot copy and backup intact, retry safe" ;;
        *)                       print_error "softube post — admin step failed: $admin_output" ;;
    esac
    return 1
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

    if ! audio_volume_is_ready "$key"; then
        echo ""
        print_error "Refusing to open $app_name — the Audio volume is not ready"
        return 1
    fi

    if [ "$key" = "softube" ]; then
        if ! softube_cycle_pre; then
            print_error "Softube pre dance failed — not opening $app_name"
            return 1
        fi
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

    if [ "$key" = "softube" ]; then
        if ! softube_cycle_post; then
            print_error "Softube post dance failed — install path left in pre state; inspect manually"
            return 1
        fi
    fi

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
        current=$((current + 1))

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
            skipped=$((skipped + 1))
            continue
        fi

        if open_plugin_manager "$manager"; then
            success=$((success + 1))
        else
            skipped=$((skipped + 1))
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
            --native|--arturia|--izotope|--output|--softube|--spitfire|--xln|--ua|--plugin-alliance|--ilok|--vcv-rack|--grm-atelier|--soundthread)
                key="${1#--}"
                SELECTED_MANAGERS+=("$key")
                shift
                ;;
            --list)
                LIST_ONLY=true
                shift
                ;;
            --softube-status)
                softube_cycle_status
                exit 0
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
