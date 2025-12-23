# Portable Shell Configuration

A bash configuration designed for restricted environments like Git Bash on Windows, where you cannot install tools via package managers but Node.js is typically available.

## Overview

The `bashrc.portable` configuration provides:
- Cross-platform compatibility (Windows Git Bash, Linux, macOS)
- No external tool dependencies (no fzf, ripgrep, eza, etc.)
- Full Node.js/npm integration when available
- Familiar keybindings and aliases from the main zsh config

## Installation

### Quick Setup (Git Bash on Windows)

```bash
# Clone your dotfiles (if not already done)
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles

# Source the portable config from your .bashrc
echo '[ -f ~/dotfiles/shell/bashrc.portable ] && source ~/dotfiles/shell/bashrc.portable' >> ~/.bashrc

# Reload
source ~/.bashrc
```

### Alternative: Direct Symlink

```bash
# Backup existing .bashrc
mv ~/.bashrc ~/.bashrc.backup

# Symlink portable config
ln -s ~/dotfiles/shell/bashrc.portable ~/.bashrc
```

## Features

### Platform Detection

The config automatically detects your platform and adjusts commands accordingly:

| Platform | Detection | Clipboard | Open Command |
|----------|-----------|-----------|--------------|
| Windows (Git Bash) | `MINGW*`, `MSYS*`, `CYGWIN*` | `clip` | `start` |
| macOS | `Darwin` | `pbcopy` | `open` |
| Linux | `Linux` | `xclip`/`xsel` | `xdg-open` |

### Node.js Detection

When Node.js and npm are available, additional features are enabled:
- npm aliases and shortcuts
- Package.json helper functions
- JSON formatting via Node.js

Check your environment on startup:
```
Portable shell loaded | Platform: windows | Node.js: yes (v18.17.0)
```

---

## Aliases Reference

### Navigation

| Alias | Command | Description |
|-------|---------|-------------|
| `..` | `cd ..` | Go up one directory |
| `...` | `cd ../..` | Go up two directories |
| `....` | `cd ../../..` | Go up three directories |
| `-` | `cd -` | Go to previous directory |

### System Operations

| Alias | Command | Description |
|-------|---------|-------------|
| `cl` | `clear` | Clear terminal |
| `reload` | `exec ${SHELL} -l` | Reload shell configuration |
| `path` | `echo ${PATH//:/\\n}` | Print PATH entries on separate lines |

### File Listing

| Alias | Command | Description |
|-------|---------|-------------|
| `ls` | `ls --color=auto` | List with colors |
| `ll` | `ls -lh` | Long listing |
| `la` | `ls -lah` | Long listing including hidden |
| `l` | `ls` | Short listing |

### Clipboard (Platform-Specific)

| Alias | Windows | macOS | Linux |
|-------|---------|-------|-------|
| `pbc` | `clip` | `pbcopy` | `xclip -selection clipboard` |
| `pbp` | `powershell Get-Clipboard` | `pbpaste` | `xclip -o` |
| `copy` | Pipe to `clip` | Pipe to `pbcopy` | Pipe to `xclip` |
| `cdir` | Copy current dir | Copy current dir | Copy current dir |

### File Operations

| Alias | Windows | macOS/Linux | Description |
|-------|---------|-------------|-------------|
| `o` | `start` | `open`/`xdg-open` | Open file with default app |
| `open` | `start` | `open`/`xdg-open` | Open file with default app |

### Grep

| Alias | Command | Description |
|-------|---------|-------------|
| `grep` | `grep --color=auto` | Grep with colors |
| `fgrep` | `fgrep --color=auto` | Fixed-string grep |
| `egrep` | `egrep --color=auto` | Extended regex grep |

### Git

| Alias | Command | Description |
|-------|---------|-------------|
| `g` | `git` | Git shortcut |
| `ga` | `git add` | Stage files |
| `gaa` | `git add --all` | Stage all files |
| `gb` | `git branch` | List branches |
| `gc` | `git commit` | Commit |
| `gcm` | `git commit -m` | Commit with message |
| `gcan` | `git commit --amend --no-edit` | Amend without editing |
| `gco` | `git checkout` | Checkout |
| `gd` | `git diff` | Show diff |
| `gds` | `git diff --staged` | Show staged diff |
| `gdc` | `git diff --name-only --diff-filter=U` | Show conflicted files |
| `gf` | `git fetch` | Fetch |
| `gl` | `git log --oneline` | Compact log |
| `glo` | `git log --oneline --decorate --graph` | Graph log |
| `gp` | `git push` | Push |
| `gpl` | `git pull` | Pull |
| `gs` | `git status` | Status |
| `gss` | `git status -s` | Short status |
| `gst` | `git stash` | Stash changes |
| `gstl` | `git stash list` | List stashes |
| `gstp` | `git stash pop` | Pop stash |
| `gstdf` | `git stash show -p` | Show stash diff |

