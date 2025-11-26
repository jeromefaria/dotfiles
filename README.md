# Dotfiles

Personal dotfiles for macOS development environment.

**Last updated:** Tue Nov 26 2024

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

Comprehensive documentation available for all major configurations:

### Complete Guides (with keybindings, parameters, and examples)

| Tool | Documentation | Lines | Coverage |
|------|---------------|-------|----------|
| **Shell (ZSH)** | [shell/README.md](shell/README.md) | 200+ | ⭐⭐⭐⭐⭐ |
| **Neovim** | [editors/neovim/README.md](editors/neovim/README.md) | 600+ | ⭐⭐⭐⭐⭐ |
| **Git** | [git/README.md](git/README.md) | 400+ | ⭐⭐⭐⭐⭐ |
| **Tmux & Tmuxinator** | [terminal/README.md](terminal/README.md) | 700+ | ⭐⭐⭐⭐⭐ |
| **Neomutt (Email)** | [mail/mutt/README.md](mail/mutt/README.md) | 140+ | ⭐⭐⭐⭐⭐ |
| **Beets (Music)** | [config/beets/README.md](config/beets/README.md) | 880+ | ⭐⭐⭐⭐⭐ |
| **Yazi (File Manager)** | [config/yazi/README.md](config/yazi/README.md) | 770+ | ⭐⭐⭐⭐⭐ |
| **SKHD (Hotkeys)** | [config/skhd/README.md](config/skhd/README.md) | 244+ | ⭐⭐⭐⭐⭐ |
| **Yabai (Window Manager)** | [config/yabai/README.md](config/yabai/README.md) | 418+ | ⭐⭐⭐⭐⭐ |

### Reference Documentation

| Document | Purpose |
|----------|---------|
| [CONFIGURATION-INDEX.md](CONFIGURATION-INDEX.md) | Master catalog of all 50+ configurations |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | System design and component integration |
| [docs/INSTALLATION-IMPROVEMENTS.md](docs/INSTALLATION-IMPROVEMENTS.md) | Installation script analysis and roadmap |
| [docs/MACHINE-SPECIFIC-OVERRIDES.md](docs/MACHINE-SPECIFIC-OVERRIDES.md) | Per-machine customization guide |

**Documentation coverage:** 60% of configurations (30+ of 50+ files)

**Quick starts:**
- **Neovim keybindings**: `<Space>ff` (find files), `gd` (go to definition), `<Space>ca` (code actions)
- **Tmux prefix**: `F12` (mapped to Caps Lock), seamless Vim navigation with `Ctrl+hjkl`
- **Yazi navigation**: Vim-style `hjkl`, `<Space>` to select, `y`/`x`/`p` for copy/cut/paste
- **Git aliases**: `git co` (checkout), `git hist` (pretty log), `git st` (status)

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
