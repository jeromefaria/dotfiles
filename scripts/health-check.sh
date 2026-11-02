#!/bin/bash
#
# Dotfiles Health Check
# Verifies that all symlinks and dependencies are properly configured
#

# No -e, deliberately. check_symlink and check_command both return 1 for
# anything they report, and a bare call under -e took the whole script down at
# the first finding — so the one run that had something to say stopped after
# saying one thing, with no summary, no exit code of its own and no hint that
# more had gone unchecked. A missing optional tool was enough to do it. This
# script's error handling is to tally into ISSUES_FOUND/WARNINGS_FOUND and
# decide the exit code at the end, which -e cannot coexist with.
set -uo pipefail  # undefined vars and pipe failures still fail loudly

# Shared color palette + print_header. Local print_success/error/warning/info
# are overridden below — they use 2-space indents under headers and the
# error/warning variants tally counters.
source "$(dirname "${BASH_SOURCE[0]}")/lib/io.sh"

# Repo root, derived from this script's own location so the checkout works from
# any directory. An explicit DOTFILES_DIR still wins, which is how bootstrap.sh
# hands down its --dir value.
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
ISSUES_FOUND=0
WARNINGS_FOUND=0

print_success() {
    echo -e "  ${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "  ${RED}✗${NC} $1"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
}

print_warning() {
    echo -e "  ${YELLOW}⚠${NC} $1"
    WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
}

print_info() {
    echo -e "  ${BLUE}ℹ${NC} $1"
}

check_symlink() {
    local target=$1
    local expected_source=$2
    local description=$3

    if [ -L "$target" ]; then
        local actual_source
        actual_source=$(readlink "$target")
        if [ "$actual_source" = "$expected_source" ]; then
            print_success "$description"
            return 0
        else
            print_error "$description (points to wrong location: $actual_source)"
            return 1
        fi
    elif [ -e "$target" ]; then
        print_warning "$description (exists but is not a symlink)"
        return 1
    else
        print_warning "$description (does not exist)"
        return 1
    fi
}

check_command() {
    local cmd=$1
    local description=$2
    local optional="${3:-}"

    if command -v "$cmd" &> /dev/null; then
        print_success "$description"
        return 0
    else
        if [ "$optional" = "optional" ]; then
            print_warning "$description (optional, not installed)"
        else
            print_error "$description (required, not found)"
        fi
        return 1
    fi
}

# Main checks
print_header "Dotfiles Health Check"
echo ""
print_info "Checking dotfiles installation at: $DOTFILES_DIR"
echo ""

# Check 1: Dotfiles directory exists
print_header "1. Repository Check"
if [ -d "$DOTFILES_DIR" ]; then
    print_success "Dotfiles directory exists"
    if [ -d "$DOTFILES_DIR/.git" ]; then
        print_success "Git repository detected"
    else
        print_warning "Not a git repository"
    fi
else
    print_error "Dotfiles directory not found at $DOTFILES_DIR"
    echo ""
    echo "Exiting - cannot continue without dotfiles directory"
    exit 1
fi

# Check 2: Core symlinks
print_header "2. Core Configuration Symlinks"
check_symlink "$HOME/.zshrc" "$DOTFILES_DIR/terminal/zsh/zshrc" "zsh configuration"
check_symlink "$HOME/.vimrc" "$DOTFILES_DIR/editors/vim/vimrc" "vim configuration"
check_symlink "$HOME/.tmux.conf" "$DOTFILES_DIR/terminal/tmux/tmux.conf" "tmux configuration"
check_symlink "$HOME/.gitconfig" "$DOTFILES_DIR/git/gitconfig" "git configuration"

# Check 3: XDG config symlinks
print_header "3. XDG Configuration Symlinks"

# Check if ~/.config itself is a symlink (whole-directory strategy)
if [ -L "$HOME/.config" ]; then
    config_target=$(readlink "$HOME/.config")
    if [ "$config_target" = "$DOTFILES_DIR/config" ]; then
        print_success "Using whole-directory strategy: ~/.config → $DOTFILES_DIR/config"
        print_info "All configs automatically linked through directory symlink"

        # Verify key configs are accessible
        test_configs=("nvim" "starship.toml" "bat" "gh")
        for config in "${test_configs[@]}"; do
            if [ -e "$HOME/.config/$config" ]; then
                print_success "  $config accessible"
            else
                print_warning "  $config not found"
            fi
        done
    else
        # shellcheck disable=SC2088  # the tilde is prose in a message, not a path to expand
        print_error "~/.config is a symlink but points to: $config_target (expected: $DOTFILES_DIR/config)"
    fi