### Node.js / npm (When Available)

| Alias | Command | Description |
|-------|---------|-------------|
| `ni` | `npm install` | Install dependencies |
| `nid` | `npm install --save-dev` | Install dev dependency |
| `nig` | `npm install -g` | Install globally |
| `nu` | `npm uninstall` | Uninstall package |
| `nug` | `npm uninstall -g` | Uninstall global package |
| `nup` | `npm update` | Update packages |
| `nls` | `npm list --depth=0` | List installed packages |
| `nlsg` | `npm list -g --depth=0` | List global packages |
| `nout` | `npm outdated` | Check for outdated packages |
| `nr` | `npm run` | Run script |
| `nrs` | `npm run start` | Run start script |
| `nrd` | `npm run dev` | Run dev script |
| `nrb` | `npm run build` | Run build script |
| `nrt` | `npm run test` | Run test script |
| `nrl` | `npm run lint` | Run lint script |
| `nrf` | `npm run format` | Run format script |

### Docker (When Available)

| Alias | Command | Description |
|-------|---------|-------------|
| `dcu` | `docker compose up` | Start containers |
| `dcud` | `docker compose up -d` | Start containers (detached) |
| `dcd` | `docker compose down` | Stop containers |
| `dcs` | `docker compose stop` | Stop without removing |
| `dcb` | `docker compose build` | Build images |

### Tmux (When Available)

| Alias | Command | Description |
|-------|---------|-------------|
| `tmx` | `tmux new -s` | New session with name |
| `tmxa` | `tmux attach` | Attach to session |
| `tmxl` | `tmux ls` | List sessions |

### Encoding

| Alias | Command | Description |
|-------|---------|-------------|
| `rot13` | `tr 'A-Za-z' 'N-ZA-Mn-za-m'` | ROT13 encoding |
| `rot5` | `tr '0-9' '5-90-4'` | ROT5 for numbers |
| `rotten` | Combined ROT13+ROT5 | Full rotation |
| `json` | Format JSON | Uses Node.js or Python |

### Date/Time

| Alias | Command | Description |
|-------|---------|-------------|
| `week` | `date +%V` | Current week number |
| `now` | `date +"%Y-%m-%d %H:%M:%S"` | Current datetime |
| `today` | `date +"%Y-%m-%d"` | Current date |

### Archives

| Alias | Command | Description |
|-------|---------|-------------|
| `zi` | `zipinfo` | Zip file info |
| `uz` | `unzip -o` | Unzip overwriting |

### Misc

| Alias | Command | Description |
|-------|---------|-------------|
| `weather` | `curl wttr.in` | Weather forecast |

---

## Functions Reference

### File Operations

#### `mkd <directory>`
Create a directory and cd into it.
```bash
mkd my-new-project
# Creates my-new-project/ and enters it
```

#### `fs [path]`
Show file or directory size.
```bash
fs                    # Size of current directory contents
fs myfile.txt         # Size of specific file
fs src/               # Size of directory
```

#### `enc <file>`
Base64 encode a file (outputs to stdout).
```bash
enc image.png         # Outputs base64 string
enc image.png | pbc   # Copy to clipboard
```

#### `dec <output_file>`
Base64 decode from stdin to file.
```bash
echo "SGVsbG8=" | dec output.txt
pbp | dec decoded.bin  # Decode from clipboard
```

#### `dataurl <file>`
Create a data URL from a file.
```bash
dataurl icon.png
# Output: data:image/png;base64,iVBORw0KGgo...
```

#### `rl <file> <line_number>`
Read a specific line from a file.
```bash
rl package.json 5     # Show line 5
```

#### `extract <archive>`
Extract various archive formats.
```bash
extract file.tar.gz
extract file.zip
extract file.7z       # Requires 7z
extract file.rar      # Requires unrar
```

