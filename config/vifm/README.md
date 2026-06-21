# Vifm Configuration

Vim-like file manager with dual-pane interface and powerful file operations.

## Overview

[Vifm](https://vifm.info/) is a terminal-based file manager with a Vim-like interface. Features include:

- **Dual-pane layout** - Two directory views side-by-side
- **Vim-style navigation** - hjkl movement, visual mode, text objects
- **Powerful file operations** - Copy, move, delete, rename with Vim commands
- **File associations** - Open files with specific applications
- **Customizable** - Extensive configuration via vifmrc
- **Cross-platform** - Works on macOS, Linux, BSB

**This configuration provides:**
- macOS-specific file associations (Preview, Safari, VLC, etc.)
- Vim integration (`vicmd=vim`)
- Smart file previews
- Trash support
- 100-level undo history

## Quick Links

- [Installation](#installation)
- [Navigation](#navigation)
- [File Operations](#file-operations)
- [File Associations](#file-associations)
- [Comparison with Yazi](#comparison-with-yazi)
- [Troubleshooting](#troubleshooting)

---

## Installation

### Prerequisites

```bash
# Install vifm
brew install vifm
```

### Configuration

**Symlink (created by install script):**
```bash
config/vifm/vifmrc → ~/.config/vifm/vifmrc
```

**Manual symlink if needed:**
```bash
ln -sf ~/dotfiles/config/vifm/vifmrc ~/.config/vifm/vifmrc
```

---

## Basic Usage

### Launching Vifm

```bash
# Open vifm in current directory
vifm

# Open specific directory
vifm ~/Downloads

# Open two directories (left and right panes)
vifm ~/Downloads ~/Desktop
```

### Interface Layout

```
┌─────────────────────────────────────────────┐
│ Left Pane          │  Right Pane           │ ← Two directory views
│ ~/Downloads/       │  ~/Desktop/           │
│                    │                        │
│ > file1.txt        │   image.png           │
│   file2.pdf        │   document.doc        │
│   archive.zip      │   video.mp4           │
│                    │                        │
└─────────────────────────────────────────────┘
  Command line: :                              ← Vim-style command mode
```

**Key areas:**
- **Left/Right panes** - Two independent directory views
- **Active pane** - Highlighted (where commands apply)
- **Inactive pane** - Secondary pane (destination for operations)
- **Status line** - File info, permissions, size
- **Command line** - Ex-mode commands (`:` like Vim)

---

## Navigation

### Basic Movement

**Vim-style navigation:**

| Key | Action | Description |
|-----|--------|-------------|
| `j` | Down | Move cursor down |
| `k` | Up | Move cursor up |
| `h` | Left/Parent | Go to parent directory |
| `l` | Right/Enter | Enter directory or open file |
| `gg` | Top | Jump to first file |
| `G` | Bottom | Jump to last file |
| `Ctrl-f` | Page down | Scroll down one page |
| `Ctrl-b` | Page up | Scroll up one page |
| `{` | Previous dir | Previous directory in history |
| `}` | Next dir | Next directory in history |

### Quick Navigation

| Key | Action | Description |
|-----|--------|-------------|
| `gh` | Home | Go to home directory (`~`) |
| `gh` then `h` | Root | Go to root directory (`/`) |
| `Tab` | Switch pane | Switch between left/right panes |
| `Space` | Select | Toggle file selection |
| `t` | Select | Toggle file selection (alternative) |
| `v` | Visual mode | Enter visual selection mode |
| `V` | Visual line | Visual line selection mode |

### Search and Filter

| Key | Action | Description |
|-----|--------|-------------|
| `/` | Search | Search for files (like Vim) |
| `?` | Search back | Search backwards |
| `n` | Next match | Next search result |
| `N` | Prev match | Previous search result |
| `=` | Filter | Filter files by pattern |

**Example search:**
```
/\.pdf$    " Find all PDF files
/^report   " Find files starting with "report"
```

---

## File Operations

### Basic Operations

| Key | Action | Command | Description |
|-----|--------|---------|-------------|
| `yy` | Yank | `:yank` | Copy file(s) |
| `dd` | Delete | `:delete` | Delete file(s) to trash |
| `p` | Put | `:put` | Paste copied/cut files |
| `cw` | Change | `:rename` | Rename file |
| `PP` | Put here | - | Paste in current directory |

**Workflow:**
```
1. yy      - Copy file
2. Tab     - Switch to other pane
3. p       - Paste file to other pane's directory
```

### Advanced Operations

| Key | Command | Description |
|-----|---------|-------------|
| `ZZ` | `:q` | Quit vifm |
| `ZQ` | `:q!` | Force quit |
| `:w` | - | Write vifminfo (save state) |
| `:mkdir` | - | Create directory |
| `:touch` | - | Create file |
| `:chmod` | - | Change permissions |

### Visual Mode

**Select multiple files:**

```vim
" Method 1: Visual mode
v           " Enter visual mode
jjj         " Select 3 files
y           " Yank (copy) selected

" Method 2: Space selection
Space       " Select file 1
j           " Move down
Space       " Select file 2
j           " Move down
Space       " Select file 3
d           " Delete selected

" Method 3: Pattern selection
:select *.txt   " Select all .txt files
:unselect *.md  " Unselect .md files
```

### Bulk Operations

**Rename multiple files:**

```vim
" Method 1: Bulk rename with editor
:rename!

" Opens editor with list of filenames:
# old-name-1.txt
# old-name-2.txt
# old-name-3.txt

" Edit names, save, and quit
# new-name-1.txt
# new-name-2.txt
# new-name-3.txt

" Files renamed when you save
```

**Substitute in filenames:**

```vim
:substitute/old/new/g      " Rename: old → new
:substitute/\.txt/\.md/g   " Change extension: .txt → .md
```

---

## File Associations

This configuration defines how different file types open:

### Documents

| File Type | Default Application | Alternatives |
|-----------|-------------------|--------------|
| **PDF** | Preview.app | Skim.app |
| **Text** | Vim | - |
| **Markdown** | Vim | - |
| **Office** | LibreOffice | - |

**Open PDF:**
```
1. Navigate to PDF file
2. Press 'l' or Enter
   → Opens in Preview.app
```

### Media

| File Type | Application |
|-----------|-------------|
| **Images** (jpg, png, gif) | Preview.app |
| **Videos** (mp4, mkv, avi) | VLC, QuickTime, MPlayerX |
| **Audio** (mp3, flac, m4a) | QuickTime |

### Archives

| File Type | Action |
|-----------|--------|
| **ZIP** | Unzip on Enter |
| **TAR/TGZ** | Extract on Enter |
| **DMG** | Mount disk image |
| **Torrent** | Open in Transmission |

**Extract archive:**
```
1. Navigate to archive.zip
2. Press 'l' or Enter
   → Extracts in current directory
```

### Development

| File Type | Application |
|-----------|-------------|
| **HTML** | Safari (default), Firefox, Chrome |
| **Code** | Vim |
| **Man pages** | man viewer |

---

## Settings

### Key Settings in vifmrc

```vim
" Editor for text files
set vicmd=vim

" Trash directory (deleted files go here)
set trash

" Directory history
set history=100

" Undo levels
set undolevels=100

" Smart case search
set ignorecase
set smartcase

" Incremental search
set incsearch

" Don't auto-highlight search
set nohlsearch

" Sort numbers naturally (file1, file2, file10)
set sortnumbers

" Show file info suggestions
set suggestoptions=normal,visual,view,otherpane,keys,marks,registers
```

### Active Customizations

**What's customized in this config:**
- ✅ Vim as default editor
- ✅ Trash support (safe delete)
- ✅ 100-level undo history
- ✅ macOS app associations
- ✅ Smart search (case-insensitive unless uppercase)
- ✅ Natural number sorting

**What's default:**
- Color scheme: Default
- File preview: Basic
- No custom keybindings (uses Vim defaults)

---

## Integration

### With Yazi

**This dotfiles includes both Vifm and Yazi:**

| Feature | Vifm | Yazi |
|---------|------|------|
| **Interface** | Dual-pane | Dual/Triple-pane |
| **Preview** | Basic text | Rich (images, code, PDFs) |
| **Speed** | Good | Excellent |
| **Vim-like** | Yes | Yes |
| **Configuration** | Vimscript | TOML/Lua |
| **Development** | Stable | Active |
| **Use case** | Traditional file operations | Modern preview & navigation |

**When to use which:**
- **Use Yazi** for: Browsing files with rich previews, modern UI, faster navigation
- **Use Vifm** for: Traditional dual-pane workflow, Vim muscle memory, bulk operations

### With Vim/Neovim

Vifm integrates with Vim:

**Open file in Vim:**
```
1. Navigate to file
2. Press 'v'
   → Opens in Vim
```

**File is opened using `vicmd=vim` setting**

---

## Customization

### Adding Keybindings

**Edit ~/.config/vifm/vifmrc:**

```vim
" Custom keybinding example
nnoremap s :shell<cr>     " 's' opens shell
nnoremap w :view<cr>      " 'w' toggles preview
nnoremap <f3> :!less %f<cr>  " F3 views file
```

### Adding File Associations

**Custom file opener:**

```vim
" Open Python files in specific editor
filetype *.py
       \ {Open in VS Code}
       \ code %f,
       \ {Open in Vim}
       \ vim %f,

" Open with custom script
filetype *.custom
       \ ~/scripts/custom-opener.sh %f
```

**Variables:**
- `%f` - Current file
- `%F` - Selected files
- `%d` - Current directory
- `%c` - Current file under cursor

### Changing Color Scheme

**Available schemes:**

```bash
# List available color schemes
ls ~/.config/vifm/colors/
```

**Set in vifmrc:**

```vim
colorscheme gruvbox
" or
colorscheme solarized
" or
colorscheme zenburn
```

---

## Commands

### Useful Ex Commands

| Command | Description |
|---------|-------------|
| `:cd path` | Change directory |
| `:pushd path` | Push directory to stack |
| `:popd` | Pop directory from stack |
| `:mkdir dirname` | Create directory |
| `:touch filename` | Create file |
| `:chmod mode file` | Change permissions |
| `:!command` | Run shell command |
| `:shell` | Open shell in current dir |
| `:view` | Toggle file preview |
| `:split` | Split window horizontally |
| `:vsplit` | Split window vertically |
| `:only` | Close all but current pane |

### Marks

**Save and jump to directories:**

```vim
" Save current directory
:mark m

" Jump to marked directory
'm

" Common marks
'H  - Home directory
'z  - User-defined
```

---

## Troubleshooting

### Issue: Keybindings not working

**Check if in correct mode:**
- Normal mode: For navigation
- Command mode (`:`) : For Ex commands
- Visual mode (`v`): For selection

**Solution:** Press `Esc` to return to normal mode

### Issue: Files not opening

**Check file association:**

```vim
:file
" Shows which application is associated
```

**Solution:** Update association in vifmrc

### Issue: Can't see file preview

**Vifm has basic preview by default.**

**Enable preview pane:**
```vim
:view    " Toggle preview
```

**Or use Yazi for rich previews:**
```bash
yazi
```

### Issue: Deleted files not in trash

**Check trash setting:**

```vim
:set trash?
" Should show: trash
```

**Solution:** Ensure `set trash` in vifmrc

---

## Comparison with Yazi

Both are included in this dotfiles. Choose based on your needs:

### Vifm Advantages

✅ **Traditional file manager** - Classic dual-pane layout
✅ **Pure Vim commands** - 100% Vim keybindings
✅ **Bulk operations** - Excellent for mass file operations
✅ **Stable** - Mature, stable codebase
✅ **Lightweight** - Minimal dependencies

### Yazi Advantages

✅ **Rich previews** - Images, PDFs, code with syntax highlighting
✅ **Modern** - Active development, new features
✅ **Faster** - Written in Rust, optimized performance
✅ **Better UI** - More visual feedback, colors
✅ **File previews** - See content before opening

### Recommendation

- **Daily browsing:** Yazi (better previews, faster)
- **Bulk operations:** Vifm (better for renaming 100 files)
- **Vim purists:** Vifm (100% Vim commands)
- **Modern users:** Yazi (better UX)

**You can use both!** Each has its strengths.

---

## Related Documentation

- [Yazi Configuration](../yazi/README.md) - Alternative modern file manager
- [Shell Configuration](../../terminal/zsh/README.md) - Shell aliases and functions
- [Vim Configuration](../../editors/vim/README.md) - Text editor integration

## Resources

- [Official Documentation](https://vifm.info/manual.shtml)
- [GitHub Repository](https://github.com/vifm/vifm)
- [Wiki](https://wiki.vifm.info/)
- [Cheatsheet](https://vifm.info/cheatsheets.shtml)

---

## Related Documentation

- [Yazi Configuration](../yazi/README.md) - Alternative modern file manager
- [Shell Configuration](../../terminal/zsh/README.md) - Shell aliases and functions
- [Vim Configuration](../../editors/vim/README.md) - Text editor integration
- [Troubleshooting](../../docs/TROUBLESHOOTING.md) - Common issues

## Getting Help

- Run health check: `./scripts/health-check.sh`
- Review [Troubleshooting Guide](../../docs/TROUBLESHOOTING.md)
- Check vifm help: `:help` in vifm

---

**Status:** ✅ Complete
**Last Updated:** 2025-12-20