else
    # Individual symlink strategy.
    #
    # Only what every profile links is named here — the set link_dotfiles uses
    # for the work profile, configs with nothing personal in them. A missing one
    # is a real fault. Everything else the repo tracks is swept by check 3.6
    # below rather than listed again here, which is the part that had gone
    # wrong: the old list named ncmpcpp, neofetch, ranger and yarn, none of
    # which this repo has tracked for a long time, and warned about the seven
    # configs the work profile leaves out on purpose. So a correct work install
    # reported seven warnings it should not have while twenty-odd tracked
    # configs went unmentioned. Nobody saw it because the branch above returns
    # early on a personal machine, and that is the only kind this runs on.
    required_items=(
        "nvim:config/nvim:Neovim"
        "starship.toml:config/starship.toml:Starship prompt"
        "bat:config/bat:bat"
        "gh:config/gh:GitHub CLI"
        "tmuxinator:terminal/tmux/tmuxinator:tmuxinator"
    )

    for item in "${required_items[@]}"; do
        IFS=':' read -r target source description <<< "$item"
        if [ -e "$DOTFILES_DIR/$source" ]; then
            check_symlink "$HOME/.config/$target" "$DOTFILES_DIR/$source" "$description"
        fi
    done
fi

# Check 3.5: Circular symlinks in config directory
print_header "3.5. Circular Symlink Detection"
circular_found=false

