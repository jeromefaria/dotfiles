# Quick Start Guide

Get your dotfiles up and running in 5 minutes.

## Prerequisites

Before you begin, ensure you have:

**For macOS:**
- **macOS 11+** (Big Sur or later)
- **Terminal access** (Terminal.app, iTerm2, or similar)
- **Internet connection** (for downloading dependencies)

Xcode Command Line Tools will be installed automatically if needed.

**For Windows:**
- **Git Bash** installed
- **Internet connection** (for downloading dependencies)

See [Windows Setup Guide](WINDOWS-SETUP.md) for Windows-specific instructions.

## Installation

### Option 1: One-Line Install (Recommended)

Bootstrap your entire system with one command:

```bash
curl -fsSL https://raw.githubusercontent.com/jeromefaria/dotfiles/master/scripts/bootstrap.sh | bash
```

**This will:**
1. Check system requirements
2. Clone dotfiles to `~/dotfiles`
3. Install Homebrew (if not present)
4. Run the installation script
5. Set up all configurations

**Wait 5-10 minutes** for the installation to complete.

### Option 2: Manual Install

If you prefer more control:

```bash
# 1. Clone the repository
git clone https://github.com/jeromefaria/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Run installation
./scripts/install.sh
```

### Option 3: Custom Directory Installation

Install to a custom location (fully location-independent):

```bash
# 1. Clone to your preferred location
git clone https://github.com/jeromefaria/dotfiles.git ~/my-custom-location
cd ~/my-custom-location

# 2. Set DOTFILES_DIR environment variable and run installation
DOTFILES_DIR=~/my-custom-location ./scripts/install.sh
```

The scripts will automatically detect and use the custom location.

## Verify Installation

Check that everything is working:

```bash
# Run the health check
./scripts/health-check.sh
```

**Expected output:**
```
✓ Homebrew installed
✓ ZSH is default shell
✓ Oh My Zsh installed
✓ Dotfiles symlinked correctly
✓ All plugin managers present
```

## Test Key Features

### 1. Shell Enhancements

Open a new terminal and test:

```bash
# Smart directory navigation with zoxide
z dotfiles        # Jump to dotfiles directory
zi                # Interactive directory picker

# Modern CLI tools
ls                # Enhanced with eza (colors, git status)
cat README.md     # Syntax highlighted with bat
fd README         # Fast file search

# Quick navigation
..                # Go up one directory
...               # Go up two directories
....              # Go up three directories
```

### 2. Git Shortcuts

```bash
# Navigate to any git repository first
cd ~/dotfiles

# Try these git aliases
git st            # Status (shorter)
git hist          # Pretty commit history
git co master     # Checkout branch
```

### 3. Neovim (if installed)

```bash
nvim README.md
```

**Try these keys:**
- `Space` + `ff` - Find files
- `Space` + `e` - File explorer
- `jk` - Exit insert mode
- `:q` - Quit

### 4. Tmux (if you want to use it)

```bash
tmux

# Inside tmux, try:
# F12 + c  - New window
# F12 + n  - Next window
# F12 + d  - Detach session
```

## Customize

### Add Personal Aliases

Edit your shell aliases:

```bash
nvim ~/dotfiles/terminal/zsh/aliases/custom.sh    # Or use vim/nano
```

Add your aliases:

```bash
#!/usr/bin/env zsh
# Custom aliases

alias myproject="cd ~/Projects/my-project"
alias gs="git status"
```

Reload your shell:

```bash
reload    # or: source ~/.zshrc
```

### Machine-Specific Settings

For machine-specific customizations (work vs personal):

```bash
# Copy the example file
cp ~/dotfiles/terminal/zsh/zshrc.local.example ~/.zshrc.local

# Edit with your machine-specific settings
nvim ~/.zshrc.local
```

This file is `.gitignore`d so your personal settings stay private.

## Common First Steps

### 1. Install Additional Software

This dotfiles includes a profile-based package system:

```bash
cd ~/dotfiles/packages

# See available profiles
cat profiles/minimal.txt      # Essential tools only
cat profiles/dev.txt           # Development tools
cat profiles/full.txt          # Everything

# Install a profile
./install-profile.sh dev      # Installs development tools
```

### 2. Configure Git Identity

Set your Git name and email:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

Or for machine-specific Git config:

```bash
cp ~/dotfiles/git/gitconfig.local.example ~/.gitconfig.local
nvim ~/.gitconfig.local
```

### 3. Set Up Window Management (macOS)

If you want tiling window management:

```bash
# Install Yabai and SKHD (included in full profile)
brew install koekeishiya/formulae/yabai
brew install koekeishiya/formulae/skhd

# Start services
yabai --start-service
skhd --start-service
```

See [Yabai README](../config/yabai/README.md) for keybindings.

### 4. Configure Email (Optional)

If you want offline email with Neomutt:

1. Read the [Mail Setup Guide](../mail/GMAIL-SYNC-SETUP.md)
2. Configure mbsync for Gmail
3. Run the first sync
4. Launch neomutt: `neomutt`

## Next Steps

Now that you're set up, explore the full documentation:

### Learn the System
- [Architecture](ARCHITECTURE.md) - Understand how everything fits together
- [Configuration Index](../CONFIGURATION-INDEX.md) - Browse all 50+ configurations

### Deep Dive into Components
- [Shell Documentation](../terminal/zsh/README.md) - Learn all aliases and functions
- [Neovim Guide](../editors/neovim/README.md) - Master your editor
- [Tmux Setup](../terminal/README.md) - Terminal multiplexer power user

### Customization
- [Machine-Specific Overrides](MACHINE-SPECIFIC-OVERRIDES.md) - Customize per machine
- [Package Management](../packages/README.md) - Install additional software

### Troubleshooting
- [Troubleshooting Guide](TROUBLESHOOTING.md) - Fix common issues
- Health Check: Run `./scripts/health-check.sh` anytime

## Getting Help

**Something not working?**

1. **Check the health:** `./scripts/health-check.sh`
2. **Review logs:** Installation creates `~/.dotfiles-install.log`
3. **Read troubleshooting:** [Troubleshooting Guide](TROUBLESHOOTING.md)
4. **Restore backup:** `./scripts/restore.sh --latest` (if needed)
5. **Open an issue:** [GitHub Issues](https://github.com/jeromefaria/dotfiles/issues)

## Summary

You now have:

✅ **Modern shell** with ZSH, Oh My Zsh, and smart navigation (zoxide)
✅ **Enhanced CLI** with bat, eza, fd, ripgrep, and fzf
✅ **Git configuration** with helpful aliases
✅ **Neovim/Vim** with LSP support (if installed)
✅ **Tmux** for terminal multiplexing (if you want it)
✅ **Comprehensive documentation** for everything

**Enjoy your new development environment!** 🎉

---

**Status:** ✅ Complete
**Last Updated:** 2025-12-20
