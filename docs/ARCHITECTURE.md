# Dotfiles Architecture

This document explains how the different components of this dotfiles repository work together to create a cohesive development environment.

## Table of Contents

- [Overview](#overview)
- [Directory Structure](#directory-structure)
- [Symlink Strategy](#symlink-strategy)
- [Boot Sequence](#boot-sequence)
- [Component Integration](#component-integration)
- [Configuration Flow](#configuration-flow)

---

## Overview

This dotfiles repository follows a **modular, category-based architecture** that organizes configurations by purpose rather than by file type. The system uses symlinks to connect versioned configurations to their expected system locations, following the XDG Base Directory Specification where possible.

### Design Principles

1. **Modularity**: Configurations are split into logical, maintainable units
2. **XDG Compliance**: Uses `~/.config/` for modern applications
3. **Version Control**: All configurations tracked in git (except sensitive data)
4. **Automated Setup**: One-command installation via scripts
5. **Cross-machine Portability**: Same configs work on different machines

---

## Directory Structure

```
dotfiles/
├── config/              # XDG-compliant app configs
│   ├── nvim/           # → symlink to editors/neovim/
│   ├── skhd/           # Window management hotkeys
│   ├── yabai/          # Tiling window manager
│   ├── starship.toml   # Shell prompt
│   └── ...             # Other app configs
│
├── editors/            # Text editor configurations
│   ├── neovim/         # Lua-based Neovim config
│   │   ├── init.lua
│   │   └── lua/
│   │       ├── config/     # Core settings
│   │       └── plugins/    # Plugin configs
│   └── vim/            # Legacy Vim config
│
├── git/                # Git version control
│   └── gitconfig       # Git settings & aliases
│
├── mail/               # Email client configs
│   └── mutt/           # Neomutt configuration
│
├── packages/           # Package management
│   ├── Brewfile.*      # Categorized packages
│   └── profiles/       # Installation profiles
│
├── scripts/            # Installation & utilities
│   ├── install.sh      # Main setup script
│   ├── uninstall.sh    # Removal script
│   ├── health-check.sh # Verification script
│   └── macos-setup.sh  # System preferences
│
├── shell/              # Shell configuration
│   ├── zshrc           # Main shell config
│   ├── aliases/        # Modular aliases
│   └── functions/      # Modular functions
│
└── terminal/           # Terminal multiplexer
    ├── tmux.conf       # Tmux configuration
    └── tmuxinator/     # Project sessions
```

---

## Symlink Strategy

The installation script creates symlinks from your home directory to the versioned configurations in the repository. This allows you to edit configs in place and track changes with git.

### Home Directory Symlinks

```bash
~/.zshrc        → ~/dotfiles/shell/zshrc
~/.vimrc        → ~/dotfiles/editors/vim/vimrc
~/.tmux.conf    → ~/dotfiles/terminal/tmux.conf
~/.gitconfig    → ~/dotfiles/git/gitconfig
```

### XDG Config Directory Symlinks

```bash
~/.config/nvim/       → ~/dotfiles/editors/neovim/
~/.config/neomutt/    → ~/dotfiles/mail/mutt/
~/.config/skhd/       → ~/dotfiles/config/skhd/
~/.config/yabai/      → ~/dotfiles/config/yabai/
~/.config/starship.toml → ~/dotfiles/config/starship.toml
# ... and more
```

### Why Symlinks?

- **Single source of truth**: Edit once, change everywhere
- **Git tracking**: All changes are automatically versioned
- **Easy updates**: `git pull` updates all configs instantly
- **Safe rollback**: `git checkout` to revert changes
- **Cross-machine sync**: Push/pull to keep machines in sync

---

## Boot Sequence

Understanding how your shell environment loads helps you customize effectively.

### 1. Terminal Launch

When you open a terminal, the following happens in order:

```
Ghostty (or other terminal)
    ↓
Launches Zsh shell
    ↓
Reads ~/.zshrc (symlinked to shell/zshrc)
```

### 2. Shell Configuration Loading

The `shell/zshrc` file orchestrates loading in this order:

```zsh
# 1. Oh My Zsh framework
source $ZSH/oh-my-zsh.sh

# 2. Plugins (syntax highlighting, autosuggestions)
source $ZSH_CUSTOM/plugins/...

# 3. Modular aliases (auto-discovered)
for alias_file in shell/aliases/*.sh; do
  source "$alias_file"
done

# 4. Modular functions (auto-discovered)
for function_file in shell/functions/*.sh; do
  source "$function_file"
done

# 5. Tool initializations
eval "$(zoxide init zsh)"        # Smart cd
eval "$(fnm env)"                # Node version manager
eval "$(starship init zsh)"      # Prompt

# 6. FZF integration (history/file search)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
```

### 3. Tool Availability Checks

Aliases are conditionally created only if tools exist:

```zsh
# From shell/aliases/tools.sh
command -v eza &> /dev/null && alias ls="eza"
command -v bat &> /dev/null && alias cat="bat"
# ... prevents errors if tools aren't installed
```

---

## Component Integration

### Shell + Git

```
shell/zshrc loads git/gitconfig aliases
    ↓
Git commands use custom aliases
    ↓ (example: git hist)
Pretty log format defined in gitconfig
```

**Git Aliases Available:**
- `git co` → checkout
- `git ci` → commit
- `git st` → status
- `git hist` → pretty log graph

### Shell + Neovim

```
shell/zshrc sets alias: vim="nvim"
    ↓
Launches Neovim with config from editors/neovim/
    ↓
init.lua loads plugins via lazy.nvim
    ↓
LSP, Telescope, Treesitter configured
```

**Integration Points:**
- Shell `$EDITOR` variable set to `nvim`
- Git commit messages open in Neovim
- Tmux bindings use Neovim for editing

### Shell + Tmux

```
shell/zshrc starts with Tmux available
    ↓
User runs: tmux or tmuxinator start <project>
    ↓
terminal/tmux.conf loads with plugins
    ↓
Sessions defined in terminal/tmuxinator/
```

**Key Bindings:**
- Prefix: `F12` (instead of default Ctrl-b)
- Vi-mode navigation in copy mode
- Plugins via TPM (install with `F12 + I`)

### Package Management

```
packages/Brewfile.* categories define software
    ↓
scripts/install.sh offers to install packages
    ↓
User runs: brew bundle --file=packages/Brewfile.<category>
    ↓
Tools become available to shell aliases
```

**Workflow:**
1. Edit package categories in `packages/Brewfile.*`
2. Run `packages/sync-packages.sh` to verify
3. Run `brew bundle` to install
4. Shell aliases auto-detect and activate

---

## Configuration Flow

### Adding a New Tool

Here's the flow when adding a new tool to your environment:

```
1. Add to packages/Brewfile.<category>
   brew "newtool"

2. Install the package
   brew install newtool

3. (Optional) Add alias in shell/aliases/<category>.sh
   command -v newtool &> /dev/null && alias nt="newtool"

4. (Optional) Add function in shell/functions/<category>.sh
   newtool_wrapper() {
     newtool "$@" --with-defaults
   }

5. Reload shell or source config
   source ~/.zshrc

6. Tool is now available!
   nt --help
```

### Customizing Configurations

**For Shell:**
1. Edit files in `shell/aliases/` or `shell/functions/`
2. Reload: `source ~/.zshrc`
3. Changes take effect immediately

**For Neovim:**
1. Edit files in `editors/neovim/lua/`
2. Restart Neovim or `:source $MYVIMRC`
3. Plugins auto-sync via lazy.nvim

**For Git:**
1. Edit `git/gitconfig`
2. Changes take effect immediately
3. Test with `git config --list`

**For Tmux:**
1. Edit `terminal/tmux.conf`
2. Reload: `tmux source ~/.tmux.conf` or `F12 + r`
3. May need to restart tmux for some changes

### Machine-Specific Overrides

For configurations that differ between machines (work vs. personal):

```bash
# Git: Add to git/gitconfig
[include]
  path = ~/.gitconfig.local

# Shell: Add at end of shell/zshrc
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Create local files (not tracked in git)
echo "export WORK_SPECIFIC_VAR=true" > ~/.zshrc.local
echo "[user]\n  email = work@company.com" > ~/.gitconfig.local
```

---

## Plugin Managers

Three plugin managers maintain different parts of the system:

### 1. Oh My Zsh (Shell)
- **Location**: `~/.oh-my-zsh/`
- **Purpose**: Shell framework, themes, plugins
- **Update**: `omz update`
- **Config**: `shell/zshrc` (ZSH_THEME, plugins array)

### 2. lazy.nvim (Neovim)
- **Location**: `~/.local/share/nvim/lazy/`
- **Purpose**: Neovim plugin management
- **Update**: `:Lazy sync` inside Neovim
- **Config**: `editors/neovim/lua/plugins/*.lua`

### 3. TPM (Tmux)
- **Location**: `~/.tmux/plugins/tpm/`
- **Purpose**: Tmux plugin management
- **Install Plugins**: `F12 + I`
- **Update Plugins**: `F12 + U`
- **Config**: `terminal/tmux.conf` (set -g @plugin lines)

---

## Environment Variables

Key environment variables set by the configurations:

```bash
# XDG Base Directories (shell/zshrc)
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Editor (shell/zshrc)
export EDITOR="nvim"
export VISUAL="nvim"

# Oh My Zsh (shell/zshrc)
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="robbyrussell"  # Or overridden by Starship

# Language Version Managers
export FNM_DIR="$HOME/.fnm"      # Node via FNM

# Paths (shell/zshrc)
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# macOS Volume Paths (shell/zshrc - macOS only)
export ARCHIVE="/Volumes/Archive"
export AUDIO="/Volumes/Audio"
export MEDIA="/Volumes/Media"
export PORTABLE="/Volumes/Portable"
export VIDEO="/Volumes/Video"

# macOS Derived Paths (shell/zshrc - macOS only)
export CINEMA="$MEDIA/Cinema"
export DRIVE="$ARCHIVE/Drive"
export MOBILE="$HOME/Library/Mobile Documents"
export MUSIC="$MEDIA/Music/FLAC"
export PROJECTS="$AUDIO/Audio/Projects"
export SHARED="$DRIVE/Shared"
export TELEVISION="$MEDIA/Television"

# Cross-Platform Paths (shell/zshrc)
export DOTFILES="$HOME/dotfiles"
export DOWNLOADS="$HOME/Downloads"
export WORK="$HOME/Work"
```

---

## Health Checking

Run the health check script to verify everything is configured correctly:

```bash
./scripts/health-check.sh
```

This checks:
- ✓ Repository integrity
- ✓ Symlinks are correct
- ✓ Required tools installed
- ✓ Plugin managers present
- ✓ No broken symlinks

---

## Troubleshooting

### "Command not found" errors

1. Check if tool is installed: `which <command>`
2. Check if it's in Brewfile: `grep <command> packages/Brewfile.*`
3. Install if needed: `brew install <command>`
4. Reload shell: `source ~/.zshrc`

### Symlinks not working

1. Run health check: `./scripts/health-check.sh`
2. Re-run install: `./scripts/install.sh`
3. Check manually: `ls -la ~/.zshrc`

### Neovim plugins not loading

1. Check lazy.nvim installed: `ls ~/.local/share/nvim/lazy/`
2. Open Neovim and run: `:Lazy sync`
3. Check for errors: `:Lazy log`

### Shell config not loading

1. Verify symlink: `ls -la ~/.zshrc`
2. Check for syntax errors: `zsh -n ~/.zshrc`
3. Source manually: `source ~/.zshrc`

---

## Further Reading

- [Main README](../README.md) - Installation and overview
- [Shell Documentation](../shell/README.md) - Shell configuration details
- [Package Management](../packages/README.md) - Package workflow
- [Vim/Neovim Guide](vim-neovim-configuration-review.md) - Editor keybindings

---

## Summary Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Terminal Launch                          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│  shell/zshrc  (Main orchestrator)                           │
│  • Loads Oh My Zsh                                          │
│  • Sources aliases/* and functions/*                        │
│  • Initializes tools (zoxide, fnm, starship)                │
│  • Sets environment variables                                │
└─┬───────────────┬───────────────┬───────────────┬───────────┘
  │               │               │               │
  ▼               ▼               ▼               ▼
┌──────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│ Git  │    │  Neovim  │    │   Tmux   │    │ Packages │
│Config│    │  Config  │    │  Config  │    │ Brewfile │
└──────┘    └──────────┘    └──────────┘    └──────────┘
  │               │               │               │
  ▼               ▼               ▼               ▼
git commands   vim → nvim      tmux or       brew install
with aliases   w/ LSP, etc.    tmuxinator    tools/apps
```

The architecture creates a cohesive, self-maintaining development environment where components work together seamlessly.
