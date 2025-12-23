# ZSH Vim-like Enhancements - Quick Reference

## 🎉 What's New

Your zsh configuration now has vim-like enhancements matching your Neovim classic mode workflow!

## 📦 Installed Plugins

- **zsh-autopair** - Auto-close brackets and quotes
- **zsh-vi-mode** - Enhanced vi mode with jk/jj escape bindings
- **zsh-syntax-highlighting** - Command syntax highlighting
- **zsh-autosuggestions** - Fish-like autosuggestions

## ⌨️ Key Bindings (Matches Your Neovim Classic Mode)

### Insert Mode

#### Vi Mode
- **jk** or **jj** - Exit insert mode (enter normal mode)

#### Fuzzy Finding (Telescope-like)
- **Ctrl-P** - Find git files (like Telescope find_files)
- **Ctrl-F** - Live grep with preview (matches `,f` in nvim)

#### Text Manipulation
- **Ctrl-L** - Insert `=>` (fat arrow, matches nvim classic)
- **Ctrl-K** - Clear entire line

#### Clipboard
- **Ctrl-Y Y** - Yank (copy) current command
- **Ctrl-V** - Paste from clipboard

#### Command Palette
- **Ctrl-X Ctrl-P** - Open command palette (like nvim `:Commands`)

#### History
- **Ctrl-N** - Next in history
- **Ctrl-R** - Fuzzy history search (FZF)

#### Auto-suggestions
- **Ctrl-Space** - Accept suggestion

### Normal Mode (Press Esc or jk to enter)

#### Git Operations (vim-style)
- **gb** - Fuzzy git branch checkout
- **gl** - Browse git log with preview
- **gs** - Interactive git status/staging

