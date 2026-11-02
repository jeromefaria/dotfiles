#!/bin/bash

################################################################################
# Dotfiles Installation Script
#
# This script automates the installation and configuration of dotfiles.
# It creates backups of existing files and symlinks dotfiles to the home directory.
#
# Features:
# - Automatic error handling and rollback on failure
# - Idempotent (safe to run multiple times)
# - Non-interactive mode support (--yes flag)
# - Comprehensive dependency checking
# - Integration with health-check.sh
################################################################################

# -E (errtrace) is load-bearing, not decoration: without it a shell function
# does not inherit the ERR trap, so every failure inside every phase of this
# script exited 1 in silence and on_error never ran. Ten functions maintain
# CURRENT_STEP to feed a message that only a Ctrl-C could produce, because
# INT and TERM fire inside functions and ERR does not.
set -Eeuo pipefail  # exit on error, undefined vars, pipe failures; ERR reaches functions

# Shared color + print helpers
source "$(dirname "${BASH_SOURCE[0]}")/lib/io.sh"

# Configuration
# Repo root, derived from this script's own location so the checkout works from
# any directory. An explicit DOTFILES_DIR still wins, which is how bootstrap.sh
# hands down its --dir value.
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

# Command-line flags
# Which machine this is. personal installs everything; work installs the
# development environment only. Defaults to personal so that an install with no
# --profile behaves exactly as it always has.
PROFILE="personal"
INTERACTIVE=true
SKIP_PACKAGES=false
SKIP_MACOS=false
DRY_RUN=false

# Names the step in progress so on_error can say where it died.
CURRENT_STEP=""

# Error handler
on_error() {
  local line_number=$1

  print_error "Installation failed at line $line_number during: $CURRENT_STEP"

  if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
    print_warning "A backup was created at: $BACKUP_DIR"
    print_info "To restore your previous configuration, run:"
    print_info "  ./scripts/restore.sh --backup $BACKUP_DIR"
  fi

  echo -e "\n${RED}Installation incomplete. Please review the error above.${NC}\n"
  exit 1
}

# Set trap for error handling
trap 'on_error $LINENO' ERR INT TERM

# Parse command-line arguments
parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      -y|--yes)
        INTERACTIVE=false
        shift
        ;;
      --skip-packages)
        SKIP_PACKAGES=true
        shift
        ;;
      --skip-macos)
        SKIP_MACOS=true
        shift
        ;;
      --profile)
        PROFILE="${2:-}"
        case "$PROFILE" in
          personal|work) ;;
          *)
            print_error "Unknown profile: '${PROFILE}'. Expected 'personal' or 'work'."
            exit 1
            ;;
        esac
        shift 2
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      -h|--help)
        show_help
        exit 0
        ;;
      *)
        print_error "Unknown option: $1"
        show_help
        exit 1
        ;;
    esac
  done
}

# Show help message
show_help() {
  cat <<EOF
Dotfiles Installation Script

Usage: $0 [OPTIONS]

Options:
  -y, --yes             Non-interactive mode (answer yes to all prompts)
  --profile NAME        personal (default) or work
  --skip-packages       Skip Homebrew package installation
  --skip-macos          Skip macOS system settings
  --dry-run             Show what would be done without making changes
  -h, --help            Show this help message

Profiles:
  personal  Everything. The default, so an install with no --profile is
            unchanged from before profiles existed.

  work      A development environment on a machine that is not your own
            setup. Installs the 'work' package profile (base + dev +
            browsers) and leaves out:
              - music production and the media stack
              - personal backup tooling (none of which install.sh ever
                installed anyway — each has its own manage script)
              - the personal git identity; a ~/.gitconfig.local stub is
                seeded for you to fill in instead
              - the neomutt mail configuration
              - window and input managers (yabai, skhd, aerospace,
                karabiner-elements and friends)
              - media tool configs (beets, mpv, musikcube, aria2)
            The choice is written to ~/.dotfiles-profile so later shells
            apply the same gating.

Examples:
  $0                      # Interactive, personal
  $0 --yes                # Automated, personal
  $0 --profile work --yes # Automated work machine
  $0 --skip-packages      # Install without packages
  $0 --yes --skip-macos   # Automated, skip macOS settings

EOF
}

