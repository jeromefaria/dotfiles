# ZSH Vim-like Enhancements - Quick Reference

## 🎉 What's New

Your zsh configuration now has comprehensive vim-like enhancements matching your Neovim classic mode workflow!

## 📦 Installed Plugins

- **fzf-tab** - Fuzzy tab completion (like Telescope)
- **zsh-abbr** - Git abbreviations that expand
- **zsh-autopair** - Auto-close brackets and quotes

## ⌨️ Key Bindings (Matches Your Neovim Classic Mode)

### Insert Mode

#### Fuzzy Finding (Telescope-like)
- **Ctrl-P** - Find git files (like Telescope find_files)
- **Ctrl-F** - Live grep with preview (matches `,f` in nvim)
- **Ctrl-G B** - Fuzzy git branch checkout
- **Ctrl-G L** - Browse git log
- **Ctrl-G S** - Interactive git status/staging

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
- **Ctrl-P** - Previous in history
- **Ctrl-R** - Fuzzy history search (enhanced)

#### Auto-suggestions
- **Ctrl-Space** - Accept suggestion (existing)

### Normal Mode

- **/** - Search history forward
- **?** - Search history backward
- **Y** - Yank (copy) current directory path

### Completion Menu (Tab menu)

- **h/j/k/l** - Navigate with vim keys
- **Ctrl-N** - Next item
- **Ctrl-P** - Previous item
- **Tab** - Opens fuzzy finder for completions!

## 🎯 New Features

### 1. Fuzzy Tab Completion (fzf-tab)

Tab now opens a fuzzy finder instead of traditional menu:

```bash
cd ~/Do[TAB]  # Opens fuzzy finder with directory preview
git checkout [TAB]  # Fuzzy search branches
```

### 2. Git Abbreviations (expand on space)

Type abbreviation + space to expand:

```bash
gs → git status
gd → git diff
ga → git add
gc → git commit -v
gcm → git commit -m
gco → git checkout
gp → git push
gpl → git pull
```

Run `abbr` to see all available abbreviations.

### 3. Command Palette

Press **Ctrl-X Ctrl-P** to open a searchable command palette with 60+ commands:

- Text manipulation (format JSON, base64 encode/decode, etc.)
- System maintenance (update packages, clean caches)
- Git operations (clean branches, show stats)
- Development (start server, kill port)
- File operations (find large files, broken symlinks)

### 4. Enhanced Vi Mode

- **Surround text objects** enabled (ys, ds, cs - like nvim-surround)
- **Faster escape** response (100ms vs 400ms)
- **Vi mode indicator** in prompt:
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

1. **Tab completion**: Type `cd ~/` and press **Tab** → Should show fuzzy finder
2. **File finder**: Press **Ctrl-P** → Should show git files
3. **Live grep**: Press **Ctrl-F** → Should open grep search
4. **Git abbreviation**: Type `gs ` (with space) → Should expand to `git status`
5. **Auto-pair**: Type `echo "` → Should auto-close quote
6. **Vi mode indicator**: Press **Escape** or **jk** → Prompt should change to yellow `❮`
7. **Command palette**: Press **Ctrl-X Ctrl-P** → Should show command menu
8. **Clipboard**: Press **Ctrl-Y Y** → Should yank command (check with `pbpaste`)

## 📚 Documentation

### FZF Functions

All in `~/dotfiles/shell/functions/fzf-enhancements.sh`:
- `fzf-git-files` - Find git-tracked files
- `fzf-ripgrep` - Live grep with preview
- `fzf-git-branch` - Checkout branch
- `fzf-git-log` - Browse commits
- `fzf-git-status` - Stage files interactively
- `fzf-recent-files` - Open recent files
- `fzf-kill` - Kill process with fuzzy finder
- `fzf-man` - Search man pages

### Git Abbreviations

All in `~/dotfiles/shell/functions/git-abbr.sh` (60+ abbreviations)

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
- `~/dotfiles/shell/functions/*.sh` - 5 new function files

## 🐛 Troubleshooting

### Tab completion not working
```bash
# Reload completions
rm ~/.zcompdump*
source ~/.zshrc
```

### Keybinding not working
```bash
# Check if function exists
which fzf-git-files

# Check if binding exists
bindkey | grep fzf-git-files
```

### Git abbreviations not expanding
```bash
# Check if abbr is loaded
abbr

# If empty, check plugin installation
ls ~/.oh-my-zsh/custom/plugins/zsh-abbr
```

### Auto-pair not working
```bash
# Check if plugin loaded
ls ~/.oh-my-zsh/custom/plugins/zsh-autopair

# Try typing: echo "
# Should auto-close with: echo ""
```

## 💡 Tips

1. **Use Tab everywhere** - fzf-tab makes all completions fuzzy
2. **Ctrl-P is your friend** - Quick file navigation
3. **Ctrl-F for searching** - Live grep with preview
4. **Explore command palette** - Press Ctrl-X Ctrl-P to discover commands
5. **Git abbreviations** - Run `abbr` to see all available shortcuts
6. **hjkl in menus** - Use vim keys in completion menus
7. **Vi mode indicator** - Watch the prompt symbol to know your mode

## 📝 Next Steps

1. Reload your shell: `source ~/.zshrc`
2. Try the key bindings above
3. Explore command palette: **Ctrl-X Ctrl-P**
4. Check git abbreviations: `abbr`
5. Enjoy your vim-like zsh experience! 🎉

## 🔗 Related Files

- Plan: `~/.claude/plans/rustling-jumping-biscuit.md`
- This guide: `~/dotfiles/shell/VIM_ENHANCEMENTS_README.md`
- Functions: `~/dotfiles/shell/functions/*.sh`
- Config: `~/dotfiles/shell/zshrc`
- Starship: `~/dotfiles/config/starship.toml`
