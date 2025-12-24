# Terminal: Tmux & Tmuxinator Configuration

Terminal multiplexer configuration for managing multiple shell sessions and project workspaces.

## Overview

This configuration combines **Tmux** (terminal multiplexer) with **Tmuxinator** (session manager) for powerful terminal workflow management.

**Key Features:**
- Custom prefix key (F12/Caps Lock)
- Vim-style navigation
- Seamless Vim/Tmux pane switching
- Session persistence and restore
- Project-based workspace templates
- Mouse support
- Clipboard integration

**Configuration Files:**
- `tmux.conf` - Main Tmux configuration
- `tmuxinator/*.yml` - Project session templates

---

## Table of Contents

- [Tmux Concepts](#tmux-concepts)
- [Installation](#installation)
- [Tmux Configuration](#tmux-configuration)
  - [Status Bar Theme](#status-bar-theme-oceanicnext)
- [Keybindings](#keybindings)
- [Plugins](#plugins)
- [Tmuxinator Sessions](#tmuxinator-sessions)
- [Common Workflows](#common-workflows)
- [Troubleshooting](#troubleshooting)
- [Quick Reference](#quick-reference-card)

---

## Tmux Concepts

Understanding the hierarchy of sessions, windows, and panes:

```
Session "work"
├── Window 1: "editor"
│   ├── Pane 1: nvim (80%)
│   └── Pane 2: terminal (20%)
├── Window 2: "server"
│   └── Pane 1: npm run dev
└── Window 3: "git"
    └── Pane 1: lazygit
```

| Concept | Description | Analogy |
|---------|-------------|---------|
| **Session** | A collection of windows. Persists when you detach. | Desktop workspace |
| **Window** | Like a tab. Each fills the terminal. Switch with `F12 1-9`. | Browser tab |
| **Pane** | A split within a window. Multiple visible at once. | Split screen |

### Layouts

| Layout | Description |
|--------|-------------|
| `even-horizontal` | Panes side by side, equal width |
| `even-vertical` | Panes stacked, equal height |
| `main-horizontal` | One large pane on top, others below |
| `main-vertical` | One large pane on left, others right |
| `tiled` | Grid of equal-sized panes |

Switch layouts with `F12 Alt+1-5` or cycle with `F12 Space`.

### Synchronize Panes

Broadcasts keyboard input to all panes in current window. Useful for:
- Running same command on multiple servers
- Updating multiple config files simultaneously
- Parallel testing

Toggle with `F12 S`. Status bar shows "SYNC" when active.

---

## Installation

### Prerequisites

```bash
# Install Tmux
brew install tmux

# Install Tmuxinator
gem install tmuxinator

# Install Tmux Plugin Manager (TPM)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

> **Note:** `reattach-to-user-namespace` is no longer needed on macOS 10.14+

### Configuration Setup

Symlinked automatically via dotfiles:

```bash
# Via dotfiles installation
cd ~/dotfiles
./scripts/install.sh

# Manual symlinks
ln -s ~/dotfiles/terminal/tmux.conf ~/.tmux.conf
ln -s ~/dotfiles/terminal/tmuxinator ~/.tmuxinator
```

### First Launch

1. Start Tmux: `tmux`
2. Install plugins: `F12 + I` (capital I)
3. Wait for plugin installation to complete

---

## Tmux Configuration

### Prefix Key

**Mapped to:** `F12` (via PCKeyboardHack/Karabiner mapping Caps Lock → F12)

```tmux
set-option -g prefix F12
bind-key F12 last-window
```

**Why F12?**
- Caps Lock is convenient (thumb position)
- F12 doesn't conflict with common shortcuts
- Double-tap F12 to switch to last window

**Alternative:** Uncomment to use `Ctrl+a`:
```tmux
# set-option -g prefix C-a
```

### Base Settings

```tmux
# Window and pane numbering starts at 1 (not 0)
set -g base-index 1
set -g pane-base-index 1

# Close gaps when windows are closed (1,3,4 → 1,2,3)
set -g renumber-windows on

# Vi mode for copy mode
setw -g mode-keys vi

# True color support
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*256col*:Tc,ghostty:Tc"

# Mouse support
set -g mouse on

# Enable focus events for better editor integration (autoread in Neovim)
set -g focus-events on

# Prevent automatic window renaming
set-option -g allow-rename off

# Command history
set -g history-file ~/.tmux_history
```

### macOS Integration

```tmux
# Clipboard integration (macOS 10.14+ - no reattach-to-user-namespace needed)
set-option -g default-command "$SHELL"

# Copy to system clipboard
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
```

### Status Bar Theme (OceanicNext)

The status bar is styled to match the OceanicNext color scheme used in Vim/Neovim.

**Color Palette:**
| Color | Hex | Usage |
|-------|-----|-------|
| Background | `#1B2B34` | Status bar background |
| Foreground | `#D8DEE9` | Default text |
| Cyan | `#6699CC` | Session name, active pane border |
| Green | `#99C794` | Hostname |
| Grey | `#343D46` | Current window, secondary backgrounds |
| Muted | `#A7ADBA` | Inactive window text |

**Status Bar Layout:**
```
┌─────────────────────────────────────────────────────────────────┐
│  SESSION   1 window1   2 window2*        2024-01-15  12:30   hostname │
└─────────────────────────────────────────────────────────────────┘
     ↑           ↑           ↑                  ↑          ↑        ↑
   cyan     inactive    current(grey)        date       time     green
```

**Configuration:**
```tmux
# Status bar styling (OceanicNext theme)
set -g status-style 'bg=#1B2B34 fg=#D8DEE9'
set -g status-left '#[fg=#1B2B34,bg=#6699CC,bold] #S #[fg=#6699CC,bg=#1B2B34]'
set -g status-right '#[fg=#343D46]#[fg=#D8DEE9,bg=#343D46] %Y-%m-%d  %H:%M #[fg=#99C794]#[fg=#1B2B34,bg=#99C794,bold] #h '
setw -g window-status-format '#[fg=#A7ADBA] #I #W '
setw -g window-status-current-format '#[fg=#1B2B34,bg=#343D46]#[fg=#D8DEE9,bg=#343D46,bold] #I #W #[fg=#343D46,bg=#1B2B34]'
```

**Powerline Symbols:**
The status bar uses powerline arrow characters (``, ``) for section separators. Ensure your terminal font includes powerline glyphs (e.g., Nerd Fonts, Powerline fonts).

**Vim Integration:**
When using Vim with `tmuxline.vim` plugin, the status bar theme automatically syncs with airline. The preset is configured in `editors/vim/misc.vim`.

---

## Keybindings

**Note:** All bindings assume prefix `F12` unless noted with `-n` (no prefix needed).

### Session Management

| Key | Action | Description |
|-----|--------|-------------|
| `F12 F12` | Last window | Toggle between current and last window |
| `F12 d` | Detach | Detach from session (keeps running) |
| `F12 $` | Rename session | Rename current session |
| `F12 Q` | Kill server | **Dangerous:** Kill entire Tmux server |

### Window Management

| Key | Action | Description |
|-----|--------|-------------|
| `F12 c` | New window | Create new window |
| `F12 ,` | Rename window | Rename current window |
| `F12 &` | Kill window | Close current window |
| `F12 n` | Next window | Go to next window |
| `F12 p` | Previous window | Go to previous window |
| `F12 0-9` | Window number | Jump to window by number |
| `F12 w` | Window list | Show all windows |
| `Shift+←` | Move window left | Reorder window position |
| `Shift+→` | Move window right | Reorder window position |

### Pane Management

| Key | Action | Description |
|-----|--------|-------------|
| `F12 "` | Split horizontal | Split pane horizontally |
| `F12 %` | Split vertical | Split pane vertically |
| `F12 x` | Kill pane | Close current pane |
| `F12 z` | Zoom pane | Toggle pane fullscreen |
| `F12 {` | Swap pane left | Swap with previous pane |
| `F12 }` | Swap pane right | Swap with next pane |
| `F12 Space` | Cycle layouts | Rotate through layouts |

### Pane Navigation (Vim/Tmux Integration)

**Seamless navigation** between Tmux panes and Vim splits:

| Key | Action | Description |
|-----|--------|-------------|
| `Ctrl+h` | Left | Move to left pane/split |
| `Ctrl+j` | Down | Move to pane/split below |
| `Ctrl+k` | Up | Move to pane/split above |
| `Ctrl+l` | Right | Move to right pane/split |

**No prefix needed** - works in both Tmux and Neovim!

### Pane Resizing

| Key | Action | Description |
|-----|--------|-------------|
| `F12 h` | Resize left | Decrease width by 10 |
| `F12 j` | Resize down | Decrease height by 10 |
| `F12 k` | Resize up | Increase height by 10 |
| `F12 l` | Resize right | Increase width by 10 |

### Copy Mode

Enter copy mode to scroll and copy text:

| Key | Action | Description |
|-----|--------|-------------|
| `F12 [` | Enter copy mode | Start scrolling/copying |
| `v` | Visual selection | Start selecting text (Vi mode) |
| `y` | Yank | Copy selection to clipboard |
| `Enter` | Copy | Copy and exit copy mode |
| `Escape` | Cancel | Exit copy mode without copying |
| `Ctrl+v` | Rectangle | Toggle block/rectangle selection |
| `q` | Exit | Leave copy mode |
| `Space` | Begin selection | Alternative to `v` |

**Rectangle selection:** Toggle with `Ctrl+v` to select columns of text (useful for selecting table columns, aligned code, etc.)

**Vim keybindings work in copy mode:**
- `h j k l` - Navigate
- `w / b` - Word forward/back
- `0 / $` - Line start/end
- `g g / G` - Top/bottom
- `Ctrl+d / Ctrl+u` - Page down/up
- `/ pattern` - Search forward
- `? pattern` - Search backward

### Configuration

| Key | Action | Description |
|-----|--------|-------------|
| `F12 r` | Reload config | Source `~/.tmux.conf` |
| `F12 ?` | Show keys | Display all keybindings |
| `F12 :` | Command prompt | Enter Tmux command |

### Plugin Management (TPM)

| Key | Action | Description |
|-----|--------|-------------|
| `F12 I` | Install plugins | Install/update all plugins |
| `F12 U` | Update plugins | Update TPM and plugins |
| `F12 alt+u` | Uninstall plugins | Remove unlisted plugins |

### Productivity Keybindings

| Key | Action | Description |
|-----|--------|-------------|
| `F12 S` | Sync panes | Toggle input broadcast to all panes |
| `F12 \|` | Vertical split | Split keeping current directory |
| `F12 -` | Horizontal split | Split keeping current directory |
| `F12 C` | New window (path) | New window in current directory |
| `F12 s` | Session picker | Tree view of all sessions |
| `F12 w` | Window picker | Tree view of all windows |
| `F12 J` | Join pane | Pull pane from another window |
| `F12 B` | Break pane | Move pane to new window |
| `F12 Ctrl+k` | Clear history | Clear scrollback and screen |
| `F12 b` | Toggle status | Show/hide status bar |
| `F12 Alt+1` | Layout: even-h | Even horizontal layout |
| `F12 Alt+2` | Layout: even-v | Even vertical layout |
| `F12 Alt+3` | Layout: main-h | Main horizontal layout |
| `F12 Alt+4` | Layout: main-v | Main vertical layout |
| `F12 Alt+5` | Layout: tiled | Tiled layout |

### Workflow Enhancement Keybindings

| Key | Action | Description |
|-----|--------|-------------|
| `F12 Space` | Which-key menu | Show contextual keybinding hints |
| `F12 f` | FZF menu | Fuzzy find sessions/windows/panes |
| `F12 a` | Thumbs | Hint-based text selection |
| `F12 e` | Extrakto | FZF-based text extraction |
| `F12 g` | Switch session | Prompt for session name (sessionist) |
| `F12 @` | Promote pane | Move pane to new session (sessionist) |

---

## Plugins

### Tmux Plugin Manager (TPM)

```tmux
set -g @plugin 'tmux-plugins/tpm'
```

**Plugin manager** - Must be installed first.

**Installation:**
```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

**Usage:**
- `F12 I` - Install plugins
- `F12 U` - Update plugins

### tmux-sensible

```tmux
set -g @plugin 'tmux-plugins/tmux-sensible'
```

**Sensible default settings:**
- Better scrollback (50,000 lines)
- Better status bar refresh rate
- UTF-8 support
- Focus events enabled
- Aggressive resize

### tmux-resurrect

```tmux
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @resurrect-capture-pane-contents 'on'
```

**Save and restore sessions** after reboot.

**Features:**
- Saves session layout
- Restores running programs
- Restores pane contents
- Restores command history

**Usage:**
- `F12 Ctrl+s` - Save session
- `F12 Ctrl+r` - Restore session

**Saved to:** `~/.tmux/resurrect/`

### tmux-continuum

```tmux
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @continuum-restore 'off'
set -g @continuum-save-interval '15'
```

**Automatic session saving** - pairs with resurrect.

**Features:**
- Auto-saves every 15 minutes
- Manual restore available (auto-restore disabled to avoid conflicts with tmuxinator)
- Works alongside tmuxinator for project-based sessions

**Configuration:**
- `@continuum-restore 'off'` - Disabled to prevent conflicts with tmuxinator session layouts
- `@continuum-save-interval '15'` - Save every 15 minutes (set to '0' to disable)

### tmux-urlview

```tmux
set -g @plugin 'tmux-plugins/tmux-urlview'
```

**Extract and open URLs** from terminal.

**Usage:**
1. `F12 u` - Open URL picker
2. Navigate with `j/k`
3. `Enter` - Open URL in browser

**Requires:** `brew install urlview`

### tmux-copycat

```tmux
set -g @plugin 'tmux-plugins/tmux-copycat'
```

**Enhanced search** in copy mode.

**Search shortcuts:**
- `F12 /` - Regex search
- `F12 Ctrl+f` - File paths
- `F12 Ctrl+g` - Git status files
- `F12 Ctrl+u` - URLs
- `F12 Ctrl+d` - Digits
- `F12 Alt+i` - IP addresses

### tmux-open

```tmux
set -g @plugin 'tmux-plugins/tmux-open'
set -g @open-S 'https://www.duckduckgo.com/'
```

**Open files and URLs** from copy mode.

**Usage in copy mode:**
- `o` - Open selection (files with $EDITOR, URLs in browser)
- `Ctrl+o` - Open selection with $PAGER
- `S` - Search selection on DuckDuckGo

### tmux-which-key

```tmux
set -g @plugin 'alexwforsythe/tmux-which-key'
```

**Contextual keybinding hints** - Shows available keybindings when you pause after pressing prefix.

**Features:**
- Automatic menu display after prefix key
- Organized by category (Windows, Panes, Sessions, etc.)
- Shows custom keybindings alongside defaults
- Improves discoverability of tmux features

**Usage:**
- Press `F12` and wait briefly - menu appears automatically
- Press `Space` for main menu
- Navigate with arrow keys or vim keys

### tmux-fzf

```tmux
set -g @plugin 'sainnhe/tmux-fzf'
set -g @tmux-fzf-launch-key "f"
```

**FZF integration for tmux** - Fuzzy find sessions, windows, panes, and more.

**Features:**
- Session switcher
- Window switcher
- Pane switcher
- Command menu
- Keybinding browser

**Usage:**
- `F12 f` - Launch FZF menu
- Type to filter, `Enter` to select
- `Esc` to cancel

### tmux-thumbs

```tmux
set -g @plugin 'fcsonline/tmux-thumbs'
set -g @thumbs-key a
```

**Fast text selection with hints** - Vim-like hint mode for copying text.

**Features:**
- Shows hint labels over copyable text (paths, URLs, hashes, IPs)
- Fast keyboard-driven selection
- No need to enter copy mode first
- Regex-based pattern matching

**Usage:**
- `F12 a` - Activate hint mode
- Type hint letters to select
- Automatically copies to clipboard

**Requires:** `brew install tmux-thumbs`

### extrakto

```tmux
set -g @plugin 'laktak/extrakto'
set -g @extrakto_key e
set -g @extrakto_grab_area "full"
set -g @extrakto_fzf_tool "fzf"
```

**FZF-based text extraction** - Alternative to thumbs with FZF interface.

**Features:**
- Extracts paths, URLs, git hashes, IPs, etc.
- FZF fuzzy filtering
- Works on full pane content
- Integrates with clipboard

**Usage:**
- `F12 e` - Launch extrakto
- Type to filter matches
- `Enter` to copy selection
- `Tab` to insert into prompt

**Comparison with thumbs:**
- Thumbs: Faster, overlay hints directly on text
- Extrakto: More flexible filtering with FZF

### tmux-yank

```tmux
set -g @plugin 'tmux-plugins/tmux-yank'
```

**Enhanced clipboard integration** - Improved copying to system clipboard.

**Features:**
- Better clipboard support across different systems
- Mouse selection auto-copies
- Works with copy mode selections
- Handles terminal vs GUI contexts

**Usage:**
- In copy mode: `y` yanks to clipboard
- Mouse select: Automatically copies
- Works seamlessly with macOS, Linux, WSL

### tmux-prefix-highlight

```tmux
set -g @plugin 'tmux-plugins/tmux-prefix-highlight'
set -g @prefix_highlight_show_copy_mode 'on'
set -g @prefix_highlight_copy_mode_attr 'fg=#1B2B34,bg=#FAC863,bold'
set -g @prefix_highlight_prefix_prompt 'PREFIX'
set -g @prefix_highlight_copy_prompt 'COPY'
```

**Visual prefix indicator** - Shows when prefix key or copy mode is active.

**Features:**
- Status bar indicator when prefix pressed
- Shows "COPY" when in copy mode
- Customizable colors and text
- Helps avoid confusion about current mode

**Display:**
- Shows "PREFIX" in status bar when `F12` is pressed
- Shows "COPY" when in copy mode
- Disappears after key sequence completes

### tmux-sessionist

```tmux
set -g @plugin 'tmux-plugins/tmux-sessionist'
```

**Session management helpers** - Enhanced session switching and manipulation.

**Features:**
- Quick session switching
- Create new sessions
- Promote pane to new session
- Kill sessions without detaching

**Keybindings:**
- `F12 g` - Prompt for session name and switch to it
- `F12 C` (Shift+c) - Create new session
- `F12 X` (Shift+x) - Kill current session without detaching
- `F12 S` (Shift+s) - Switch to last session (Note: overridden by sync-panes binding)
- `F12 @` - Promote current pane into new session

**Note:** The `F12 S` binding is overridden by the sync-panes toggle in this configuration.

---

## Tmuxinator Sessions

### What is Tmuxinator?

**Project-based Tmux sessions** - Define window/pane layouts in YAML files.

**Benefits:**
- Consistent project workspaces
- One command to launch entire setup
- Shareable configurations
- Automatic directory navigation

### Available Sessions

| Template | Name | Purpose |
|----------|------|---------|
| `b.yml` | blog | Jekyll blog development |
| `d.yml` | dscgrm | dscgrm project development |
| `p.yml` | Personal | Personal workspace with email, music, files |

### Session: blog (b.yml)

**Purpose:** Jekyll blog development with live preview

**Layout:**
```yaml
name: blog
root: /Users/jeromefaria/Work/jeromefaria.github.io/
windows:
  - blog:
      panes:
        - nvim                                          # Editor
        - sleep 5 && open http://localhost:4000 && clear  # Browser
        - bundle exec jekyll serve -D                  # Dev server
```

**Panes:**
1. **Editor** - Neovim for editing posts
2. **Browser** - Opens http://localhost:4000 after 5 seconds
3. **Server** - Jekyll development server with drafts

**Usage:**
```bash
tmuxinator start blog
# OR
mux blog
```

### Session: dscgrm (d.yml)

**Purpose:** General project development workspace

**Layout:**
```yaml
name: dscgrm
root: /Users/jeromefaria/Work/projects/dscgrm
windows:
  - development:
      panes:
        - nvim      # Editor
        - clear     # Shell 1
        - clear     # Shell 2
```

**Panes:**
1. **Editor** - Neovim for code editing
2. **Shell 1** - For git, testing, etc.
3. **Shell 2** - For running servers, watching, etc.

**Usage:**
```bash
tmuxinator start dscgrm
# OR
mux dscgrm
```

### Session: Personal (p.yml)

**Purpose:** Personal productivity workspace

**Layout:**
```yaml
name: Personal
root: ~/
windows:
  - files:      # File management (Yazi)
  - dotfiles:   # Dotfiles editing
  - email:      # Email (Neomutt)
  - transfer:   # File transfers
  - music:      # Music player (Musikcube)
```

**Windows breakdown:**

#### 1. files
```yaml
panes:
  - yazi        # Terminal file manager
  - clear       # General shell
layout: even-vertical
```

#### 2. dotfiles
```yaml
pre: cd ~/dotfiles
panes:
  - nvim        # Edit dotfiles
  - clear       # Git commands, testing
```

#### 3. email
```yaml
panes:
  - neomutt     # Email client
```

#### 4. transfer
```yaml
panes:
  - clear       # scp, rsync, etc.
  - clear       # Second shell for monitoring
layout: even-vertical
```

#### 5. music
```yaml
panes:
  - musikcube   # Terminal music player
```

**Usage:**
```bash
tmuxinator start Personal
# OR
mux Personal
```

### Creating Custom Sessions

```bash
# Create new session template
tmuxinator new myproject

# Opens editor with template:
```

**Basic template:**
```yaml
name: myproject
root: ~/projects/myproject

# Optional: Run before *everything*
pre_window: rbenv shell 2.0.0-p481

windows:
  - editor:
      layout: main-vertical
      panes:
        - nvim
        - clear
  - server:
      panes:
        - npm run dev
  - shell:
      panes:
        - clear
```

**Advanced features:**
```yaml
# Run command before window opens
pre: cd ~/project

# Custom layout string (get with: tmux list-windows)
layout: 81fd,151x42,0,0[151x34,0,0,1,151x7,0,35{75x7,0,35,2,75x7,76,35,3}]

# Named panes
panes:
  - editor: nvim
  - shell: clear
  - server: npm start

# Multiple windows
windows:
  - window1:
      panes:
        - echo "pane 1"
  - window2:
      panes:
        - echo "pane 2"
```

### Tmuxinator Commands

```bash
# List all sessions
tmuxinator list
mux list

# Start session
tmuxinator start [name]
mux [name]

# Stop session
tmuxinator stop [name]

# Edit session
tmuxinator edit [name]

# Copy existing session
tmuxinator copy [existing] [new]

# Delete session
tmuxinator delete [name]

# Show session info
tmuxinator debug [name]

# Validate YAML
tmuxinator doctor
```

---

## Common Workflows

### Starting Your Day

```bash
# Start personal workspace
mux Personal

# Windows automatically created:
# 1. File manager (Yazi)
# 2. Dotfiles editor
# 3. Email (Neomutt)
# 4. Transfer terminal
# 5. Music player

# Navigate windows
F12 1-5        # Jump to window
F12 n/p        # Next/previous
```

### Project Development

```bash
# Start project session
mux dscgrm

# Layout appears:
# ┌──────────────┬───────────┐
# │              │           │
# │    Neovim    │  Shell 1  │
# │              │           │
# │              ├───────────┤
# │              │  Shell 2  │
# └──────────────┴───────────┘

# Navigate panes
Ctrl+h/j/k/l   # Move between panes (works in Vim too!)

# Work in shells
F12 Ctrl+j     # Jump to Shell 1
npm run dev    # Start dev server

F12 Ctrl+j     # Jump to Shell 2
git status     # Git commands
```

### Pair Programming

```bash
# Create shared session
tmux new -s pairing

# Partner connects
tmux attach -t pairing

# Both see same screen
# Both can control
```

### Temporary Detach

```bash
# Working on laptop
mux Personal
# Do work...

# Need to leave
F12 d              # Detach

# Later, from different location
tmux attach -t Personal    # Resume exactly where you left off
```

### Session Management

```bash
# List running sessions
tmux ls

# Attach to existing
tmux attach -t session-name

# Kill session
tmux kill-session -t session-name

# Kill all except current
tmux kill-session -a

# Rename current session
F12 $
```

---

## Vim/Tmux Integration

### Seamless Navigation

The configuration enables **unified navigation** across Vim splits and Tmux panes.

**How it works:**
```tmux
# Smart pane switching with Vim awareness (also handles fzf)
is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
bind -n C-h if-shell "$is_vim" "send-keys C-h" "select-pane -L"
bind -n C-j if-shell "$is_vim" "send-keys C-j" "select-pane -D"
bind -n C-k if-shell "$is_vim" "send-keys C-k" "select-pane -U"
bind -n C-l if-shell "$is_vim" "send-keys C-l" "select-pane -R"
```

> The detection pattern also handles **fzf** popups, ensuring navigation keys are passed through correctly when using fuzzy finders.

**Experience:**
```text
# In Neovim with splits
Ctrl+h/j/k/l    # Navigate between Vim splits

# When at edge of Vim window
Ctrl+h/j/k/l    # Seamlessly moves to Tmux pane

# In Tmux pane (not Vim)
Ctrl+h/j/k/l    # Navigate between Tmux panes
```

**Plugin required in Neovim:**
```lua
-- In Neovim config (already included in dotfiles)
require('nvim-tmux-navigation').setup()
```

---

## Advanced Features

### Session Persistence

**Automatic saving** via tmux-continuum:

```bash
# Session saves every 15 minutes automatically
# Auto-restore is disabled to avoid conflicts with tmuxinator
# Use manual restore when needed
```

**Manual save/restore:**
```bash
# Save current session
F12 Ctrl+s

# After reboot or when needed
tmux
F12 Ctrl+r      # Restore last saved session
```

### Copy Mode Tips

```bash
# Enter copy mode
F12 [

# Vim-style navigation
h j k l           # Move cursor
w / b             # Word forward/back
Ctrl+d / Ctrl+u   # Page down/up
g g / G           # Top/bottom
/ pattern         # Search forward
? pattern         # Search backward

# Select and copy
v                 # Start visual selection
y                 # Yank to clipboard

# Paste
F12 ]             # Paste from Tmux buffer
Cmd+V             # Paste from system clipboard
```

### Custom Layouts

**Get current layout string:**
```bash
tmux list-windows
# Shows: 81fd,151x42,0,0[151x34,0,0,1,151x7,0,35{75x7,0,35,2,75x7,76,35,3}]
```

**Use in Tmuxinator:**
```yaml
layout: 81fd,151x42,0,0[151x34,0,0,1,151x7,0,35{75x7,0,35,2,75x7,76,35,3}]
```

**Common layouts:**
- `even-horizontal` - Equal width panes
- `even-vertical` - Equal height panes
- `main-horizontal` - Large top, small bottom
- `main-vertical` - Large left, small right
- `tiled` - Grid layout

---

## Troubleshooting

### Prefix Key Not Working

**Problem:** F12 doesn't work as prefix

**Solution:**
```bash
# Check if Caps Lock mapped to F12
# macOS: Use Karabiner-Elements

# Alternative: Use Ctrl+a
# Edit ~/.tmux.conf:
set-option -g prefix C-a
bind-key C-a send-prefix

# Reload config
F12 r
```

### Colors Look Wrong

**Problem:** Colors not displaying correctly

**Solution:**
```bash
# Check terminal
echo $TERM
# Should be: "tmux-256color" inside tmux

# Reload Tmux
tmux kill-server
tmux
```

### Clipboard Not Working

**Problem:** Can't copy to macOS clipboard

**Solution:**
```bash
# Test copy
F12 [
v (select text)
y (yank)
Cmd+V (paste in other app)

# If still not working, check tmux version
tmux -V
# Should be 2.6+ for native clipboard support

# Verify copy binding
F12 :
list-keys -T copy-mode-vi
# Should show: y ... copy-pipe-and-cancel "pbcopy"
```

> **Note:** `reattach-to-user-namespace` is no longer needed on macOS 10.14+

### Plugins Not Installing

**Problem:** `F12 I` doesn't install plugins

**Solution:**
```bash
# Install TPM manually
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Reload config
tmux source ~/.tmux.conf

# Try again
F12 I
```

### Vim Navigation Not Working

**Problem:** Ctrl+h/j/k/l doesn't switch between Vim and Tmux

**Solution:**
```bash
# Check Neovim has tmux navigator plugin
# Should be in dotfiles: lua/plugins/misc.lua

# Verify plugin installed
:checkhealth

# Restart both Tmux and Neovim
```

### Tmuxinator Session Won't Start

**Problem:** `mux project` fails

**Solution:**
```bash
# Check YAML syntax
tmuxinator doctor

# Validate specific session
tmuxinator debug project

# Common issues:
# - Incorrect indentation (use 2 spaces)
# - Missing required fields (name, windows)
# - Invalid layout string
```

### Session Not Persisting

**Problem:** Session doesn't restore after reboot

**Solution:**
```bash
# Check resurrect/continuum installed
F12 I

# Manual save
F12 Ctrl+s

# Check save location
ls ~/.tmux/resurrect/
# Should see timestamped files

# Manual restore
F12 Ctrl+r
```

---

## Performance Tips

### Faster Startup

```tmux
# Limit history (in ~/.tmux.conf)
set-option -g history-limit 10000    # Default: 50000

# Disable unused plugins by commenting them out in ~/.tmux.conf
```

### Reduce Resource Usage

```bash
# Kill idle sessions
tmux kill-session -t unused-session

# Clear scrollback
F12 :
clear-history

# Limit window count
# Keep sessions focused and minimal
```

---

## Quick Reference

### Essential Commands

```bash
# Sessions
tmux                    # Start new session
tmux ls                 # List sessions
tmux attach -t name     # Attach to session
F12 d                   # Detach
F12 Q                   # Kill server

# Windows
F12 c                   # New window
F12 ,                   # Rename window
F12 n/p                 # Next/previous
F12 0-9                 # Jump to window

# Panes
F12 "                   # Split horizontal
F12 %                   # Split vertical
Ctrl+h/j/k/l            # Navigate panes
F12 z                   # Zoom pane
F12 x                   # Kill pane

# Copy mode
F12 [                   # Enter copy mode
v                       # Visual selection
y                       # Yank (copy)
F12 ]                   # Paste

# Tmuxinator
mux [project]           # Start project
mux list                # List projects
mux edit [project]      # Edit project
```

### Most Used Keys

```text
F12 c       New window
F12 n/p     Next/prev window
F12 "       Split horizontal
F12 %       Split vertical
Ctrl+hjkl   Navigate panes
F12 z       Zoom pane
F12 [       Copy mode
F12 d       Detach
F12 r       Reload config
F12 Space   Which-key menu
F12 f       FZF menu
F12 a       Thumbs (text hints)
```

---

## Quick Reference Card

```
QUICK REFERENCE (Prefix: F12)
─────────────────────────────────────────────────────────────────
Sessions:  d=detach  s=pick  $=rename  Q=kill-server  g=switch
Windows:   c=new  C=new(path)  n/p=next/prev  ,=rename  0-9=jump
Panes:     |/-=split(path)  "/%=split  x=kill  z=zoom
Navigate:  Ctrl+hjkl (no prefix, works in vim too)
Resize:    hjkl (with prefix)
Layouts:   Alt+1-5  Space=cycle
Copy:      [=enter  v=select  y=copy  Escape=cancel  Ctrl+v=rect
Special:   S=sync  b=status  J=join  B=break  r=reload  Ctrl+k=clear
Workflow:  Space=which-key  f=fzf  a=thumbs  e=extrakto  @=promote
Plugins:   I=install  U=update
Persist:   Ctrl+s=save  Ctrl+r=restore (auto-saves every 15min)
─────────────────────────────────────────────────────────────────
```

---

## Related Documentation

- [Tmux Official Wiki](https://github.com/tmux/tmux/wiki)
- [Tmuxinator GitHub](https://github.com/tmuxinator/tmuxinator)
- [TPM Plugin Manager](https://github.com/tmux-plugins/tpm)
- [Vim-Tmux Navigator](https://github.com/christoomey/vim-tmux-navigator)
- [Tmux Cheat Sheet](https://tmuxcheatsheet.com/)

---

**Configuration Location:** `~/dotfiles/terminal/`
**Files:**
- `tmux.conf` → `~/.tmux.conf`
- `tmuxinator/` → `~/.tmuxinator/`

**Plugin Directory:** `~/.tmux/plugins/`
**Session Saves:** `~/.tmux/resurrect/`
