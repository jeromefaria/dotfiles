# Dotfiles

Personal dotfiles for macOS development environment.

## Quick Navigation

**New to dotfiles?** → Get started in 5 minutes with the [Quick Start](#-quick-start) below
**Looking for something specific?** → Browse the [Configuration Index](CONFIGURATION-INDEX.md) (Master catalog of 50+ configs)
**Having issues?** → Check [Troubleshooting](docs/TROUBLESHOOTING.md) for common problems and solutions
**Want to understand the system?** → Read the [Architecture Guide](docs/ARCHITECTURE.md) to see how it all works
**Contributing or developing?** → See [Development Documentation](docs/dev/README.md) for roadmap and guidelines

## 📋 Contents

- **Shell Configuration**: ZSH with Oh My Zsh, custom aliases, and functions
- **Editor Setup**: Neovim/Vim with LSP support
- **Terminal Multiplexer**: Tmux with custom keybindings
- **Package Management**: Homebrew Brewfile for reproducible installs
- **macOS Settings**: Automated system preferences configuration
- **Git Configuration**: Custom aliases and settings
- **Additional Tools**: Starship prompt, FZF, and more

## 🚀 Quick Start

### One-Liner Installation (Recommended)

Bootstrap a new macOS system with one command:

```bash
curl -fsSL https://raw.githubusercontent.com/jeromefaria/dotfiles/master/scripts/bootstrap.sh | bash
```

**What it does:**
- Checks system requirements (macOS, git, curl, zsh)
- Clones dotfiles repository to `~/dotfiles`
- Runs installation script automatically
- Handles existing installations gracefully

**Options:**
```bash
# Custom installation directory
curl -fsSL https://raw.githubusercontent.com/jeromefaria/dotfiles/master/scripts/bootstrap.sh | bash -s -- --dir ~/my-dotfiles

# Custom repository
curl -fsSL https://raw.githubusercontent.com/jeromefaria/dotfiles/master/scripts/bootstrap.sh | bash -s -- --repo https://github.com/user/dotfiles

# Custom branch
curl -fsSL https://raw.githubusercontent.com/jeromefaria/dotfiles/master/scripts/bootstrap.sh | bash -s -- --branch develop
```

### Manual Installation

If you prefer manual control:

```bash
# Clone the repository
git clone https://github.com/jeromefaria/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run the installation script
./scripts/install.sh
```

### Prerequisites

- macOS (tested on macOS Sonoma and later)
- Xcode Command Line Tools: `xcode-select --install`
- [Homebrew](https://brew.sh/) (installed automatically if missing)

The installation script will:
- Check for Homebrew and install if needed
- Install Oh My Zsh and plugins
- Install Vim-plug (for Vim only, Neovim uses lazy.nvim)
- Install Tmux Plugin Manager (TPM)
- Create symlinks for all configuration files
- Optionally install packages from Brewfile
- Optionally apply macOS system settings
- Set ZSH as default shell

### Backup & Restore

The installation script automatically creates timestamped backups of existing configuration files.

**Restore from backup:**
```bash
# List available backups
./scripts/restore.sh --list

# Restore from latest backup
./scripts/restore.sh --latest

# Preview changes without applying
./scripts/restore.sh --latest --dry-run

# Restore from specific backup
./scripts/restore.sh --backup ~/.dotfiles-backup-TIMESTAMP
```

**Backup location:** `~/.dotfiles-backup-YYYYMMDD-HHMMSS/`

### Health Check

Verify installation integrity:

```bash
./scripts/health-check.sh
```

Checks:
- All symlinks point to correct locations
- Required tools are installed
- Plugin managers are present
- No broken symlinks

### Uninstallation

To remove all dotfile symlinks (your dotfiles repository remains unchanged):

```bash
./scripts/uninstall.sh
```

## 📦 Package Management

### Install All Packages

```bash
# Install from Brewfile
cd ~/dotfiles/packages
brew bundle install

# Or use specific package types
brew bundle install --file=Brewfile
```

### Export Current Packages

```bash
cd ~/dotfiles/packages
./get-packages.sh
```

This will export lists of installed packages to:
- `brew.log` - Homebrew formulae
- `cask.log` - Homebrew casks
- `gem.log` - Ruby gems
- `mas.log` - Mac App Store apps
- `npm.log` - NPM global packages
- `pip.log` - Python packages

## 📚 Documentation

Comprehensive documentation organized by category for easy navigation.

### Getting Started
- [Configuration Index](CONFIGURATION-INDEX.md) - Master catalog of all 50+ configurations with status tracking
- [Quick Start Guide](docs/QUICK-START.md) - Get up and running in 5 minutes
- [Architecture](docs/ARCHITECTURE.md) - System design and how components integrate
- [Machine-Specific Setup](docs/MACHINE-SPECIFIC-OVERRIDES.md) - Customize per-machine (work vs personal)
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions

### Configuration Guides

**Shell & Terminal**
- [Shell (ZSH)](shell/README.md) - Modular aliases and functions | [Quick Reference](shell/QUICK_REFERENCE.md)
- [Tmux](terminal/README.md) - Terminal multiplexer with custom keybindings (700+ lines)
- [Starship](config/starship/README.md) - Fast, customizable shell prompt

**Editors**
- [Neovim](editors/neovim/README.md) - Modern editor with LSP support (600+ lines)
- [Vim](editors/vim/README.md) - Fallback configuration for systems without Neovim

**Development Tools**
- [Git](git/README.md) - Version control configuration and aliases (400+ lines)
- [Packages](packages/README.md) - Profile-based package management system

**Email & Communication**
- [Mail (Neomutt)](mail/README.md) - Offline email with mbsync + notmuch + neomutt
  - [Features Guide](mail/FEATURES.md) - Complete feature documentation
  - [Quick Reference](mail/QUICK-REFERENCE.md) - Keybinding cheat sheet
  - [Gmail Setup](mail/GMAIL-SYNC-SETUP.md) - Gmail-specific configuration
  - [Auto-Sync Setup](mail/AUTO-SYNC-SETUP.md) - Background sync with launchd

**Window Management**
- [Yabai](config/yabai/README.md) - Tiling window manager for macOS (418+ lines)
- [SKHD](config/skhd/README.md) - Hotkey daemon with window management shortcuts (244+ lines)
- [Karabiner](config/karabiner/README.md) - Advanced keyboard remapping (650+ lines)

**File & Media Management**
- [Yazi](config/yazi/README.md) - Modern file manager with rich previews (770+ lines)
- [Vifm](config/vifm/README.md) - Vim-like dual-pane file manager
- [Beets](config/beets/README.md) - Music library management and organization (880+ lines)
- [Musikcube](config/musikcube/README.md) - Terminal-based music player
- [Aria2](config/aria2/README.md) - Download manager with torrent support

### Advanced Topics
- [Migration Guide](docs/MIGRATION-GUIDE.md) - Version upgrades and breaking changes
- [Development](docs/dev/README.md) - Contributing, roadmap, and development workflows

### Documentation Status

📊 **Coverage:** 100% of major configurations documented
📚 **Total Documentation:** 45+ comprehensive guides, 15,000+ lines
✅ **All Major Components:** Complete READMEs with examples, keybindings, and troubleshooting

**Recent Additions (December 2024):**
- Quick Start Guide for new users
- Comprehensive Troubleshooting organized by symptom
- Migration Guide for version upgrades
- Developer Documentation (ROADMAP, CONTRIBUTING)
- Component docs: Musikcube, Vifm, Starship, Aria2, enhanced Vim

See [Configuration Index](CONFIGURATION-INDEX.md) for the complete catalog with detailed status indicators.

## 🛠 Configuration Files

### Repository Structure

- **`shell/`** - ZSH configuration (zshrc, aliases.sh, functions.sh)
- **`editors/`** - Editor configurations
  - **`vim/`** - Vim configuration (separate from Neovim)
  - **`neovim/`** - Neovim configuration with lazy.nvim
- **`terminal/`** - Terminal multiplexer configuration (tmux.conf, tmuxinator/)
- **`git/`** - Git configuration (gitconfig)
- **`config/`** - XDG-compliant application configurations (see `config/README.md`)
- **`packages/`** - Package management files (see `packages/README.md`)
- **`scripts/`** - Installation and setup scripts (install.sh, uninstall.sh, macos-setup.sh)
- **`docs/`** - Documentation and analysis files

### Shell (ZSH)

- **`shell/zshrc`** - Main ZSH configuration
  - Oh My Zsh integration
  - Custom plugins (syntax highlighting, autosuggestions, vi-mode)
  - FNM (Fast Node Manager) for Node.js version management
  - Starship prompt
  - Custom key bindings

- **`shell/aliases.sh`** - Shell aliases
  - Navigation shortcuts
  - Modern tool replacements (eza, bat, fd, ripgrep)
  - Git aliases
  - macOS-specific utilities

- **`shell/functions.sh`** - Custom shell functions
  - HTTP server utilities
  - File operations
  - Development helpers

### Editor (Vim/Neovim)

**Note:** Vim and Neovim configurations are kept separate to support systems without Neovim.

- **Vim Configuration** (for systems without Neovim)
  - **`editors/vim/vimrc`** - Main Vim configuration entry point
  - **`editors/vim/plugins.vim`** - Plugin definitions using vim-plug
  - **`editors/vim/`** - Modular configuration files

- **Neovim Configuration** (modern setup)
  - **`editors/neovim/init.lua`** - Neovim entry point
  - **`editors/neovim/lua/`** - Lua-based configuration
  - **`config/nvim/`** - XDG location (symlinks to editors/neovim/)
  - Uses **lazy.nvim** for plugin management (auto-installs on first launch)
  - LSP support with native Neovim LSP client
  - Modern plugin ecosystem

### Terminal Multiplexer

- **`terminal/tmux.conf`** - Tmux configuration
  - Custom prefix key (F12)
  - Vi-mode keybindings
  - Plugin management with TPM
  - Vim/Tmux navigator integration
- **`terminal/tmuxinator/`** - Tmuxinator session configurations

### Git

- **`git/gitconfig`** - Git configuration
  - Custom aliases (co, ci, st, br)
  - Pretty log format
  - Git LFS support
  - Pull with rebase by default
  - diff-so-fancy pager

### Prompt

- **`config/starship.toml`** - Starship prompt configuration
  - Minimal configuration
  - Disabled modules for cleaner output

### XDG-Compliant Configurations

The `config/` directory contains application configurations following the XDG Base Directory Specification. Includes configurations for:
- Aria2, Bat, Beets, GitHub CLI, Mutt, Musikcube, ncmpcpp, Neofetch, Ranger, SKHD, Tmuxinator, Yabai, Yarn, and more

See `config/README.md` for detailed information about each configuration.

## 🔧 Tools & Dependencies

### Package Managers
- **Homebrew** - macOS package manager
- **FNM** - Fast Node Manager (preferred over NVM)
- **rbenv** - Ruby version management

### Modern CLI Tools
- **bat** - cat replacement with syntax highlighting
- **eza** - ls replacement with better defaults
- **fd** - find replacement
- **ripgrep** - grep replacement
- **fzf** - Fuzzy finder
- **starship** - Fast shell prompt
- **thefuck** - Command correction tool

### Development Tools
- **Neovim** - Modern Vim fork
- **Tmux** - Terminal multiplexer
- **gh** - GitHub CLI (replaces deprecated hub)
- **git-delta** - Better git diffs
- **yt-dlp** - Media downloader (replaces youtube-dl)

## 🎨 Customization

### Adding Custom Aliases

Edit `shell/aliases.sh` and add your aliases:

```bash
alias myalias="command"
```

### Adding Custom Functions

Edit `shell/functions.sh` and add your functions:

```bash
function myfunction() {
  # Your code here
}
```

### Installing Additional Plugins

**For Vim:**
Edit `editors/vim/plugins.vim` and add plugins using vim-plug syntax:

```vim
Plug 'author/plugin-name'
```

Then run `:PlugInstall` in Vim.

**For Neovim:**
Add plugins to the appropriate file in `editors/neovim/lua/plugins/`. Lazy.nvim will automatically install them on next launch.

## 🔍 Key Features

### Shell Enhancements
- **Vi-mode** with `jj` and `jk` as escape sequences
- **FZF integration** for fuzzy finding files and history
- **Syntax highlighting** and autosuggestions
- **Git completion** and shortcuts

### macOS Optimizations
- Automated system preferences configuration
- Finder tweaks and optimizations
- Dock and Mission Control settings
- Safari and Mail.app customizations
- Security and privacy enhancements

### Development Workflow
- LSP support for multiple languages
- Git workflow optimizations
- Project-specific tmuxinator configurations
- Quick server utilities
- Format and linting tools

## 📝 macOS System Preferences

Run the macOS configuration script to apply system preferences:

```bash
./scripts/macos-setup.sh
```

**Warning:** Review the script before running. Some settings may require a logout/restart.

## 🤝 Contributing

This is a personal dotfiles repository, but feel free to:
- Fork it and adapt it to your needs
- Open issues for questions or suggestions
- Submit PRs if you find bugs

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details.

Feel free to use, modify, and distribute as needed.

## 🙏 Acknowledgments

Inspired by various dotfiles repositories in the community, including:
- [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles)
- Various contributors to the dotfiles community

## 🔗 Useful Links

- [Homebrew](https://brew.sh/)
- [Oh My Zsh](https://ohmyz.sh/)
- [Neovim](https://neovim.io/)
- [Tmux](https://github.com/tmux/tmux)
- [Starship](https://starship.rs/)
- [FNM](https://github.com/Schniz/fnm)