# Check required commands
check_required_commands() {
  CURRENT_STEP="Checking required commands"

  local required=(git curl zsh)
  local missing=()

  for cmd in "${required[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
      missing+=("$cmd")
    fi
  done

  if [ ${#missing[@]} -gt 0 ]; then
    print_error "Missing required commands: ${missing[*]}"
    print_info "Please install these commands and try again"
    exit 1
  fi

  print_success "All required commands available"
}

# Check if running on macOS
check_os() {
  CURRENT_STEP="Checking the operating system"

  if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only."
    exit 1
  fi
  print_success "Running on macOS"
}

# Check if Homebrew is installed
check_homebrew() {
  CURRENT_STEP="Checking dependencies"
  print_header "Checking Dependencies"

  if ! command -v brew &> /dev/null; then
    if [ "$DRY_RUN" = true ]; then
      print_info "[DRY RUN] Would install Homebrew"
    else
      print_warning "Homebrew not found. Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      print_success "Homebrew installed"
    fi
  else
    print_success "Homebrew is already installed"
  fi
}

# Create backup directory
create_backup_dir() {
  if [ "$DRY_RUN" = true ]; then
    print_info "[DRY RUN] Would create backup directory: $BACKUP_DIR"
    return 0
  fi

  if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    print_success "Created backup directory: $BACKUP_DIR"
  fi
}

# Backup existing file
backup_file() {
  local file=$1
  local filename
  filename=$(basename "$file")

  if [ -e "$file" ] && [ ! -L "$file" ]; then
    cp -r "$file" "$BACKUP_DIR/$filename"
    print_info "Backed up: $filename"
    return 0
  fi
  return 1
}

# A pre-existing symlink is replaced rather than backed up, and backup_file is
# right to refuse it: `cp -r` would dereference and copy the target's contents
# instead of the link. Nothing is destroyed either way — `rm -rf` on a symlink
# takes the link, not what it points at — so the file at the far end survives in
# whatever repo owns it. What does not survive is the mapping: which repo this
# path used to come from. That is one line of text, so keep it as one.
#
# Deliberately not `cp -P` into BACKUP_DIR. restore.sh walks a backup with
# `find -type f`, which does not match a symlink, so a copied link would sit in
# the backup looking restorable and never be restored. A manifest is honest
# about needing a person.
record_replaced_symlink() {
  local link=$1

  [ -L "$link" ] || return 0

  local manifest="$BACKUP_DIR/replaced-symlinks.txt"
  mkdir -p "$BACKUP_DIR"
  printf '%s -> %s\n' "$link" "$(readlink "$link")" >> "$manifest"
  print_info "Recorded the replaced symlink: $(basename "$link") → $(readlink "$link")"
}

# Create symlink (idempotent)
# True when installing this user's own machine. Reads better at the call sites
# than repeating the comparison, and mirrors the same helper in the zshrc.
is_personal_profile() {
  [ "$PROFILE" = "personal" ]
}

# Record the profile where the shell can find it. The zshrc reads this file on
# every start, so without it a work machine would install trimmed and then come
# up with the full personal surface anyway.
persist_profile() {
  CURRENT_STEP="Recording the profile"

  local marker="$HOME/.dotfiles-profile"

  if [ "$DRY_RUN" = true ]; then
    print_info "[DRY RUN] Would record profile '$PROFILE' in $marker"
    return 0
  fi

  echo "$PROFILE" > "$marker"
  print_success "Profile '$PROFILE' recorded in ~/.dotfiles-profile"
}

# Create a directory unless this is a dry run. Pulled out because the two
# call sites below both had to repeat the existence test and the DRY_RUN check,
# and the dry-run half kept being the one that got forgotten.
ensure_dir() {
  local dir=$1

  [ -d "$dir" ] && return 0

  if [ "$DRY_RUN" = true ]; then
    print_info "[DRY RUN] Would create directory: $dir"
    return 0
  fi

  mkdir -p "$dir"
}

# Do two paths name the same entry? dirname is resolved with `pwd -P` so a
# symlinked parent collapses to its real location, while the basename is left
# alone — a final symlink is compared as itself, not as what it points at.
same_path() {
  local first=$1
  local second=$2
  local first_dir second_dir

  first_dir=$(cd "$(dirname "$first")" 2>/dev/null && pwd -P) || return 1
  second_dir=$(cd "$(dirname "$second")" 2>/dev/null && pwd -P) || return 1

  [ "$first_dir/$(basename "$first")" = "$second_dir/$(basename "$second")" ]
}

create_symlink() {
  local source=$1
  local target=$2
  local target_name
  target_name=$(basename "$target")

  # SAFETY: Prevent circular symlinks - source must not be a symlink itself
  if [ -L "$source" ]; then
    print_error "Circular symlink risk: source is already a symlink: $source"
    print_error "Target would be: $target"
    print_error "This would create: $target → $source → $(readlink "$source")"
    return 1
  fi

  # SAFETY: Verify source exists (file or directory)
  if [ ! -e "$source" ]; then
    print_error "Source does not exist: $source"
    return 1
  fi

  # Check if symlink already points to correct location (idempotent)
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    print_success "Already linked: $target_name"
    return 0
  fi

  # SAFETY: the target may already *be* the source, reached through a symlinked
  # parent — with $HOME/.config → config/, $HOME/.config/nvim is the very same
  # directory as config/nvim. The check above misses that, because the target is
  # not itself a symlink; the circular-symlink check misses it too, because the
  # source is a real directory. Without this one the rm -rf below deletes the
  # source and leaves a broken link pointing at where it used to be.
  if [ -e "$target" ] && same_path "$source" "$target"; then
    print_success "Already in place: $target_name"
    return 0
  fi

  # Dry run mode
  if [ "$DRY_RUN" = true ]; then
    print_info "[DRY RUN] Would link: $target_name → $source"
    return 0
  fi

  # Backup and remove existing file/symlink.
  #
  # `|| true` because backup_file returns 1 for anything it declines to copy,
  # a symlink included, and a bare non-zero call under set -e aborted the whole
  # install at the first target some other dotfiles manager already owned. The
  # return value is a "nothing was copied" signal, not a failure, so the two
  # cases are handled separately: content goes to BACKUP_DIR, a link's mapping
  # goes to the manifest.
  if [ -e "$target" ] || [ -L "$target" ]; then
    backup_file "$target" || true
    record_replaced_symlink "$target"
    rm -rf "$target"
  fi

  # Create the symlink
  ln -s "$source" "$target"
  print_success "Linked: $target_name"
}

# Install Oh My Zsh
install_oh_my_zsh() {
  CURRENT_STEP="Installing Oh My Zsh"
  print_header "Installing Oh My Zsh"

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    if [ "$DRY_RUN" = true ]; then
      print_info "[DRY RUN] Would install Oh My Zsh"
    else
      print_info "Installing Oh My Zsh..."
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
      print_success "Oh My Zsh installed"
    fi
  else
    print_success "Oh My Zsh is already installed"
  fi

  # Custom plugins. Every entry here is named in the plugins=() list in
  # terminal/zsh/zshrc and is NOT bundled with Oh My Zsh, so omitting one costs
  # a `plugin not found` line on every shell start and silently drops whatever
  # it provided — zsh-vi-mode in particular is load-bearing, with its own
  # keybindings, post-init hooks and ZVM_* settings in the zshrc.
  #
  # git-flow-completion is on this list because upstream Oh My Zsh ships
  # git-flow and git-flow-avh but not it. The copy on the machine this was
  # written on sits in $ZSH/plugins rather than $ZSH_CUSTOM/plugins and is
  # untracked there, so it looked stock when checked locally and was missing
  # on a genuinely fresh install.
  local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  local custom_plugins=(
    "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting.git"
    "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
    "zsh-autopair:https://github.com/hlissner/zsh-autopair"
    "git-open:https://github.com/paulirish/git-open"
    "zsh-vi-mode:https://github.com/jeffreytse/zsh-vi-mode"
    "git-flow-completion:https://github.com/bobthecow/git-flow-completion"
  )

  local entry plugin_name plugin_url
  for entry in "${custom_plugins[@]}"; do
    plugin_name="${entry%%:*}"
    plugin_url="${entry#*:}"

    if [ -d "$ZSH_CUSTOM/plugins/$plugin_name" ]; then
      print_success "$plugin_name is already installed"
    elif [ "$DRY_RUN" = true ]; then
      print_info "[DRY RUN] Would clone $plugin_name"
    else
      print_info "Installing $plugin_name..."
      git clone --quiet "$plugin_url" "$ZSH_CUSTOM/plugins/$plugin_name"
      print_success "$plugin_name installed"
    fi
  done
}

# Install Vim Plug (for Vim only, not Neovim)
install_vim_plug() {
  CURRENT_STEP="Installing Vim Plug"
  print_header "Installing Vim Plug"

  if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    if [ "$DRY_RUN" = true ]; then
      print_info "[DRY RUN] Would install vim-plug to ~/.vim/autoload/plug.vim"
    else
      print_info "Installing vim-plug for Vim..."
      curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      print_success "vim-plug installed"
    fi
  else
    print_success "vim-plug is already installed"
  fi

  print_info "Neovim uses lazy.nvim (no manual installation required)"
}

# Install Tmux Plugin Manager
install_tpm() {
  CURRENT_STEP="Installing Tmux Plugin Manager"
  print_header "Installing Tmux Plugin Manager"

  if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    if [ "$DRY_RUN" = true ]; then
      print_info "[DRY RUN] Would install TPM to ~/.tmux/plugins/tpm"
    else
      print_info "Installing TPM..."
      git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
      print_success "TPM installed"
    fi
  else
    print_success "TPM is already installed"
  fi
}

# Link dotfiles
link_dotfiles() {
  CURRENT_STEP="Linking dotfiles"
  print_header "Linking Dotfiles"

  create_backup_dir

  # Main dotfiles (organized by category)
  create_symlink "$DOTFILES_DIR/terminal/zsh/zshrc" "$HOME/.zshrc"
  create_symlink "$DOTFILES_DIR/editors/vim/vimrc" "$HOME/.vimrc"
  create_symlink "$DOTFILES_DIR/terminal/tmux/tmux.conf" "$HOME/.tmux.conf"
  create_symlink "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"

  # Vim directory (separate from Neovim for systems without Neovim)
  ensure_dir "$HOME/.vim"
  create_symlink "$DOTFILES_DIR/editors/vim" "$HOME/.vim/config"

  # XDG-compliant configs.
  print_info "Linking XDG-compliant configurations..."

  # A personal machine takes config/ whole, so $HOME/.config *is* the repo's
  # config directory: every tracked config is live the moment it lands, and no
  # per-item list can drift behind the tree. That drift is why this exists — the
  # per-item list had fallen 18 configs behind what the repo tracks, and the
  # only reason nobody noticed is that the machine it was written on already had
  # the whole-directory link. config/neomutt and config/tmuxinator are relative
  # symlinks inside the repo precisely so this picks them up, which is why
  # neither is linked separately here.
  if is_personal_profile; then
    create_symlink "$DOTFILES_DIR/config" "$HOME/.config"
  else
    ensure_dir "$HOME/.config"

    # A work machine gets named items instead, because one link cannot filter.
    # beets/mpv/musikcube/aria2 serve the music and media work; skhd/yabai are
    # window and input management, which on managed hardware usually cannot get
    # the accessibility permissions they need anyway; yazi binds ten keys to
    # /Volumes/Archive, /Volumes/Audio and /Volumes/Media and opens media with
    # mpv, so on other hardware the keys are dead and the config describes a
    # personal media library; and the neomutt setup is a personal Gmail
    # account. None of them belong on hardware that is not this user's own.
    print_info "Profile '$PROFILE': skipping media, window-manager and mail configs"

    # atuin, vifm and git were missing from this list rather than excluded from
    # it. All three tools are installed by the work package set — atuin from
    # base, vifm from dev, git from base — so a work machine had the binary and
    # none of the configuration, which nothing reported until health-check
    # grew a check for exactly that. git is here because both gitconfigs name
    # the global ignore by its XDG path, so on this profile the link is what
    # makes ~/.config/git/ignore exist at all.
    local config_items=(
      "nvim"
      "starship.toml"
      "atuin"
      "bat"
      "gh"
      "git"
      "vifm"
    )

    for item in "${config_items[@]}"; do
      local source="$DOTFILES_DIR/config/$item"
      local target="$HOME/.config/$item"

      # Only create symlink if source exists
      if [ -e "$source" ] || [ -L "$source" ]; then
        create_symlink "$source" "$target"
      fi
    done

    # tmuxinator's real home is outside config/; inside the repo it is a
    # relative symlink, and create_symlink refuses a symlink as its source.
    if [ -e "$DOTFILES_DIR/terminal/tmux/tmuxinator" ]; then
      create_symlink "$DOTFILES_DIR/terminal/tmux/tmuxinator" "$HOME/.config/tmuxinator"
    fi
  fi

  print_success "All dotfiles linked successfully"
}

# Install packages from Brewfile
install_packages() {
  CURRENT_STEP="Installing packages"

  if [ "$SKIP_PACKAGES" = true ]; then
    print_info "Skipping package installation (--skip-packages flag)"
    return 0
  fi

  print_header "Installing Packages"

  local install_packages=false

  if [ "$INTERACTIVE" = false ]; then
    install_packages=true
    print_info "Installing packages automatically (--yes flag)"
  else
    read -p "Do you want to install packages from Brewfile? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      install_packages=true
    fi
  fi

  # There is no plain `Brewfile` in packages/ — only Brewfile.<category> — so
  # bare `brew bundle install` here failed with "No Brewfile found" and took the
  # whole install down with it via the ERR trap. install-packages.sh is the
  # interface that understands the categories, and routing through it is also
  # what lets the profile pick a package set.
  local package_profile="full"
  if ! is_personal_profile; then
    package_profile="work"
  fi

  if [ "$install_packages" = true ]; then
    if [ "$DRY_RUN" = true ]; then
      print_info "[DRY RUN] Would install the '$package_profile' package profile"
    else
      print_info "Installing Homebrew packages ($package_profile profile)..."
      bash "$DOTFILES_DIR/packages/install-packages.sh" --profile "$package_profile"
      print_success "Packages installed"
    fi
  else
    print_info "Skipping package installation"
  fi
}

# Apply macOS settings
apply_macos_settings() {
  CURRENT_STEP="Applying macOS settings"

  if [ "$SKIP_MACOS" = true ]; then
    print_info "Skipping macOS settings (--skip-macos flag)"
    return 0
  fi

  print_header "macOS System Settings"

  local apply_settings=false

  if [ "$INTERACTIVE" = false ]; then
    apply_settings=true
    print_warning "Applying macOS settings automatically (--yes flag)"
    print_warning "This will modify system settings"
  else
    read -p "Do you want to apply macOS system settings? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      print_warning "This will modify system settings. Review $DOTFILES_DIR/scripts/macos-setup.sh before proceeding."
      read -p "Continue? (y/N) " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        apply_settings=true
      fi
    fi
  fi

  if [ "$apply_settings" = true ]; then
    if [ "$DRY_RUN" = true ]; then
      print_info "[DRY RUN] Would apply macOS system settings"
    else
      print_info "Applying macOS settings ($PROFILE)..."
      # Bare macos-setup.sh prompts interactively for which groups to apply.
      # On a work machine say so explicitly instead: --dev covers base plus the
      # developer settings and never touches personal.sh or apps.sh.
      if is_personal_profile; then
        bash "$DOTFILES_DIR/scripts/macos-setup.sh"
      else
        bash "$DOTFILES_DIR/scripts/macos-setup.sh" --dev
      fi
      print_success "macOS settings applied"
      print_warning "Some changes may require a logout or restart"
    fi
  else
    print_info "Skipping macOS settings"
  fi
}

# Set ZSH as default shell
set_zsh_shell() {
  CURRENT_STEP="Setting ZSH as default shell"
  print_header "Setting Default Shell"

  if [ "$SHELL" != "$(which zsh)" ]; then
    if [ "$DRY_RUN" = true ]; then
      print_info "[DRY RUN] Would set default shell to $(which zsh)"
    else
      print_info "Setting ZSH as default shell..."
      # Non-fatal on purpose. chsh prompts for a password, and fails outright
      # where there is no tty to prompt on or the account is directory-managed
      # — common on corporate hardware, and the case on a CI runner. Letting
      # the ERR trap abort here would discard a complete, successful install
      # over the one step a person can finish by hand in five seconds.
      if chsh -s "$(which zsh)"; then
        print_success "ZSH set as default shell"
        print_warning "Restart your terminal for changes to take effect"
      else
        print_warning "Could not change the login shell automatically."
        print_info "Everything else is installed. To finish: chsh -s $(which zsh)"
      fi
    fi
  else
    print_success "ZSH is already the default shell"
  fi
}

# Run health check
run_health_check() {
  CURRENT_STEP="Running health check"

  print_header "Verifying Installation"

  if [ -f "$DOTFILES_DIR/scripts/health-check.sh" ]; then
    if bash "$DOTFILES_DIR/scripts/health-check.sh"; then
      print_success "Health check passed!"
    else
      print_warning "Health check found some issues. Review output above."
    fi
  else
    print_warning "Health check script not found. Skipping verification."
  fi
}

# Seed *.template files: for each `foo.template` under config/, if `foo`
# does not already exist, copy the template to `foo`. The live copy lives
# alongside the template because ~/.config → DOTFILES_DIR/config via the
# repo's install-time symlink, so in-place seeding IS the runtime location.
# Every seeded destination is gitignored (verified) so no local credential
# ever drifts back into tracking.
seed_templates() {
  CURRENT_STEP="Seeding config templates"
  print_header "Seeding config templates"

  local template dest
  local seeded=0
  local skipped=0
  while IFS= read -r template; do
    dest="${template%.template}"
    local rel="${dest#$DOTFILES_DIR/}"

    if [ -e "$dest" ]; then
      print_success "Already present: $rel"
      skipped=$((skipped + 1))
      continue
    fi

    if [ "$DRY_RUN" = true ]; then
      print_info "[DRY RUN] Would seed: $rel"
      seeded=$((seeded + 1))
      continue
    fi

    if cp "$template" "$dest"; then
      print_success "Seeded: $rel"
      seeded=$((seeded + 1))
    else
      print_error "Failed to seed: $rel"
    fi
  done < <(find "$DOTFILES_DIR/config" -name "*.template" -type f 2>/dev/null)

  print_info "Templates: $seeded seeded, $skipped already present"

  seed_work_git_identity
}

# git/gitconfig sets this user's personal address, and gitconfig includes
# ~/.gitconfig.local last so anything there wins. On a work machine that
# override is the difference between commits going out as the right author and
# going out as a personal address, so seed it rather than relying on the
# installer's reader noticing the comment in gitconfig.
#
# The seeded address is a deliberate sentinel in the RFC 2606 .invalid TLD, not
# a blank. Two things that look like they would be safer are not:
#   - `email =` (empty) still commits, authored as `Name <>`
#   - user.useConfigOnly only disables auto-detection; an explicitly set value,
#     empty included, still counts as configured, so it does not block either
# Nothing in git refuses a commit here, so the next best thing is an author
# that cannot be mistaken for real and cannot receive mail.
seed_work_git_identity() {
  if is_personal_profile; then
    return 0
  fi

  local local_config="$HOME/.gitconfig.local"

  if [ -e "$local_config" ]; then
    print_success "Already present: ~/.gitconfig.local"
    return 0
  fi

  if [ "$DRY_RUN" = true ]; then
    print_info "[DRY RUN] Would seed ~/.gitconfig.local with a blank work identity"
    return 0
  fi

  cat > "$local_config" <<'GITLOCAL'
# Machine-specific git settings for a work machine.
#
# git/gitconfig in the dotfiles sets a personal name and email, then includes
# this file last, so whatever is set here wins. Replace the address below with
# your work one before committing anything.
#
# The placeholder is in the .invalid TLD, which RFC 2606 reserves so it can
# never resolve. It is a sentinel, not a safety net: git will happily commit
# with it, so the protection is that it is impossible to miss in `git log`,
# obviously not a real person, and rejected or flagged by most forges. A blank
# email would NOT have been safer — git commits anyway, authored as `Name <>`.

[user]
	email = replace-with-work-address@invalid
	# name = Your Name As Work Expects It
	# signingkey = ABCD1234
GITLOCAL

  print_success "Seeded ~/.gitconfig.local with a placeholder work identity"
  print_warning "Commits will be authored as replace-with-work-address@invalid until you edit it"
}

# Main installation flow
main() {
  # Parse command-line arguments
  parse_args "$@"

  # Only when there is a terminal to clear. `clear` exits non-zero with "TERM
  # environment variable not set." anywhere TERM is absent — CI, cron, a
  # curl|bash in a bare environment — and the ERR trap turns that into an
  # aborted install before a single line of work has run.
  if [ -t 1 ] && [ -n "${TERM:-}" ]; then
    clear
  fi

  echo -e "${BLUE}"
  echo "╔═══════════════════════════════════════════════════════════╗"
  echo "║                                                           ║"
  echo "║              Dotfiles Installation Script                ║"
  echo "║                                                           ║"
  echo "╚═══════════════════════════════════════════════════════════╝"
  echo -e "${NC}\n"

  if [ "$DRY_RUN" = true ]; then
    print_warning "DRY RUN MODE - No changes will be made"
    echo
  fi

  if [ "$INTERACTIVE" = false ]; then
    print_info "Running in non-interactive mode (--yes flag)"
    echo
  fi

  print_info "Profile: $PROFILE"
  if ! is_personal_profile; then
    print_info "Development environment only — no music, media, personal identity or window managers"
  fi
  echo

  check_os
  persist_profile
  check_required_commands
  check_homebrew
  install_oh_my_zsh
  install_vim_plug
  install_tpm
  link_dotfiles
  seed_templates
  install_packages
  apply_macos_settings
  set_zsh_shell

  # Run health check if not in dry-run mode
  if [ "$DRY_RUN" = false ]; then
    run_health_check
  fi

  print_header "Installation Complete!"

  if [ -d "$BACKUP_DIR" ] && [ "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
    print_info "Backups saved to: $BACKUP_DIR"
    print_info "To restore, run: ./scripts/restore.sh --backup $BACKUP_DIR"
  fi

  if [ "$DRY_RUN" = true ]; then
    echo -e "\n${BLUE}✨ Dry run complete! No changes were made.${NC}\n"
    echo -e "Run without ${BLUE}--dry-run${NC} to apply changes.\n"
  else
    echo -e "\n${GREEN}✨ Your dotfiles have been installed successfully!${NC}\n"
    echo -e "Next steps:"
    echo -e "  1. Restart your terminal"
    echo -e "  2. For Vim: Run ${BLUE}:PlugInstall${NC} to install plugins"
    echo -e "  3. For Neovim: Plugins will auto-install with ${BLUE}lazy.nvim${NC} on first launch"
    echo -e "  4. Open tmux and press ${BLUE}prefix + I${NC} to install tmux plugins"
    echo -e "  5. Enjoy your new environment! 🚀\n"
  fi
}

# Run main installation only when executed directly (not when sourced for tests)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