### Search

#### `qf <pattern>`
Quick find files by name (uses basic `find`).
```bash
qf component          # Find files containing "component"
qf "*.tsx"            # Find TypeScript React files
```

#### `qg <pattern> [path]`
Quick grep for content (uses basic `grep`).
```bash
qg "TODO"             # Search current directory
qg "import" src/      # Search in src/
```

### Web

#### `links <url>`
Extract all href links from a webpage.
```bash
links https://example.com
```

#### `server [port]`
Start an HTTP server (default port: 8000).
```bash
server                # Start on port 8000
server 3000           # Start on port 3000
```

### Git Functions

#### `ggd`
Get the date of the latest commit.
```bash
ggd
# Output: Wed Nov 27 14:30:00 2024
```

#### `gdb`
Remove local branches that have been deleted from remote.
```bash
gdb
# Removing stale branches:
#   - feature/old-branch
#   - fix/completed-fix
```

### Utilities

#### `randNum <min> <max>`
Generate a random number in range.
```bash
randNum 1 100         # Random number between 1 and 100
```

---

## npm Functions (When Node.js Available)

#### `nscripts`
List all available npm scripts from package.json.
```bash
nscripts
# Available npm scripts:
#   start: react-scripts start
#   build: react-scripts build
#   test: react-scripts test
```

#### `nrun [script]`
Run an npm script (shows list if no argument).
```bash
nrun                  # Shows available scripts
nrun dev              # Runs npm run dev
```

#### `nsetup`
Smart dependency installation.
```bash
nsetup
# Uses npm ci if package-lock.json exists
# Falls back to npm install otherwise
```

#### `nclean`
Remove node_modules and reinstall.
```bash
nclean
# Removing node_modules...
# Removing package-lock.json...
# Reinstalling dependencies...
```

#### `ncheck`
Check for outdated packages.
```bash
ncheck
# Shows npm outdated output
```

#### `npkg`
Show package.json summary.
```bash
npkg
# Name: my-project
# Version: 1.0.0
# Description: My awesome project
# Dependencies: 15
# DevDependencies: 8
```

#### `nbump [major|minor|patch]`
Bump package version (default: patch).
```bash
nbump                 # 1.0.0 -> 1.0.1
nbump minor           # 1.0.0 -> 1.1.0
nbump major           # 1.0.0 -> 2.0.0
```

#### `ninit`
Initialize a new npm project.
```bash
ninit
# Creates package.json with npm init -y
```

#### `ndev-setup`
Install common front-end dev dependencies.
```bash
ndev-setup
# Installs: eslint, prettier, eslint-config-prettier, eslint-plugin-prettier
```

---

## Local Customization

Create `~/.bashrc.local` for machine-specific settings:

```bash
# ~/.bashrc.local

# Work-specific aliases
alias vpn="start company-vpn.exe"
alias work="cd /c/Users/me/Work"

# Project shortcuts
alias myproject="cd /c/Projects/my-project && nrd"

# Custom PATH additions
export PATH="$PATH:/c/custom/tools"
```

This file is automatically sourced if it exists.

---

## Comparison with Main Config

| Feature | `zshrc` (Full) | `bashrc.portable` |
|---------|----------------|-------------------|
| Shell | Zsh | Bash |
| Framework | Oh My Zsh | None |
| Plugins | 17+ | None |
| `cd` enhancement | zoxide | None (basic cd) |
| Fuzzy finder | fzf | None |
| Modern CLI tools | eza, bat, fd, etc. | Basic Unix tools |
| Syntax highlighting | Yes | No |
| Autosuggestions | Yes | No |
| Node.js support | Yes | Yes (when available) |
| Git integration | Full | Aliases only |
| Platform | macOS primary | Cross-platform |

---

## Troubleshooting

### Clipboard not working on Windows

Ensure you're using Git Bash (not cmd or PowerShell). The `clip` command should be available.

### Node.js not detected

Check that `node` and `npm` are in your PATH:
```bash
which node
which npm
```

### Functions not loading

Ensure the file is sourced correctly:
```bash
source ~/dotfiles/shell/bashrc.portable
```

### Colors not showing

Git Bash should support colors. If not, check your terminal settings or try:
```bash
export TERM=xterm-256color
```
