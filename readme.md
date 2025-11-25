# Dotfiles

Personal dotfiles for macOS development environment.

**Last updated:** Mon Nov 25 2025

## 📋 Contents

- **Shell Configuration**: ZSH with Oh My Zsh, custom aliases, and functions
- **Editor Setup**: Neovim/Vim with LSP support
- **Terminal Multiplexer**: Tmux with custom keybindings
- **Package Management**: Homebrew Brewfile for reproducible installs
- **macOS Settings**: Automated system preferences configuration
- **Git Configuration**: Custom aliases and settings
- **Additional Tools**: Starship prompt, FZF, and more

## 🚀 Quick Start

### Prerequisites

- macOS (tested on recent versions)
- [Homebrew](https://brew.sh/)
- Xcode Command Line Tools: `xcode-select --install`

### Installation

```bash
# Clone the repository
git clone https://github.com/jeromefaria/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Run the installation script
./install.sh
```

The installation script will:
- Check for Homebrew and install if needed
- Install Oh My Zsh and plugins
- Install Vim-plug (for Vim only, Neovim uses lazy.nvim)
- Install Tmux Plugin Manager (TPM)
- Create symlinks for all configuration files
- Optionally install packages from Brewfile
- Optionally apply macOS system settings
- Set ZSH as default shell

### Uninstallation

To remove all dotfile symlinks (your dotfiles repository remains unchanged):

```bash
./uninstall.sh
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

## 🛠 Configuration Files

### Repository Structure

- **Root Level** - Shell configurations and main dotfiles (zshrc, vimrc, tmux.conf, gitconfig)
- **`config/`** - XDG-compliant application configurations (see `config/README.md`)
- **`vim/`** - Vim-specific configuration (separate from Neovim)
- **`neovim/`** - Neovim configuration with lazy.nvim
- **`packages/`** - Package management files (see `packages/README.md`)
- **`docs/`** - Documentation and analysis files

### Shell (ZSH)

- **`zshrc`** - Main ZSH configuration
  - Oh My Zsh integration
  - Custom plugins (syntax highlighting, autosuggestions, vi-mode)
  - FNM (Fast Node Manager) for Node.js version management
  - Starship prompt
  - Custom key bindings

- **`aliases.sh`** - Shell aliases
  - Navigation shortcuts
  - Modern tool replacements (eza, bat, fd, ripgrep)
  - Git aliases
  - macOS-specific utilities

- **`functions.sh`** - Custom shell functions
  - HTTP server utilities
  - File operations
  - Development helpers

### Editor (Vim/Neovim)

**Note:** Vim and Neovim configurations are kept separate to support systems without Neovim.

- **Vim Configuration** (for systems without Neovim)
  - **`vimrc`** - Main Vim configuration entry point
  - **`vim/plugins.vim`** - Plugin definitions using vim-plug
  - **`vim/`** - Modular configuration files

- **Neovim Configuration** (modern setup)
  - **`neovim/init.lua`** - Neovim entry point
  - **`neovim/lua/`** - Lua-based configuration
  - **`config/nvim/`** - XDG location (symlinks to neovim/)
  - Uses **lazy.nvim** for plugin management (auto-installs on first launch)
  - LSP support with native Neovim LSP client
  - Modern plugin ecosystem

### Terminal Multiplexer

- **`tmux.conf`** - Tmux configuration
  - Custom prefix key (F12)
  - Vi-mode keybindings
  - Plugin management with TPM
  - Vim/Tmux navigator integration

### Git

- **`gitconfig`** - Git configuration
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

Edit `aliases.sh` and add your aliases:

```bash
alias myalias="command"
```

### Adding Custom Functions

Edit `functions.sh` and add your functions:

```bash
function myfunction() {
  # Your code here
}
```

### Installing Additional Plugins

**For Vim:**
Edit `vim/plugins.vim` and add plugins using vim-plug syntax:

```vim
Plug 'author/plugin-name'
```

Then run `:PlugInstall` in Vim.

**For Neovim:**
Add plugins to the appropriate file in `neovim/lua/plugins/`. Lazy.nvim will automatically install them on next launch.

## 🔍 Key Features

### Shell Enhancements
- **Vi-mode** with `jj` and `jk` as escape sequences
- **FZF integration** for fuzzy finding files and history
- **Syntax highlighting** and autosuggestions
- **FASD** for frecent directory navigation
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
./osx
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
