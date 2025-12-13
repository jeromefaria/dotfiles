# Vim and Neovim Configuration Review Summary

## Overview

Your dotfiles have been successfully decoupled into two independent configurations:
- **Vim** (8.0+): Uses vim-plug with COC.nvim at `~/.vim/`
- **Neovim**: Uses lazy.nvim with native LSP at `~/.config/nvim/`

---

## Neovim Dual Keymap System

Neovim now supports **two switchable keymap modes** to ease the transition from the original vim-plug configuration:

### Available Modes

| Mode | Leader Key | Description |
|------|------------|-------------|
| **Classic** | `,` (comma) | Original vim-plug era keybindings |
| **Modern** | `<Space>` | Current lazy.nvim keybindings |

### Switching Between Modes

**Commands:**
- `:ClassicMode` - Switch to classic keymaps
- `:ModernMode` - Switch to modern keymaps
- `:KeymapMode` - Show current mode info
- `:KeymapToggle` - Toggle between modes
- `:KeymapSave [mode]` - Save preference for future sessions
- `:KeymapClearPreference` - Clear saved preference (will prompt on next startup)

**Startup Behavior:**
1. If you have a saved preference, it loads automatically
2. If no preference saved, you'll see a prompt to choose
3. You can save your choice to skip the prompt next time

### Quick Comparison

| Action | Classic (`,` leader) | Modern (`<Space>` leader) |
|--------|---------------------|---------------------------|
| Find files | `,t` or `Ctrl-P` | `<Space>ff` |
| Live grep | `,f` | `<Space>fg` |
| Buffers | `,b` | `<Space>fb` |
| File tree | `,m` | `<Space>e` |
| Delete buffer | `,d` | `<Space>bd` |
| Clear search | `,<space>` | `<Space>h` |
| Git status | `,gs` | `<Space>gs` |
| Indent | `Tab`/`S-Tab` | `<`/`>` |
| Tab/Buffer nav | `H`/`L` (tabs) | `S-h`/`S-l` (buffers) |
| Undo tree | `F5` | `<Space>u` |
| Search | `<Space>` → `/` | Normal `/` |

### Configuration Files

```
lua/config/
├── keymap-mode.lua      # Mode switching logic
├── keymap-selector.lua  # Startup prompt handler
├── keymaps-classic.lua  # Classic (comma leader) keymaps
└── keymaps-modern.lua   # Modern (space leader) keymaps
```

### Preference Storage

Your keymap preference is stored at `~/.config/nvim/keymap-mode`

---

## Leader Key Reference

- **Vim**: `,` (comma) - always
- **Neovim Classic Mode**: `,` (comma)
- **Neovim Modern Mode**: `<Space>` (spacebar)

---

## Key Mapping Changes

### File Navigation & Search

| Action | Vim | Neovim |
|--------|-----|--------|
| **Find Files** | `<leader>t` (FZF) | `<leader>ff` (Telescope) |
| **Live Grep** | `<leader>f` (Rg) | `<leader>fg` (Telescope) |
| **Search in Buffer** | `<leader>l` (BLines) | `<leader>f/` (Telescope) |
| **File Explorer** | `<leader>m` (NERDTree) | `<leader>e` (NvimTree) |
| **Recent Files** | N/A | `<leader>fr` (Telescope) |

### Buffer Management

| Action | Vim | Neovim |
|--------|-----|--------|
| **List Buffers** | `<leader>b` | `<leader>fb` |
| **Delete Buffer** | `<leader>d` | `<leader>bd` |
| **Next Buffer** | `L` (next tab) | `<S-l>` (next buffer) |
| **Prev Buffer** | `H` (prev tab) | `<S-h>` (prev buffer) |

**Note**: Neovim uses buffers instead of tabs for navigation.

### Window Management

| Action | Vim | Neovim |
|--------|-----|--------|
| **Navigate Windows** | Commented out | `<C-h/j/k/l>` |
| **Resize Windows** | N/A | `<C-Up/Down/Left/Right>` |
| **Split Vertical** | N/A | `<leader>sv` |
| **Split Horizontal** | N/A | `<leader>sh` |

### Git Operations

| Action | Vim | Neovim |
|--------|-----|--------|
| **Git Status** | `<leader>gs` | `<leader>gs` |
| **LazyGit** | N/A | `<leader>gg` |
| **Git Commits** | N/A | `<leader>fc` (Telescope) |
| **Stage Hunk** | N/A | `<leader>hs` |
| **Preview Hunk** | N/A | `<leader>hp` |
| **Blame Line** | N/A | `<leader>hb` |
| **Next Hunk** | N/A | `]h` |
| **Prev Hunk** | N/A | `[h` |

### Insert Mode

| Action | Vim | Neovim Classic | Neovim Modern |
|--------|-----|----------------|---------------|
| **Escape** | `jk` | `jk` | Default `Esc` |
| **Arrow Function** | `<C-l>` → ` => ` | `<C-l>` → ` => ` | Not mapped |
| **Save** | `<C-s>` | `<C-s>` | Not mapped |