# Check config/ directory for circular symlinks
for item in "$DOTFILES_DIR/config"/*; do
    if [ -L "$item" ]; then
        item_name=$(basename "$item")
        target=$(readlink "$item")

        # Check if symlink points to itself (circular)
        if [ "$target" = "$item" ] || [ "$target" = "$(cd "$(dirname "$item")" && pwd -P)/$item_name" ]; then
            print_error "Circular symlink: config/$item_name → $target"
            circular_found=true
        fi
    fi
done

if [ "$circular_found" = false ]; then
    print_success "No circular symlinks found in config/"
fi

# Check 3.6: a config this repo tracks, its app installed, and no link
print_header "3.6. Installed Apps Whose Config Is Not Linked"

if [ -L "$HOME/.config" ]; then
    print_info "Whole-directory link in use, so every tracked config is already live"
else
    # Reports; does not link. Which configs a profile installs stays with
    # link_dotfiles, where the reason is written down: the media, window-manager
    # and mail configs are kept off hardware that is not this user's own, and
    # that is a decision about propriety which the presence of an app cannot
    # express. What presence *can* do is make the other case audible — an app
    # installed by hand after the fact, whose config has been sitting in this
    # repo unlinked ever since, with nothing anywhere saying so.
    #
    # `command -v` and no table of binary names, on purpose. A probe that cannot
    # see an app costs one hint not printed: aria2's binary is aria2c, beets' is
    # beet, and a GUI cask like Karabiner-Elements has no binary at all, so none
    # of those three will ever be reported here. Guessing wrong the other way —
    # putting a personal config on a work machine — is the failure this whole
    # split exists to prevent, which is why the probe only ever prints.
    unlinked_count=0

    for source in "$DOTFILES_DIR/config"/*; do
        config_name=$(basename "$source")

        [ "$config_name" = "README.md" ] && continue

        # A directory holding nothing but documentation has nothing to link.
        # config/starship and config/gtk-4.0 are both prose only, and the first
        # of them would otherwise be reported on every machine with a prompt.
        if [ -d "$source" ] \
            && [ "$(find "$source" -mindepth 1 ! -name "*.md" | wc -l | tr -d " ")" = "0" ]; then
            continue
        fi

        if [ -e "$HOME/.config/$config_name" ] || [ -L "$HOME/.config/$config_name" ]; then
            continue
        fi

        if ! command -v "$config_name" &> /dev/null; then
            continue
        fi

        print_warning "$config_name is installed but config/$config_name is not linked"
        unlinked_count=$((unlinked_count + 1))
    done

    if [ "$unlinked_count" -eq 0 ]; then
        print_success "Every installed app with a config in this repo has it linked"
    else
        print_info "Each is a decision, not a fault: link one by hand, or add it to link_dotfiles if every machine should have it"
    fi
fi

# Check 4: Essential tools
print_header "4. Essential Tools"
check_command "brew" "Homebrew package manager"
check_command "git" "Git version control"
check_command "zsh" "Zsh shell"
check_command "tmux" "Tmux terminal multiplexer"
check_command "nvim" "Neovim editor"

# Check 5: Shell enhancement tools (from aliases)
print_header "5. Shell Enhancement Tools"
check_command "eza" "eza (modern ls)" "optional"
check_command "bat" "bat (modern cat)" "optional"
check_command "fd" "fd (modern find)" "optional"
check_command "rg" "ripgrep (modern grep)" "optional"
check_command "fzf" "fzf (fuzzy finder)" "optional"
check_command "zoxide" "zoxide (smart cd)" "optional"
check_command "htop" "htop (system monitor)" "optional"

# Check 6: Development tools
print_header "6. Development Tools"
check_command "node" "Node.js" "optional"
check_command "npm" "npm" "optional"
check_command "python3" "Python 3" "optional"
check_command "ruby" "Ruby" "optional"
check_command "gh" "GitHub CLI" "optional"

# Check 7: Plugin managers
print_header "7. Plugin Managers"
if [ -d "$HOME/.oh-my-zsh" ]; then
    print_success "Oh My Zsh installed"
else
    print_warning "Oh My Zsh not installed"
fi

if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    print_success "Tmux Plugin Manager installed"
else
    print_warning "Tmux Plugin Manager not installed"
fi

if [ -d "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy/lazy.nvim" ]; then
    print_success "lazy.nvim (Neovim plugin manager) installed"
else
    print_warning "lazy.nvim not installed (will auto-install on first Neovim launch)"
fi

# Check 8: Broken symlinks
print_header "8. Broken Symlinks Check"
broken_links=$(find "$HOME" -maxdepth 1 -type l ! -exec test -e {} \; -print 2>/dev/null)
broken_config_links=$(find "$HOME/.config" -maxdepth 1 -type l ! -exec test -e {} \; -print 2>/dev/null)

if [ -z "$broken_links" ] && [ -z "$broken_config_links" ]; then
    print_success "No broken symlinks found"
else
    if [ -n "$broken_links" ]; then
        print_error "Broken symlinks in home directory:"
        echo "$broken_links" | while read -r link; do
            echo "    - $link"
        done
    fi
    if [ -n "$broken_config_links" ]; then
        print_error "Broken symlinks in ~/.config:"
        echo "$broken_config_links" | while read -r link; do
            echo "    - $link"
        done
    fi
fi

# Check 9: Package management
print_header "9. Package Management"
if [ -f "$DOTFILES_DIR/packages/Brewfile.current" ]; then
    print_warning "Brewfile.current exists (should be deleted after categorizing packages)"
fi

if command -v brew &> /dev/null; then
    brewfile_count=$(find "$DOTFILES_DIR/packages" -name "Brewfile.*" -not -name "*.current" -not -name "*.old" | wc -l | xargs)
    print_info "Found $brewfile_count package category files"
fi

# Check 10: Shell configuration
print_header "10. Shell Configuration"
if [ -d "$DOTFILES_DIR/terminal/zsh/aliases" ]; then
    alias_count=$(find "$DOTFILES_DIR/terminal/zsh/aliases" -name "*.sh" | wc -l | xargs)
    print_success "Modular aliases: $alias_count categories"
else
    print_warning "Modular aliases directory not found"
fi

if [ -d "$DOTFILES_DIR/terminal/zsh/functions" ]; then
    function_count=$(find "$DOTFILES_DIR/terminal/zsh/functions" -name "*.sh" | wc -l | xargs)
    print_success "Modular functions: $function_count categories"
else
    print_warning "Modular functions directory not found"
fi

# Check for backup files
if ls "$DOTFILES_DIR/terminal/zsh/"*.backup 1> /dev/null 2>&1; then
    print_warning "Backup files found in terminal/zsh/ directory (can be deleted)"
fi

# Check 6: Shell Performance
print_header "11. Shell Performance"

# Measure ZSH startup time
if command -v zsh &> /dev/null; then
    # Run test 3 times and average
    total_time=0
    runs=3

    for ((i=1; i<=runs; i++)); do
        startup_time=$(/usr/bin/time -p zsh -i -c exit 2>&1 | grep real | awk '{print $2}')
        total_time=$(echo "$total_time + $startup_time" | bc)
    done

    avg_time=$(echo "scale=3; $total_time / $runs" | bc)
    avg_ms=$(echo "scale=0; $avg_time * 1000 / 1" | bc)

    # Check against thresholds
    if (( $(echo "$avg_time < 0.250" | bc -l) )); then
        print_success "ZSH startup time: ${avg_time}s (${avg_ms}ms) - Excellent!"
    elif (( $(echo "$avg_time < 0.500" | bc -l) )); then
        print_warning "ZSH startup time: ${avg_time}s (${avg_ms}ms) - Acceptable (target: <250ms)"
    else
        print_warning "ZSH startup time: ${avg_time}s (${avg_ms}ms) - Slow (target: <250ms)"
    fi
else
    print_info "ZSH not available (skipping performance check)"
fi

echo ""

# Summary
print_header "Summary"
echo ""
if [ $ISSUES_FOUND -eq 0 ] && [ $WARNINGS_FOUND -eq 0 ]; then
    echo -e "${GREEN}✓ Perfect!${NC} All checks passed."
elif [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${YELLOW}⚠${NC} All critical checks passed with ${YELLOW}$WARNINGS_FOUND warning(s)${NC}"
    echo "  (Warnings are typically optional features or tools)"
else
    echo -e "${RED}✗${NC} Found ${RED}$ISSUES_FOUND issue(s)${NC} and ${YELLOW}$WARNINGS_FOUND warning(s)${NC}"
    echo ""
    echo "Recommended actions:"
    echo "  1. Review errors above"
    echo "  2. Run: cd $DOTFILES_DIR && ./scripts/install.sh"
    echo "  3. Install missing required tools via Homebrew"
fi

echo ""

# Exit with appropriate code
if [ $ISSUES_FOUND -gt 0 ]; then
    exit 1
else
    exit 0
fi
