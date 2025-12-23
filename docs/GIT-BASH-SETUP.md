# Git Bash Setup Guide
## Portable Dotfiles for Windows

This guide covers setting up portable dotfiles configuration for Git Bash on Windows, specifically designed for corporate/restricted environments.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [What's Included](#whats-included)
- [Manual Setup](#manual-setup)
- [Troubleshooting](#troubleshooting)
- [Tips & Shortcuts](#tips--shortcuts)

---

## Overview

### What is Portable Mode?

The portable configuration is a streamlined version of the full dotfiles designed for environments where:

- ❌ No package manager access (no admin rights)
- ❌ No external CLI tools (fzf, ripgrep, eza, bat, etc.)
- ❌ Corporate proxy/SSL interception
- ✅ Git Bash is available
- ✅ Node.js/npm may be available (front-end dev)

### What You Get

With the portable configuration, you get a **fully functional development environment** using only standard tools:

- **Bash shell** with git-aware prompt
- **40+ git aliases** for productivity
- **20+ portable functions** (server, extract, find, grep)
- **Platform-aware clipboard** and file operations
- **Vim** with CoC.nvim support (if Node.js available)
- **npm shortcuts** (if Node.js available)

All with **ZERO external dependencies** beyond what's included in Git Bash!

---

## Quick Start

### One-Command Installation

Open Git Bash and run:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/jeromefaria/dotfiles/master/bootstrap/gitbash-setup.sh)
```

Then reload your shell:

```bash
source ~/.bashrc
```

That's it! You now have a fully configured portable environment.

### With Custom Repository URL

If you've forked the dotfiles:

```bash
DOTFILES_REPO=https://github.com/YOUR_USERNAME/dotfiles.git \
  bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/master/bootstrap/gitbash-setup.sh)
```

### With Custom Directory

To install to a different location:

```bash
DOTFILES_DIR=~/code/dotfiles \
  bash <(curl -fsSL https://raw.githubusercontent.com/jeromefaria/dotfiles/master/bootstrap/gitbash-setup.sh)
```

---

## What's Included

### Shell Configuration (bashrc.portable)

**732 lines** of well-tested, portable bash configuration.

#### Git Integration
- **Git-aware prompt** - Shows current branch: `user@host:~/project (master)$`
- **40+ git aliases** - Shorthand for common operations
  ```bash
  ga      # git add
  gc      # git commit
  gco     # git checkout
  gd      # git diff
  gp      # git push
  gs      # git status
  gss     # git status -s (short)
  gl      # git log --oneline
  # ... and 30+ more
  ```

#### Platform Features
- **Cross-platform clipboard**
  - Windows: `clip` / PowerShell clipboard
  - macOS: `pbcopy` / `pbpaste`
  - Linux: `xclip` / `xsel`
- **Smart file opening**
  - Windows: `start` / `open` command
  - macOS: `open`
  - Linux: `xdg-open`

#### Navigation
```bash
..      # cd ..
...     # cd ../..
....    # cd ../../..
-       # cd to previous directory
```

#### Portable Functions

**Development:**
- `server [port]` - Start HTTP server (Python) with auto-open browser
- `ggd` - Get date of latest git commit
- `gdb` - Delete stale git branches (those removed from remote)

**File Operations:**
- `mkd <dir>` - Create directory and cd into it
- `extract <file>` - Smart extraction (supports tar, zip, 7z, rar, gz, bz2, etc.)
- `fs [path]` - Show directory/file sizes
- `qf <pattern>` - Quick find files (no fzf needed)
- `qg <pattern>` - Quick grep content (no ripgrep needed)

**Encoding:**
- `enc <file>` - Base64 encode file
- `dec <output>` - Base64 decode from stdin
- `dataurl <file>` - Create data URL for file
- `json` - Format JSON from stdin

**Utilities:**
- `links <url>` - Extract all links from webpage
- `randNum <min> <max>` - Generate random number
- `weather` - Get weather report (requires curl)

### Node.js Features (if available)

When Node.js/npm is detected, you get **30+ additional shortcuts**:

#### npm Shortcuts
```bash
ni          # npm install
nid         # npm install --save-dev
nig         # npm install -g
nr          # npm run
nrs         # npm run start
nrd         # npm run dev
nrb         # npm run build
nrt         # npm run test
nrl         # npm run lint
```

#### Package Utilities
```bash
nscripts    # List available npm scripts
nsetup      # Smart install (npm ci or npm install)
nclean      # Remove node_modules and reinstall
ncheck      # Check for outdated packages
ninit       # Initialize new npm project
npkg        # Show package.json info
nbump       # Bump version (major|minor|patch)
```

### Vim Configuration (vimrc.portable)

**832 lines** of feature-rich vim configuration.

**Key Features:**
- **65 plugins** (pure Vimscript, no compilation needed)
- **NERDTree** for file exploration (no fzf needed)
- **CoC.nvim** for LSP/autocomplete (if Node.js available)
- **vim-fugitive** for git integration
- **Auto-pairs**, **vim-surround**, **vim-commentary** for editing
- **Language support** for JavaScript, TypeScript, React, Vue, CSS, HTML, JSON, Markdown

**No External Dependencies:**
- No fzf required (uses NERDTree + vim's built-in `:find`)
- No ripgrep needed (uses `:vimgrep`)
- No powerline fonts (simple ASCII status line)

### Git Configuration

**gitconfig.portable** removes external tool dependencies:

- ✅ All git aliases preserved (co, ci, st, br, hist)
- ✅ Standard less pager (no diff-so-fancy)
- ✅ No git-lfs filter (can add in ~/.gitconfig.local if needed)
- ✅ No gh credential helper (use standard git credentials)

---

## Manual Setup

If you prefer manual installation or want to understand what the script does:

### 1. Clone the Repository

```bash
git clone https://github.com/jeromefaria/dotfiles.git ~/dotfiles
```

### 2. Backup Existing Configs

```bash
mkdir -p ~/dotfiles_backup
cp ~/.bashrc ~/dotfiles_backup/ 2>/dev/null
cp ~/.vimrc ~/dotfiles_backup/ 2>/dev/null
cp ~/.gitconfig ~/dotfiles_backup/ 2>/dev/null
```

### 3. Create Symlinks

```bash
# Bash (required)
ln -sf ~/dotfiles/terminal/bash/bashrc.portable ~/.bashrc

# Vim (optional, if vim is installed)
ln -sf ~/dotfiles/editors/vim/vimrc.portable ~/.vimrc

# Git (choose portable or full version)
ln -sf ~/dotfiles/git/gitconfig.portable ~/.gitconfig
# OR for full version (if external tools available):
# ln -sf ~/dotfiles/git/gitconfig ~/.gitconfig
```

### 4. Install vim-plug (optional)

If you use vim:

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

Then in vim:
```vim
:PlugInstall
```

### 5. Reload Shell

```bash
source ~/.bashrc
```

---

## Troubleshooting

### Corporate SSL/Proxy Issues

If you see certificate errors with npm or git:

```bash
# For npm (disables SSL verification)
npm config set strict-ssl false

# For git (use with caution in secure environments)
git config --global http.sslVerify false
```

### vim-plug Installation Fails

If curl fails to download vim-plug:

**Option 1:** Download manually
```bash
mkdir -p ~/.vim/autoload
# Download on a machine with internet access and copy the file
```

**Option 2:** Use vim without plugins
The portable vimrc will still work without plugins, just with reduced functionality.

### Node.js/npm Not Detected

Check Node.js installation:
```bash
node --version
npm --version
```

If not installed, you can:
1. Request IT to install Node.js
2. Use portable Node.js (no admin required): https://nodejs.org/en/download/
3. Continue without Node.js (bash features still work)

### Git Credential Issues

Without `gh` CLI, use standard git credentials:

```bash
# Cache credentials for 1 hour
git config --global credential.helper 'cache --timeout=3600'

# Or use Windows Credential Manager (Git Bash default)
git config --global credential.helper manager
```

### Slow Git Performance

If git operations are slow on corporate networks:

```bash
# Disable automatic garbage collection
git config --global gc.auto 0

# Increase http buffer
git config --global http.postBuffer 524288000
```

### Colors Not Working

Enable colors in Git Bash:

1. Right-click Git Bash title bar → Options
2. Enable "ANSI colors"
3. Restart Git Bash

---

## Tips & Shortcuts

### Learning the Shortcuts

**List all git aliases:**
```bash
alias | grep git
```

**List all npm aliases (if Node.js available):**
```bash
alias | grep npm
```

**See available npm scripts:**
```bash
nscripts
```

### Customization

**Machine-specific bash overrides:**
```bash
# Create ~/.bashrc.local
echo 'export MY_CUSTOM_VAR="value"' >> ~/.bashrc.local
echo 'alias myalias="command"' >> ~/.bashrc.local
```

**Machine-specific git config:**
```bash
# Create ~/.gitconfig.local
git config --file ~/.gitconfig.local user.email "work@company.com"
git config --file ~/.gitconfig.local user.name "Your Name"
```

### Productivity Boosters

**Quick project setup:**
```bash
mkd ~/projects/new-project  # Create and cd
nsetup                       # Install npm dependencies
server                       # Start dev server
```

**Git workflow:**
```bash
gss           # Quick status check
ga .          # Stage all changes
gcm "message" # Commit with message
gp            # Push
```

**Archive operations:**
```bash
extract project.zip          # Smart extraction
tar czf backup.tar.gz dir/   # Create archive
```

**File search:**
```bash
qf "*.js"           # Find all JavaScript files
qg "TODO" src/      # Search for TODO in src/
```

### Advanced Usage

**JSON manipulation:**
```bash
# Format JSON from API
curl https://api.example.com/data | json

# Format JSON file
cat package.json | json
```

**Development server:**
```bash
# Start on custom port
server 3000

# Serves current directory on http://localhost:3000
# Automatically opens in browser
```

**Git branch cleanup:**
```bash
# Remove all branches that were deleted from remote
gdb

# Interactive branch selection
gb  # List all branches
```

---

## Next Steps

1. **Explore the functions** - Try `server`, `extract`, `nscripts`
2. **Learn the aliases** - Run `alias | grep git` to see shortcuts
3. **Customize** - Add your preferences to `~/.bashrc.local`
4. **Read the code** - Check `~/dotfiles/terminal/bash/bashrc.portable` for all features
5. **Install Node.js** - Unlock npm shortcuts and CoC.nvim features

## Resources

- **Main Documentation:** `~/dotfiles/README.md`
- **Bash Portable:** `~/dotfiles/terminal/bash/bashrc.portable`
- **Vim Portable:** `~/dotfiles/editors/vim/vimrc.portable`
- **Vim Guide:** `~/dotfiles/editors/vim/README.md`

## Getting Help

- **Issues:** https://github.com/jeromefaria/dotfiles/issues
- **Discussions:** https://github.com/jeromefaria/dotfiles/discussions

---

**Enjoy your productive portable environment!** 🚀