### LSP Operations (Neovim Only)

| Mapping | Action |
|---------|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Go to references |
| `K` | Hover documentation |
| `<C-k>` | Signature help |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code actions |
| `<leader>f` | Format code |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<leader>d` | Show diagnostic float |

### Other Notable Mappings

| Action | Vim | Neovim |
|--------|-----|--------|
| **Save File** | `<leader>w` | `<leader>w` |
| **Quit** | N/A | `<leader>q` |
| **Clear Highlight** | `<leader><space>` | `<leader>h` |
| **Undo Tree** | `<F5>` (Gundo) | `<leader>u` (Undotree) |
| **Move Lines Up/Down** | `<A-j>` / `<A-k>` | `<A-j>` / `<A-k>` (same) |
| **Indent/Outdent** | `<Tab>` / `<S-Tab>` | Visual mode only |
| **Terminal** | N/A | `<leader>tt` |
| **Esc in Terminal** | N/A | `<Esc>` |

---

## Plugin Changes

### Completion & LSP

**Vim:**
- COC.nvim (Language Server Protocol client)
- COC extensions: tsserver, json, html, css, eslint, prettier

**Neovim:**
- Native LSP (`nvim-lspconfig`)
- Mason (LSP/tool installer)
- `nvim-cmp` (completion)
- LuaSnip (snippets)
- Conform (formatting)
- nvim-lint (linting)

**Impact**: Neovim uses native LSP which is faster and more integrated. Configuration is more explicit but more flexible.

### Fuzzy Finding

**Vim:** FZF + fzf.vim
**Neovim:** Telescope.nvim

**Impact**: Telescope is more feature-rich with better integration, preview windows, and extensibility.

### File Explorer

**Vim:** NERDTree
**Neovim:** NvimTree

**Impact**: Similar functionality, NvimTree is Lua-native and faster in Neovim.

### Status Line

**Vim:** Airline + airline-themes
**Neovim:** Lualine.nvim

**Impact**: Lualine is lighter and faster, similar appearance.

### Git Integration

**Vim:**
- vim-fugitive
- vim-gitgutter

**Neovim:**
- vim-fugitive (same)
- gitsigns.nvim (replaces gitgutter)
- lazygit.nvim (NEW)

**Impact**: Gitsigns offers more features and better performance. LazyGit provides a full TUI git client within Neovim.

### Easy Motion

**Vim:** vim-easymotion
**Neovim:** flash.nvim

**Keys Changed:**
- Flash uses `s` and `S` instead of easymotion's default leader-based motions

### Commenting

**Vim:** NERDCommenter
**Neovim:** Comment.nvim

**Keys:**
- `gcc` - Toggle comment on current line
- `gc` - Toggle comment (linewise)
- `gb` - Toggle comment (blockwise)

### UI Enhancements

**New in Neovim:**
- **Alpha** - Dashboard on startup
- **Bufferline** - Visual buffer tabs at top
- **Which-key** - Popup showing available keybindings
- **Dressing** - Better UI for inputs/selects
- **Notify** - Notification system
- **indent-blankline** - Indent guides
- **nvim-colorizer** - Highlight color codes

### Syntax & Parsing

**Vim:** Individual syntax plugins for each language
**Neovim:** TreeSitter (unified syntax highlighting for all languages)

**Impact**: TreeSitter provides better, more consistent syntax highlighting and enables advanced features like better text objects.

### Removed from Neovim

These plugins were in Vim but not migrated to Neovim:
- **Writing plugins**: Goyo, Limelight, vim-pencil, vim-iawriter
- **Session management**: vim-session, restore_view.vim (replaced by persistence.nvim)
- **Outline viewer**: VOoM
- **File navigation**: vim-vinegar
- **Undo**: Gundo (replaced by undotree)
- **Language-specific**: vim-processing, vim-node
- **Most syntax plugins** (replaced by TreeSitter)

### New Features in Neovim

- **Trouble.nvim** - Better diagnostics/quickfix viewer (`<leader>xx`)
- **Todo-comments** - Highlight and search TODO comments (`<leader>ft`)
- **Better quickfix** - nvim-bqf for enhanced quickfix window
- **Session management** - persistence.nvim (`<leader>qs`)

---

## Configuration Structure

### Vim
```
vimrc
└── vim/
    ├── plugins.vim (vim-plug)
    ├── general.vim
    ├── mappings.vim
    ├── colours.vim
    ├── status.vim
    ├── autocmd.vim
    ├── functions.vim
    ├── commands.vim
    └── misc.vim
```

### Neovim
```
editors/neovim/init.lua
└── lua/
    ├── config/
    │   ├── options.lua
    │   ├── keymap-mode.lua      # Mode switching logic
    │   ├── keymap-selector.lua  # Startup prompt
    │   ├── keymaps-classic.lua  # Classic keymaps (comma leader)
    │   ├── keymaps-modern.lua   # Modern keymaps (space leader)
    │   ├── commands.lua
    │   ├── lazy.lua
    │   └── autocmds.lua
    └── plugins/
        ├── lsp.lua
        ├── editor.lua
        ├── ui.lua
        ├── git.lua
        ├── telescope.lua
        ├── treesitter.lua
        └── misc.lua
