# Terminal Configuration

Complete terminal environment configuration including shell, multiplexer, and terminal emulator settings.

## Structure

```
terminal/
├── zsh/        # Zsh shell configuration
│   ├── zshrc                      # Main Zsh config
│   ├── aliases/                   # Modular aliases (7 categories)
│   ├── functions/                 # Modular functions (9 categories)
│   └── *.md                       # Documentation
├── bash/       # Bash portable configuration
│   ├── bashrc.portable            # Git Bash/restricted environments
│   └── PORTABLE.md                # Documentation
├── tmux/       # Tmux multiplexer configuration
│   ├── tmux.conf                  # Main Tmux config
│   ├── tmuxinator/                # Session templates
│   └── README.md                  # Comprehensive guide (1,138 lines)
└── mintty/     # Mintty terminal emulator (Windows)
    └── minttyrc                   # Terminal colors and settings
```

## Quick Links

- **[Zsh Configuration](zsh/README.md)** - Modern shell with plugins and vim mode
- **[Bash Portable](bash/PORTABLE.md)** - Lightweight for Git Bash/restricted environments
- **[Tmux](tmux/README.md)** - Terminal multiplexer (comprehensive 1,138-line guide)
- **Mintty** - Windows terminal emulator with OceanicNext theme

## Configuration Files

| Tool | Config File | Symlink Target | Platform |
|------|-------------|----------------|----------|
| Zsh | `zsh/zshrc` | `~/.zshrc` | macOS, Linux |
| Bash | `bash/bashrc.portable` | `~/.bashrc` | Windows (Git Bash), Linux |
| Tmux | `tmux/tmux.conf` | `~/.tmux.conf` | All |
| Mintty | `mintty/minttyrc` | `~/.minttyrc` | Windows |

## Installation

All symlinks are created automatically by the install script:

```bash
cd ~/dotfiles
./scripts/install.sh
```

### Manual Installation

If you prefer to create symlinks manually:

```bash
# Zsh
ln -sf ~/dotfiles/terminal/zsh/zshrc ~/.zshrc

# Bash (for Git Bash on Windows)
ln -sf ~/dotfiles/terminal/bash/bashrc.portable ~/.bashrc

# Tmux
ln -sf ~/dotfiles/terminal/tmux/tmux.conf ~/.tmux.conf

# Mintty (Windows only)
ln -sf ~/dotfiles/terminal/mintty/minttyrc ~/.minttyrc
```

## Features

### Zsh

- **Oh My Zsh** framework with curated plugins
- **zsh-vi-mode** with `jk` escape binding
- **Modular aliases** - 7 categories (git, dev, tools, folders, macos, chrome, core)
- **Modular functions** - 9 categories including FZF enhancements, clipboard ops, command palette
- **Starship prompt** with git integration
- **Auto-suggestions** and **syntax highlighting**
- **Platform detection** - adapts to macOS, Linux, WSL

### Bash

- **Portable design** - works in Git Bash (Windows), WSL, and restricted environments
- **Vim mode** with `jk` escape binding
- **Cross-platform** - clipboard, file ops, JSON formatting
- **Node.js integration** - npm helpers when available
- **Minimal dependencies** - works with basic Unix tools

### Tmux

- **Custom prefix** - F12 (caps lock via Karabiner)
- **Vim-style navigation** - hjkl keys, copy mode bindings
- **10+ plugins** - resurrect, continuum, fzf, thumbs, extrakto
- **OceanicNext theme** - consistent with vim/zsh
- **Tmuxinator** - project-specific session templates
- **100+ documented keybindings**

### Mintty

- **OceanicNext theme** - matches tmux/vim color scheme
- **UTF-8 support**
- **Copy-on-select**
- **256-color support**

## Usage

### Zsh Quick Start

```bash
# Load configuration
exec zsh

# View available aliases
alias | grep git        # Git aliases
alias | grep docker     # Docker aliases

# Use modular functions
mkd my-project          # Create directory and cd
server 8080             # Start HTTP server
```

### Tmux Quick Start

```bash
# Start new session
tmux

# Use tmuxinator for projects
tmuxinator start blog   # Start predefined session
tmuxinator list         # List available sessions

# Key bindings (prefix = F12)
F12 c       # New window
F12 |       # Split vertical
F12 -       # Split horizontal
F12 hjkl    # Navigate panes
```

### Git Bash (Windows)

```bash
# After installing, restart Git Bash
# Vi mode is active with 'jk' to exit insert mode

# Test features
alias ls    # Should show colored output
mkd test    # Create dir and cd
```

## Customization

### Machine-Specific Overrides

Create `~/.zshrc.local` for machine-specific settings:

```bash
cp ~/dotfiles/terminal/zsh/zshrc.local.example ~/.zshrc.local
# Edit ~/.zshrc.local with your customizations
```

### Adding Custom Aliases/Functions

Edit the modular files:

```bash
# Add to existing category
nvim ~/dotfiles/terminal/zsh/aliases/dev.sh

# Or create new category
nvim ~/dotfiles/terminal/zsh/aliases/custom.sh
```

## Troubleshooting

### Zsh

```bash
# Syntax check
zsh -n ~/dotfiles/terminal/zsh/zshrc

# Test loading
zsh -c "source ~/dotfiles/terminal/zsh/zshrc && echo 'Success'"

# Reload configuration
exec zsh
```

### Tmux

```bash
# Reload configuration
tmux source-file ~/dotfiles/terminal/tmux/tmux.conf

# Verify plugin installation
ls ~/.tmux/plugins/
```

## Documentation

- [Zsh Full Guide](zsh/README.md)
- [Zsh Quick Reference](zsh/QUICK_REFERENCE.md)
- [Vim Enhancements](zsh/VIM_ENHANCEMENTS_README.md)
- [Bash Portable Guide](bash/PORTABLE.md)
- [Tmux Complete Guide](tmux/README.md)
- [Shell Changelog](zsh/CHANGELOG.md)

## See Also

- [Main Dotfiles README](../README.md)
- [Quick Start Guide](../docs/QUICK-START.md)
- [Architecture Overview](../docs/ARCHITECTURE.md)
- [Troubleshooting](../docs/TROUBLESHOOTING.md)
