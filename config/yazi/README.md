# Yazi File Manager Configuration

Modern terminal-based file manager with Vim-style keybindings, file preview, and powerful navigation features.

## Overview

[Yazi](https://github.com/sxyazi/yazi) is a blazingly fast terminal file manager written in Rust that features:
- Vim-style navigation and keybindings
- Async I/O for better performance
- Built-in image preview (sixel, kitty protocol, iTerm2)
- Multi-tab support
- Integration with modern CLI tools (fd, rg, zoxide, fzf)
- Customizable openers for different file types
- Miller column layout (3-pane view)
- Plugin system for extended functionality

**Configuration Files:**
- `yazi.toml` - Main configuration, layout, openers, MIME rules
- `keymap.toml` - All keybindings for different modes
- `theme.toml` - OceanicNext theme with 350+ file type icons

---

## Table of Contents

- [Installation](#installation)
- [Layout & Interface](#layout--interface)
- [Keybindings](#keybindings)
- [File Openers](#file-openers)
- [MIME Type Rules](#mime-type-rules)
- [Theme & Colors](#theme--colors)
- [Common Workflows](#common-workflows)
- [Troubleshooting](#troubleshooting)

---

## Installation

### Prerequisites

```bash
# Install yazi
brew install yazi

# Optional dependencies for better functionality
brew install ffmpeg      # Video thumbnails
brew install unar        # Archive extraction
brew install jq          # JSON preview
brew install poppler     # PDF preview
brew install fd          # Fast file search
brew install ripgrep     # Content search
brew install zoxide      # Smart directory jumping
brew install fzf         # Fuzzy finding
```

### Configuration

Symlinked automatically via dotfiles:

```bash
# Via dotfiles installation
cd ~/dotfiles
./scripts/install.sh

# Manual symlink
ln -s ~/dotfiles/config/yazi ~/.config/yazi
```

---

## Layout & Interface

### Manager Layout

```toml
[mgr]
layout = [ 1, 4, 3 ]    # Column ratios: parent:current:preview (1:4:3)
```

**Three-Column Miller View:**
- **Left column (1):** Parent directory
- **Middle column (4):** Current directory (main focus)
- **Right column (3):** File preview or subdirectory

### Sorting

```toml
sort_by = "natural"         # Natural sorting (file1, file2, file10)
sort_sensitive = false      # Case-insensitive sorting
sort_reverse = false        # Normal order (A-Z)
sort_dir_first = true       # Show directories before files
sort_translit = true        # Transliterate for sorting (é → e)
```

**Available sort methods:**
- `alphabetical` - A-Z by name
- `natural` - Natural sorting (file1, file2, file10) ← **default**
- `modified` - Last modified time
- `created` - Creation time
- `size` - File size

### Display Options

```toml
linemode = "size"       # Show file sizes by default
show_hidden = false     # Hide dotfiles by default
show_symlink = true     # Show symlink targets
scrolloff = 5           # Keep cursor 5 lines from edge
mouse_events = [ "click", "scroll" ]  # Enable mouse support
title_format = "Yazi: {cwd}"          # Window title
```

**Linemodes available** (toggle with `m` prefix):
- `none` - Just filename
- `size` - Show file size (ms)
- `permissions` - Show permissions (mp)
- `mtime` - Show modification time (mm)

---

## Keybindings

### Essential Navigation

| Key | Action | Description |
|-----|--------|-------------|
| `j` / `k` | Move down/up | Navigate files |
| `J` / `K` | Jump 5 lines | Fast navigation |
| `h` / `l` | Parent/Enter | Move between directories |
| `H` / `L` | Back/Forward | Directory history |
| `g g` | Top | Jump to first file |
| `G` | Bottom | Jump to last file |
| `↑` `↓` `←` `→` | Arrow keys | Alternative navigation |

### Quick Navigation (Goto)

| Key | Action | Description |
|-----|--------|-------------|
| `g h` | Home | Go to `~/` |
| `g c` | Config | Go to `~/.config` |
| `g d` | Downloads | Go to `~/Downloads` |
| `g D` | Desktop | Go to `~/Desktop` |
| `g o` | Documents | Go to `~/Documents` |
| `g p` | Pictures | Go to `~/Pictures` |
| `g m` | Music | Go to `~/Music` |
| `g v` | Movies | Go to `~/Movies` |
| `g .` | Dotfiles | Go to `~/dotfiles` |
| `g t` | Temp | Go to `/tmp` |
| `g /` | Root | Go to `/` |
| `g <Space>` | Interactive | Choose directory |

### File Operations

| Key | Action | Description |
|-----|--------|-------------|
| `<Enter>` | Open | Open file with default program |
| `o` | Open | Same as Enter |
| `O` | Open interactive | Choose program to open with |
| `y` | Yank | Copy selected files |
| `x` | Cut | Cut selected files |
| `p` | Paste | Paste copied/cut files |
| `P` | Paste force | Overwrite existing files |
| `d` | Delete | Move to trash |
| `D` | Delete permanently | Permanently delete (no trash) |
| `a` | Create | Create file or directory (end with `/`) |
| `r` | Rename | Rename file or directory |

### Selection

| Key | Action | Description |
|-----|--------|-------------|
| `<Space>` | Toggle | Toggle selection and move down |
| `v` | Visual mode | Start visual selection |
| `V` | Visual unset | Invert visual selection |
| `<C-a>` | Select all | Select all files |
| `<C-r>` | Inverse | Invert current selection |

### Symlinks

| Key | Action | Description |
|-----|--------|-------------|
| `-` | Link absolute | Create absolute symlink |
| `_` | Link relative | Create relative symlink |

### Search & Find

| Key | Action | Description |
|-----|--------|-------------|
| `/` | Find | Find by name (forward) |
| `?` | Find reverse | Find by name (backward) |
| `n` | Next | Jump to next match |
| `N` | Previous | Jump to previous match |
| `s` | Search fd | Search files by name (fd) |
| `S` | Search rg | Search file contents (ripgrep) |
| `<C-s>` | Cancel search | Stop ongoing search |

### Advanced Navigation

| Key | Action | Description |
|-----|--------|-------------|
| `z` | Zoxide | Jump to directory (zoxide history) |
| `Z` | FZF | Fuzzy find directory or file |

### Shell Integration

| Key | Action | Description |
|-----|--------|-------------|
| `!` | Shell | Open shell in current directory |
| `@` | Shell confirm | Open shell (confirm on close) |
| `;` | Command | Run shell command (non-blocking) |
| `:` | Command block | Run shell command (blocking) |

### File Operations (Extended)

| Key | Action | Description |
|-----|--------|-------------|
| `c m` | Chmod | Change file permissions |
| `b r` | Bulk rename | Edit filenames with $EDITOR |

### Copy Operations

| Key | Action | Description |
|-----|--------|-------------|
| `c c` | Copy path | Copy absolute path |
| `c d` | Copy dirname | Copy parent directory path |
| `c f` | Copy filename | Copy filename with extension |
| `c n` | Copy name | Copy filename without extension |

### Sorting

| Key | Action | Description |
|-----|--------|-------------|
| `, a` | Alphabetical | Sort A-Z |
| `, A` | Alphabetical reverse | Sort Z-A |
| `, c` | Created | Sort by creation time |
| `, C` | Created reverse | Newest first |
| `, m` | Modified | Sort by modified time |
| `, M` | Modified reverse | Newest first |
| `, n` | Natural | Natural number sorting |
| `, N` | Natural reverse | Reverse natural |
| `, s` | Size | Sort by file size |
| `, S` | Size reverse | Largest first |

### Tabs

| Key | Action | Description |
|-----|--------|-------------|
| `t` | New tab | Create tab in current directory |
| `1-9` | Switch tab | Jump to tab number |
| `[` / `]` | Previous/Next | Cycle through tabs |
| `{` / `}` | Swap tabs | Reorder tabs |

### Visibility

| Key | Action | Description |
|-----|--------|-------------|
| `.` | Toggle hidden | Show/hide dotfiles |

### Linemode

| Key | Action | Description |
|-----|--------|-------------|
| `m s` | Size mode | Show file sizes |
| `m p` | Permissions | Show file permissions |
| `m m` | Mtime | Show modification times |
| `m n` | None | Hide extra info |

### Preview

| Key | Action | Description |
|-----|--------|-------------|
| `<A-j>` | Peek down | Scroll preview down |
| `<A-k>` | Peek up | Scroll preview up |

### Tasks & Help

| Key | Action | Description |
|-----|--------|-------------|
| `w` | Tasks | Show background tasks |
| `~` | Help | Open help menu |
| `q` | Quit | Exit yazi |
| `Q` | Quit no-cwd | Exit without saving CWD |
| `<C-z>` | Suspend | Suspend to background |

---

## File Openers

### Opener Definitions

Openers define how to open different file types.

#### Edit (Text Files)

```toml
edit = [
  { run = '$EDITOR "$@"', block = true, for = "unix" },
]
```

Opens text files in your `$EDITOR` (Neovim, Vim, etc.)

**Usage:** Automatically used for text files, or press `O` and select "edit"

#### Open (Default System)

```toml
open = [
  { run = 'open "$@"', desc = "Open", for = "macos" },
]
```

Uses macOS `open` command (equivalent to double-clicking).

**Usage:** Default for most files, or press `o` / `<Enter>`

#### Reveal (Show in Finder)

```toml
reveal = [
  { run = 'open -R "$1"', desc = "Reveal", for = "macos" },
]
```

Opens Finder and highlights the file.

**Usage:** Press `O` and select "reveal"

#### Extract (Archives)

```toml
extract = [
  { run = 'unar "$1"', desc = "Extract here", for = "unix" },
]
```

Extracts archives to current directory using `unar`.

**Usage:** Select archive, press `O`, select "extract"

#### Play (Media)

```toml
play = [
  { run = 'mpv "$@"', orphan = true, for = "unix" },
  { run = '''mediainfo "$1"; echo "Press enter to exit"; read''',
    block = true, desc = "Show media info", for = "unix" },
]
```

**Primary:** Opens video/audio in MPV player
**Secondary:** Shows media information with mediainfo

**Usage:** Automatically for video/audio, or press `O` to choose

### Opener Parameters

| Parameter | Meaning | Example |
|-----------|---------|---------|
| `run` | Command to execute | `'open "$@"'` |
| `block` | Block UI until complete | `true` / `false` |
| `orphan` | Run detached from yazi | `true` / `false` |
| `desc` | Description shown in menu | `"Open with MPV"` |
| `for` | Operating system filter | `"unix"` / `"macos"` / `"windows"` |

---

## MIME Type Rules

### How Files Are Opened

Files are matched against MIME type rules to determine available openers.

```toml
[open]
rules = [
  # Directories
  { name = "*/", use = [ "edit", "open", "reveal" ] },

  # Text files
  { mime = "text/*", use = [ "edit", "reveal" ] },

  # Images
  { mime = "image/*", use = [ "open", "reveal" ] },

  # Video & Audio
  { mime = "video/*", use = [ "play", "reveal" ] },
  { mime = "audio/*", use = [ "play", "reveal" ] },

  # Empty files
  { mime = "inode/x-empty", use = [ "edit", "reveal" ] },

  # Code files
  { mime = "application/json", use = [ "edit", "reveal" ] },
  { mime = "*/javascript", use = [ "edit", "reveal" ] },

  # Archives
  { mime = "application/zip", use = [ "extract", "reveal" ] },
  { mime = "application/gzip", use = [ "extract", "reveal" ] },
  { mime = "application/x-tar", use = [ "extract", "reveal" ] },
  { mime = "application/x-7z-compressed", use = [ "extract", "reveal" ] },
  { mime = "application/x-rar", use = [ "extract", "reveal" ] },

  # Fallback
  { mime = "*", use = [ "open", "reveal" ] },
]
```

### Rule Priority

Rules are evaluated **top to bottom**. First match wins.

### Common MIME Types

| File Type | MIME Type | Openers |
|-----------|-----------|---------|
| `.txt`, `.md` | `text/*` | edit, reveal |
| `.jpg`, `.png` | `image/*` | open, reveal |
| `.mp4`, `.mkv` | `video/*` | play, reveal |
| `.mp3`, `.flac` | `audio/*` | play, reveal |
| `.zip`, `.tar.gz` | `application/zip` | extract, reveal |
| `.js`, `.ts` | `*/javascript` | edit, reveal |
| `.json` | `application/json` | edit, reveal |

### Adding Custom Rules

To add a custom opener for specific files:

```toml
# 1. Define the opener
[opener]
sublime = [
  { run = 'subl "$@"', orphan = true, desc = "Sublime Text" },
]

# 2. Add to rules
[open]
rules = [
  { name = "*.txt", use = [ "sublime", "edit", "reveal" ] },
  # ... rest of rules
]
```

---

## Preview Configuration

```toml
[preview]
tab_size = 2              # Tab width in preview
max_width = 600           # Maximum preview width
max_height = 900          # Maximum preview height
cache_dir = ""            # Cache directory (empty = use default)
```

### Supported Preview Types

- **Text files:** Syntax-highlighted source code
- **Images:** Inline image preview (kitty/iTerm2/WezTerm)
- **Videos:** Video thumbnail frames
- **PDFs:** First page preview (requires poppler)
- **Archives:** Contents list
- **Directories:** File list

---

## Theme & Colors

This configuration uses the **OceanicNext** color scheme to match the vim/tmux setup.

### OceanicNext Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Background | `#1B2B34` | Base background |
| Foreground | `#D8DEE9` | Text |
| Red | `#EC5F67` | Errors, deletions, PDFs |
| Orange | `#F99157` | Audio files |
| Yellow | `#FAC863` | Video files, search |
| Green | `#99C794` | Executables, scripts, added |
| Cyan | `#62B3B2` | Images, symlinks |
| Blue | `#6699CC` | Directories, selections |
| Purple | `#C594C5` | Archives |
| Brown | `#AB7967` | Config files |
| Grey | `#65737E` | Hidden files, inactive |

### Manager Theme

```toml
[mgr]
cwd = { fg = "#6699CC" }
hovered = { fg = "#1B2B34", bg = "#6699CC", bold = true }

# Markers for file operations
marker_selected = { fg = "#99C794", bg = "#99C794" }
marker_copied = { fg = "#FAC863", bg = "#FAC863" }
marker_cut = { fg = "#EC5F67", bg = "#EC5F67" }

# Tabs
tab_active = { fg = "#1B2B34", bg = "#6699CC", bold = true }
tab_inactive = { fg = "#D8DEE9", bg = "#343D46" }
```

### File Type Colors

```toml
[filetype]
rules = [
  { name = "*/", fg = "#6699CC", bold = true },     # Directories
  { is = "link", fg = "#62B3B2", italic = true },   # Symlinks
  { is = "exec", fg = "#99C794" },                   # Executables
  { is = "hidden", fg = "#65737E" },                 # Hidden files
  { mime = "image/*", fg = "#62B3B2" },              # Images
  { mime = "video/*", fg = "#FAC863" },              # Videos
  { mime = "audio/*", fg = "#F99157" },              # Audio
  { mime = "application/pdf", fg = "#EC5F67" },      # PDFs
  { mime = "application/zip", fg = "#C594C5" },      # Archives
  { name = "*.toml", fg = "#AB7967" },               # Config
]
```

### Icons (350+ File Types)

The theme includes icons for all common file types:

```toml
[icons]
# macOS Directories
"Desktop/"     = ""
"Documents/"   = ""
"Downloads/"   = ""
"Pictures/"    = ""
"Music/"       = ""
"Movies/"      = ""
".config/"     = ""

# Development
"node_modules/"= ""
".venv/"       = ""
"target/"      = ""
".git/"        = ""
".github/"     = ""

# Programming
"*.py"   = ""
"*.js"   = ""
"*.ts"   = ""
"*.rs"   = ""
"*.go"   = ""
"*.lua"  = ""
"*.rb"   = ""
"*.java" = ""
"*.swift"= ""
"*.vue"  = ""
"*.svelte" = ""

# Build Tools
"Makefile"       = ""
"Cargo.toml"     = ""
"package.json"   = ""
"Dockerfile"     = ""
"docker-compose.yml" = ""

# Documents
"*.pdf"  = ""
"*.md"   = ""
"*.doc"  = ""

# Media
"*.mp3"  = ""
"*.mp4"  = ""
"*.jpg"  = ""
"*.png"  = ""
"*.svg"  = ""
```

Icons require a [Nerd Font](https://www.nerdfonts.com/) to display properly.

---

## Common Workflows

### Basic File Management

```text
# Navigate to directory
j/k to move cursor
l to enter directory
h to go to parent

# Copy files
<Space> to select files
y to yank (copy)
Navigate to destination
p to paste

# Move files
<Space> to select files
x to cut
Navigate to destination
p to paste

# Delete files
<Space> to select files
d to move to trash
OR
D to permanently delete
```

### Search Workflows

```text
# Find by name
/ to search
Type pattern
n/N to jump between matches

# Search by filename (fd)
s
Type search term
Navigate results

# Search by content (ripgrep)
S
Type search term
Navigate results
<Enter> to open file
```

### Archive Management

```text
# Extract archive
Navigate to .zip/.tar.gz file
O (uppercase O)
Select "Extract here"

# View archive contents
Navigate to archive
Look at preview pane (right column)
```

### Quick Directory Jumping

```text
# Using zoxide (smart history)
z
Type partial directory name
<Enter>

# Using fzf (fuzzy finder)
Z
Type to fuzzy search
<Enter> to jump
```

### Tab Workflow

```text
# Create tab in current directory
t

# Switch tabs
1-9 for specific tab
[ and ] to cycle

# Close tab
<C-q>
```

### Bulk Renaming

```text
# Select files
<Space> on each file
OR
<C-a> to select all

# Rename
: (shell command)
Type: for f in *.txt; do mv "$f" "prefix_$f"; done
```

### Shell Integration

```text
# Run command without blocking
;
Type command
<Enter>

# Run command and wait
:
Type command
<Enter>
Results shown, press key to continue
```

---

## Advanced Features

### Tasks Manager

Background operations (copy, move, delete) run asynchronously.

```text
# View running tasks
w

# Task list shows:
- Operation type
- Progress percentage
- File being processed

# Cancel task
Navigate to task
x to cancel
```

### Custom Shell Commands

Create shell aliases that integrate with yazi:

```bash
# In ~/.zshrc
alias ya='yazi'

# Change directory on exit
function yy() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
```

Now `yy` will change your shell's working directory when you quit yazi.

### Performance Tuning

```toml
[tasks]
micro_workers = 5        # Workers for small tasks
macro_workers = 10       # Workers for large tasks
bizarre_retry = 5        # Retry failed operations
```

Adjust based on your system:
- **Fast SSD:** Increase workers (10-20)
- **Network drives:** Decrease workers (3-5)

---

## Troubleshooting

### Images Not Previewing

**Problem:** Image previews not showing

**Solution:**
```bash
# Check if terminal supports images
# Supported: kitty, iTerm2, WezTerm, Alacritty with sixel

# For kitty:
echo $TERM  # Should be "xterm-kitty"

# Install image support
brew install imagemagick
```

### Slow Preview

**Problem:** Preview is slow or laggy

**Solution:**
```toml
# Reduce preview size
[preview]
max_width = 400
max_height = 600
```

### Icons Not Showing

**Problem:** Icons display as boxes or question marks

**Solution:**
```bash
# Install a Nerd Font
brew tap homebrew/cask-fonts
brew install --cask font-hack-nerd-font

# Set terminal font to "Hack Nerd Font"
```

### Openers Not Working

**Problem:** Files not opening with correct application

**Solution:**
```bash
# Check MIME type
file --mime-type filename.ext

# Verify opener is installed
which open    # macOS
which mpv     # Media player
which unar    # Archive extraction

# Test opener manually
open filename.ext
mpv video.mp4
```

### Search Not Working

**Problem:** `s` (fd) or `S` (rg) search fails

**Solution:**
```bash
# Install required tools
brew install fd ripgrep

# Test manually
fd pattern
rg "search term"
```

### Zoxide Integration

**Problem:** `z` command doesn't work

**Solution:**
```bash
# Install zoxide
brew install zoxide

# Add to shell config (already in dotfiles)
eval "$(zoxide init zsh)"

# Build database by cd'ing to directories
cd ~/Documents
cd ~/Downloads
# Now z will work
```

---

## Comparison with Other File Managers

| Feature | Yazi | Ranger | lf | nnn |
|---------|------|--------|-----|-----|
| Speed | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Image preview | ✅ | ✅ | ❌ | ❌ |
| Async I/O | ✅ | ❌ | ❌ | ✅ |
| Plugin system | ✅ | ✅ | ❌ | ✅ |
| Modern UI | ✅ | ⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| Vim bindings | ✅ | ✅ | ✅ | Partial |

---

## Quick Reference

### Most Used Commands

```text
hjkl        Navigate (Vim-style)
<Space>     Toggle selection
o           Open file
yxp         Yank, cut, paste
d/D         Delete (trash/permanent)
a           Create file/directory
r           Rename
.           Toggle hidden files
s/S         Search (name/content)
z/Z         Jump (zoxide/fzf)
t           New tab
~           Help
q           Quit
```

### File Creation

```text
a           Create prompt
filename    Create file
dirname/    Create directory (trailing slash)
```

### Copy Shortcuts

```text
cc          Copy absolute path
cd          Copy directory path
cf          Copy filename
cn          Copy name without extension
```

### Sorting

```text
,a / ,A     Alphabetical (normal/reverse)
,m / ,M     Modified time (normal/reverse)
,s / ,S     Size (normal/reverse)
```

---

## Related Documentation

- [Yazi Official Docs](https://yazi-rs.github.io/)
- [Yazi GitHub](https://github.com/sxyazi/yazi)
- [Nerd Fonts](https://www.nerdfonts.com/)
- [fd Documentation](https://github.com/sharkdp/fd)
- [ripgrep Documentation](https://github.com/BurntSushi/ripgrep)

---

**Configuration Location:** `~/dotfiles/config/yazi/`
**Symlinked To:** `~/.config/yazi/`
**Files:** `yazi.toml`, `keymap.toml`, `theme.toml`