```

---

## Options Differences

### Neovim-Specific Settings
- `relativenumber = true` - Relative line numbers (Vim doesn't have this by default)
- `termguicolors = true` - 24-bit RGB colors
- `clipboard = "unnamedplus"` - Always use system clipboard
- `undofile = true` - Persistent undo
- `scrolloff = 8` - Keep 8 lines visible above/below cursor

---

## Migration Notes

### If switching from Vim to Neovim:

1. **Use Classic Mode first** (recommended):
   - Run `:ClassicMode` or choose "Classic" at startup
   - This preserves your muscle memory with comma leader and original keybindings
   - Gradually learn modern bindings, then switch with `:ModernMode`
   - Save your preference with `:KeymapSave`

2. **Or adapt to Modern Mode**:
   - Leader key: `,` → `<Space>`
   - File search: `,t` → `<Space>ff`
   - Grep: `,f` → `<Space>fg`
   - File tree: `,m` → `<Space>e`
   - Buffers: Use `Shift-h/l` instead of `H/L`

3. **Classic Mode includes `jk` to escape** - Modern mode uses default `Esc`

4. **New features to learn** (available in both modes):
   - LSP commands (`gd`, `K`, `<leader>ca`, etc.)
   - Telescope is more powerful than FZF
   - Which-key will help discover keybindings
   - LazyGit integration (`<leader>gg` in modern, `,gg` in classic)

5. **Plugin management**:
   - Use `:Lazy` instead of `:PlugInstall`
   - Use `:Mason` to manage LSP servers and tools

---

## Summary of Significant Changes

### Most Impactful
1. **Dual keymap system** - Switch between Classic (`,` leader) and Modern (`<Space>` leader)
2. **All fuzzy finding moved from FZF to Telescope** (same keys in Classic mode)
3. **COC.nvim replaced with native LSP** (different completion behavior)
4. **Classic mode preserves `jk` escape** - Modern mode uses default `Esc`
5. **Buffer navigation** - Classic uses `H/L` for tabs, Modern uses `Shift-H/L` for buffers

### New Capabilities
1. **Dual keymap modes** - Use `:ClassicMode` or `:ModernMode` to switch
2. **Native LSP support** with go-to-definition, hover, rename, etc.
3. **TreeSitter** for better syntax highlighting
4. **LazyGit integration** for visual git operations
5. **Which-key** to discover keybindings
6. **Better diagnostics** with Trouble.nvim
7. **Dashboard** on startup

### Classic Mode Preserves
- Comma (`,`) as leader key
- `jk` to escape insert mode
- `<C-l>` for fat arrow (` => `)
- `<C-s>` to save
- Tab/S-Tab for indenting
- Original FZF-style keybindings (mapped to Telescope)

### Removed from Modern Mode
- Writing-focused plugins (Goyo, Limelight, etc.)
- Some language-specific plugins (now handled by LSP + TreeSitter)

---

## Quick Reference Card

### Keymap Mode Commands
- `:ClassicMode` - Switch to classic keymaps (comma leader)
- `:ModernMode` - Switch to modern keymaps (space leader)
- `:KeymapMode` - Show current mode
- `:KeymapToggle` - Toggle between modes
- `:KeymapSave` - Save current mode as preference

### Essential Keybindings (Both Modes)

| Action | Classic (`,`) | Modern (`<Space>`) |
|--------|---------------|-------------------|
| **Find files** | `,t` or `Ctrl-P` | `<Space>ff` |
| **Live grep** | `,f` | `<Space>fg` |
| **Buffers** | `,b` | `<Space>fb` |
| **File explorer** | `,m` | `<Space>e` |
| **Save file** | `,w` or `Ctrl-s` | `<Space>w` |
| **Delete buffer** | `,d` | `<Space>bd` |
| **Clear highlight** | `,<space>` | `<Space>h` |
| **Git status** | `,gs` | `<Space>gs` |
| **Undo tree** | `F5` | `<Space>u` |

### Code Navigation (LSP) - Same in Both Modes
- `gd` - Go to definition
- `gr` - Find references
- `K` - Show documentation
- `<leader>ca` - Code actions
- `<leader>rn` - Rename symbol

### Git (Same in Both Modes)
- `<leader>hp` - Preview hunk
- `]h` / `[h` - Next/prev hunk

### Diagnostics (Same in Both Modes)
- `]d` / `[d` - Next/prev diagnostic

### Classic Mode Exclusive
- `jk` - Escape insert mode
- `<C-l>` - Insert ` => ` (fat arrow)
- `<C-s>` - Save file
- `Tab` / `S-Tab` - Indent/dedent
- `H` / `L` - Previous/next tab
- `<Space>` - Search (maps to `/`)