#### Navigation & Search
- **/** - Search history forward
- **?** - Search history backward
- **Y** - Yank (copy) current directory path

#### Fuzzy Finding
- **Ctrl-P** - Find git files
- **Ctrl-F** - Live grep

### Completion Menu (Tab menu)

- **h/j/k/l** - Navigate with vim keys
- **Tab** - Traditional menu completion with selection

## 🎯 Key Features

### 1. Git Operations in Normal Mode

Press **Esc** or **jk** to enter normal mode, then:

- **gb** - Fuzzy checkout git branches with preview
- **gl** - Browse git commit history with previews
- **gs** - Interactively stage files with git status

### 2. Git Aliases (omz-git plugin)

Common git aliases available (type and press Enter):

```bash
gst    → git status
gd     → git diff
ga     → git add
gc     → git commit -v
gcmsg  → git commit -m
gco    → git checkout
gp     → git push
gl     → git pull
```

Run `alias | grep git` to see all available aliases.

### 3. Command Palette

Press **Ctrl-X Ctrl-P** to open a searchable command palette with 60+ commands:

- Text manipulation (format JSON, base64 encode/decode, etc.)
- System maintenance (update packages, clean caches)
- Git operations (clean branches, show stats)
- Development (start server, kill port)
- File operations (find large files, broken symlinks)

### 4. Enhanced Vi Mode

- **jk/jj escape bindings** - Quick exit from insert mode
- **Surround text objects** enabled (ys, ds, cs - like nvim-surround)
- **Faster escape** response (100ms vs 400ms)
- **Vi mode indicator** in Starship prompt:
  - `❯` (green) - Insert mode, command succeeded
  - `❯` (red) - Insert mode, command failed
  - `❮` (yellow) - Normal mode

### 5. Auto-pairing

Brackets, quotes, and parens auto-close (like nvim-autopairs):

```bash
echo "[  # Automatically adds closing ]
```

### 6. Enhanced Clipboard Integration

**Functions available:**
- `yank-pwd` / `ypwd` - Copy current directory
- `yank-command-line` - Copy current command
- `clipboard-history` - Browse clipboard history with fzf
- `clipboard-show` - Show clipboard stats
- `copy-file <file>` - Copy file contents

**Aliases:**
- `y` - Copy (pbcopy)
- `p` - Paste (pbpaste)
- `cb` - Show clipboard

### 7. Text Manipulation Widgets

Available commands (bind them to keys if desired):
- `insert-fat-arrow` - Insert ` => `
- `clear-line` - Clear entire line
- `duplicate-line` - Duplicate current line
- `toggle-case` - Toggle character case
- `jump-to-matching-bracket` - Like vim's `%`

## 🚀 How to Activate

### Option 1: Start a new shell
```bash
# Open a new terminal tab/window
```

### Option 2: Reload current shell
```bash
source ~/.zshrc
```

## ✅ Quick Test Checklist

After reloading, test these:

1. **Vi mode**: Type `jk` quickly → Should enter normal mode (yellow `❮` prompt)
2. **Git branches**: In normal mode, type **gb** → Should show fuzzy git branch finder
3. **File finder**: Press **Ctrl-P** → Should show git files with preview
4. **Live grep**: Press **Ctrl-F** → Should open ripgrep search
5. **Auto-pair**: Type `echo "` → Should auto-close quote
6. **Command palette**: Press **Ctrl-X Ctrl-P** → Should show command menu
7. **Clipboard**: Press **Ctrl-Y Y** → Should yank command (check with `pbpaste`)
8. **Git log**: In normal mode, type **gl** → Should show git commit history

## 📚 Documentation

### FZF Functions

All in `~/dotfiles/shell/functions/fzf-enhancements.sh`:
- `fzf-git-files` - Find git-tracked files (Ctrl-P)
- `fzf-ripgrep` - Live grep with preview (Ctrl-F)
- `fzf-git-branch` - Checkout branch (gb in normal mode)
- `fzf-git-log` - Browse commits (gl in normal mode)
- `fzf-git-status` - Stage files interactively (gs in normal mode)
- `fzf-recent-files` - Open recent files
- `fzf-kill` - Kill process with fuzzy finder
- `fzf-man` - Search man pages

### Git Leader Widget

In `~/dotfiles/shell/functions/git-leader.sh`:
- Custom ZLE widget that handles 'g' prefix in normal mode
- Waits for second keypress (b/l/s) and dispatches to git functions

### Command Palette

All in `~/dotfiles/shell/functions/command-palette.sh` (60+ commands)

### Vim Commands

All in `~/dotfiles/shell/functions/vim-commands.sh`:
- Text manipulation widgets
- Case conversion
- Line operations
- Smart navigation

### Clipboard

All in `~/dotfiles/shell/functions/clipboard.sh`:
- Clipboard operations
- History management
- Path yanking

## 🔧 Configuration Files Modified

- `~/dotfiles/shell/zshrc` - Main config (plugins, keybindings)
- `~/dotfiles/config/starship.toml` - Vi mode indicator
- `~/dotfiles/shell/functions/fzf-enhancements.sh` - FZF fuzzy finding functions
- `~/dotfiles/shell/functions/git-leader.sh` - Git prefix widget (gb/gl/gs)
- `~/dotfiles/shell/functions/command-palette.sh` - Command palette
- `~/dotfiles/shell/functions/vim-commands.sh` - Text manipulation widgets
- `~/dotfiles/shell/functions/clipboard.sh` - Clipboard operations

## 🐛 Troubleshooting

### jk not exiting insert mode
```bash
# Check if binding exists
bindkey -M viins | grep jk

# Verify zsh-vi-mode is loaded
echo $ZVM_VI_ESCAPE_BINDKEY  # Should show: jk

# Reload shell
source ~/.zshrc
```

### Git bindings (gb/gl/gs) not working
```bash
# Must be in normal mode first - press Esc or jk
# Check if widget exists
zle -la | grep git-leader

# Check if 'g' is bound in normal mode
bindkey -M vicmd | grep "\"g\""
```

### Keybinding not working
```bash
# Check if function exists
which fzf-git-files

# Check if binding exists
bindkey -M viins | grep fzf-git-files
```

### Auto-pair not working
```bash
# Check if plugin loaded
ls ~/.oh-my-zsh/custom/plugins/zsh-autopair

# Try typing: echo "
# Should auto-close with: echo ""
```

## 💡 Tips

1. **Master normal mode** - Press jk to enter normal mode, then use gb/gl/gs for git operations
2. **Ctrl-P is your friend** - Quick file navigation (works in both modes)
3. **Ctrl-F for searching** - Live grep with preview (works in both modes)
4. **Explore command palette** - Press Ctrl-X Ctrl-P to discover 60+ commands
5. **Git aliases** - Run `alias | grep git` to see omz-git shortcuts (gst, gco, etc.)
6. **hjkl in menus** - Use vim keys in completion menus
7. **Vi mode indicator** - Watch the prompt: `❯` (insert) vs `❮` (normal)
8. **Quick escape** - jk is faster than reaching for Esc key

## 📝 Next Steps

1. Reload your shell: `source ~/.zshrc`
2. Test jk to enter normal mode
3. Try git bindings: **gb**, **gl**, **gs** (in normal mode)
4. Test fuzzy finding: **Ctrl-P**, **Ctrl-F**
5. Explore command palette: **Ctrl-X Ctrl-P**
6. Enjoy your vim-like zsh experience! 🎉

## 🔗 Files

- This guide: `~/dotfiles/shell/VIM_ENHANCEMENTS_README.md`
- Functions: `~/dotfiles/shell/functions/*.sh`
- Config: `~/dotfiles/shell/zshrc`
- Starship: `~/dotfiles/config/starship.toml`
