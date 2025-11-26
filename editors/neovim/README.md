# Neovim Configuration

Modern Neovim configuration with LSP, autocompletion, fuzzy finding, and Git integration using lazy.nvim plugin manager.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Keybindings](#keybindings)
- [Plugins](#plugins)
- [LSP Servers](#lsp-servers)
- [Configuration Files](#configuration-files)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)

---

## Overview

This Neovim configuration is organized into modular Lua files for easy maintenance and customization.

**Leader Key:** `<Space>`

**Structure:**
```
editors/neovim/
├── init.lua                 # Entry point
└── lua/
    ├── config/              # Core configuration
    │   ├── options.lua      # Editor options
    │   ├── keymaps.lua      # Key bindings
    │   ├── autocmds.lua     # Auto commands
    │   ├── lazy.lua         # Plugin manager bootstrap
    │   └── commands.lua     # Custom commands
    └── plugins/             # Plugin configurations
        ├── lsp.lua          # LSP, completion, formatting
        ├── telescope.lua    # Fuzzy finder
        ├── treesitter.lua   # Syntax highlighting
        ├── ui.lua           # UI enhancements
        ├── editor.lua       # Editor plugins
        ├── git.lua          # Git integration
        └── misc.lua         # Miscellaneous plugins
```

---

## Features

### Core Features
- ✅ **LSP Support** - Language servers for multiple languages
- ✅ **Autocompletion** - Intelligent code completion with nvim-cmp
- ✅ **Fuzzy Finding** - Fast file/text search with Telescope
- ✅ **Syntax Highlighting** - Treesitter-based parsing
- ✅ **Git Integration** - Fugitive, signs, and blame
- ✅ **Formatting** - Automatic code formatting on save
- ✅ **Linting** - Real-time error detection
- ✅ **Snippets** - Code snippets with LuaSnip

### Editor Enhancements
- Line numbers (absolute + relative)
- System clipboard integration
- Mouse support
- Persistent undo
- Smart indentation (2 spaces)
- Fast update time (300ms)
- No swap files

---

## Installation

### Prerequisites

```bash
# Install Neovim (0.9+ required)
brew install neovim

# Install required tools
brew install ripgrep  # For Telescope live_grep
brew install fd       # For Telescope find_files
```

### Setup

The configuration is symlinked automatically by the dotfiles install script:

```bash
cd ~/dotfiles
./scripts/install.sh
```

Manual symlink:
```bash
ln -s ~/dotfiles/editors/neovim ~/.config/nvim
```

### First Launch

On first launch, lazy.nvim will automatically:
1. Install itself
2. Install all plugins
3. Download LSP servers (via Mason)

This may take a few minutes.

---

## Keybindings

### Leader Key

The leader key is `<Space>`. Press `<Space>` followed by another key for custom commands.

### Core Bindings

| Keybinding | Mode | Action |
|------------|------|--------|
| `jk` | Insert | Exit insert mode (alternative to `<Esc>`) |
| `<Space>w` | Normal | Save file |
| `<Space>q` | Normal | Quit |
| `<Space>Q` | Normal | Quit all without saving |
| `<Space>h` | Normal | Clear search highlighting |

### Window Navigation

| Keybinding | Mode | Action |
|------------|------|--------|
| `<C-h>` | Normal | Move to left window |
| `<C-j>` | Normal | Move to window below |
| `<C-k>` | Normal | Move to window above |
| `<C-l>` | Normal | Move to right window |

### Window Management

| Keybinding | Mode | Action |
|------------|------|--------|
| `<Space>sv` | Normal | Split window vertically |
| `<Space>sh` | Normal | Split window horizontally |
| `<C-Up>` | Normal | Decrease window height |
| `<C-Down>` | Normal | Increase window height |
| `<C-Left>` | Normal | Decrease window width |
| `<C-Right>` | Normal | Increase window width |

### Buffer Navigation

| Keybinding | Mode | Action |
|------------|------|--------|
| `<S-l>` | Normal | Next buffer |
| `<S-h>` | Normal | Previous buffer |
| `<Space>bd` | Normal | Delete buffer |

### File Explorer

| Keybinding | Mode | Action |
|------------|------|--------|
| `<Space>e` | Normal | Toggle NvimTree file explorer |

### Telescope (Fuzzy Finder)

| Keybinding | Mode | Action |
|------------|------|--------|
| `<Space>ff` | Normal | Find files |
| `<Space>fg` | Normal | Live grep (search in files) |
| `<Space>fb` | Normal | Find buffers |
| `<Space>fh` | Normal | Find help tags |
| `<Space>fr` | Normal | Recent files |
| `<Space>fc` | Normal | Git commits |
| `<Space>fs` | Normal | Git status |

### LSP (Language Server Protocol)

These keybindings are available when an LSP server is attached:

| Keybinding | Mode | Action |
|------------|------|--------|
| `gD` | Normal | Go to declaration |
| `gd` | Normal | Go to definition |
| `gi` | Normal | Go to implementation |
| `gr` | Normal | Go to references |
| `K` | Normal | Hover documentation |
| `<C-k>` | Normal | Signature help |
| `<Space>D` | Normal | Type definition |
| `<Space>rn` | Normal | Rename symbol |
| `<Space>ca` | Normal | Code action |
| `<Space>f` | Normal | Format document |

### Diagnostics

| Keybinding | Mode | Action |
|------------|------|--------|
| `[d` | Normal | Go to previous diagnostic |
| `]d` | Normal | Go to next diagnostic |
| `<Space>d` | Normal | Show diagnostic in floating window |
| `<Space>dl` | Normal | Show diagnostics in location list |

### Code Editing

| Keybinding | Mode | Action |
|------------|------|--------|
| `<` | Visual | Decrease indent (keeps selection) |
| `>` | Visual | Increase indent (keeps selection) |
| `<A-j>` | Normal/Visual | Move line/selection down |
| `<A-k>` | Normal/Visual | Move line/selection up |
| `p` | Visual | Paste without yanking replaced text |

### Autocompletion

| Keybinding | Mode | Action |
|------------|------|--------|
| `<C-Space>` | Insert | Trigger completion |
| `<CR>` | Insert | Confirm completion |
| `<C-e>` | Insert | Abort completion |
| `<Tab>` | Insert | Next completion item / Expand snippet |
| `<S-Tab>` | Insert | Previous completion item / Jump back |
| `<C-b>` | Insert | Scroll docs up |
| `<C-f>` | Insert | Scroll docs down |

### Terminal

| Keybinding | Mode | Action |
|------------|------|--------|
| `<Space>tt` | Normal | Open terminal |
| `<Esc>` | Terminal | Exit terminal mode |

---

## Plugins

### Plugin Manager

**lazy.nvim** - Fast and modern plugin manager
- Auto-installs on first run
- Lazy-loads plugins for performance
- Lockfile for reproducible installs

### LSP & Completion

| Plugin | Purpose |
|--------|---------|
| **mason.nvim** | LSP server installer |
| **mason-lspconfig.nvim** | Bridge between mason and lspconfig |
| **nvim-lspconfig** | LSP configuration |
| **nvim-cmp** | Autocompletion engine |
| **cmp-nvim-lsp** | LSP completion source |
| **cmp-buffer** | Buffer completion source |
| **cmp-path** | Path completion source |
| **cmp_luasnip** | Snippet completion source |
| **LuaSnip** | Snippet engine |
| **friendly-snippets** | Pre-made snippets |
| **conform.nvim** | Formatting plugin |
| **nvim-lint** | Linting plugin |

### Fuzzy Finding & Navigation

| Plugin | Purpose |
|--------|---------|
| **telescope.nvim** | Fuzzy finder for files, buffers, grep |
| **plenary.nvim** | Lua utility functions (telescope dependency) |

### Syntax & Highlighting

| Plugin | Purpose |
|--------|---------|
| **nvim-treesitter** | Advanced syntax highlighting |

### UI Enhancements

| Plugin | Purpose |
|--------|---------|
| **nvim-tree.lua** | File explorer |
| **lualine.nvim** | Status line |
| **bufferline.nvim** | Buffer/tab line |
| **indent-blankline.nvim** | Indentation guides |
| **nvim-notify** | Notification manager |

### Git Integration

| Plugin | Purpose |
|--------|---------|
| **vim-fugitive** | Git commands in Neovim |
| **gitsigns.nvim** | Git diff signs in gutter |

### Editor Utilities

| Plugin | Purpose |
|--------|---------|
| **nvim-autopairs** | Auto-close brackets/quotes |
| **Comment.nvim** | Easy commenting (`gcc`, `gbc`) |
| **nvim-surround** | Surround text objects |
| **vim-repeat** | Repeat plugin actions with `.` |

---

## LSP Servers

### Auto-Installed Servers

These LSP servers are automatically installed via Mason:

| Language | Server | Configuration |
|----------|--------|---------------|
| **Lua** | `lua_ls` | Neovim-aware, diagnostics for `vim` global |
| **TypeScript** | `ts_ls` | Inlay hints enabled |
| **Python** | `pyright` | Type checking and completion |

### Available Servers

Additional servers configured but not auto-installed:

| Language | Server |
|----------|--------|
| **JavaScript** | `eslint` |
| **JSON** | `jsonls` |
| **HTML** | `html` |
| **CSS** | `cssls` |
| **Tailwind** | `tailwindcss` |
| **Bash** | `bashls` |
| **YAML** | `yamlls` |
| **Vue** | `volar` |

### Installing Additional Servers

```vim
:Mason
```

Browse and install servers with `i` (install) or `X` (uninstall).

### Manual Installation

```bash
# Example: Install specific LSP servers
npm install -g typescript typescript-language-server
npm install -g vscode-langservers-extracted  # HTML, CSS, JSON
npm install -g bash-language-server
```

---

## Configuration Files

### config/options.lua

**Editor settings configured:**

| Option | Value | Purpose |
|--------|-------|---------|
| `mouse` | `"a"` | Enable mouse in all modes |
| `clipboard` | `"unnamedplus"` | Use system clipboard |
| `number` | `true` | Show line numbers |
| `relativenumber` | `true` | Relative line numbers (for navigation) |
| `expandtab` | `true` | Use spaces instead of tabs |
| `shiftwidth` | `2` | Indent size |
| `tabstop` | `2` | Tab display size |
| `ignorecase` | `true` | Case-insensitive search |
| `smartcase` | `true` | Case-sensitive if uppercase in search |
| `updatetime` | `300` | Faster completion (ms) |
| `timeoutlen` | `400` | Faster key sequences (ms) |
| `cursorline` | `true` | Highlight current line |
| `signcolumn` | `"yes"` | Always show sign column (for git/LSP) |
| `scrolloff` | `8` | Keep 8 lines above/below cursor |
| `undofile` | `true` | Persistent undo |
| `swapfile` | `false` | Disable swap files |

### config/keymaps.lua

All keybindings are defined here. See [Keybindings](#keybindings) section for complete reference.

### config/autocmds.lua

Auto commands for file-specific settings and behaviors.

### plugins/*.lua

Each plugin category has its own configuration file:
- **lsp.lua** - Language servers, completion, formatting, linting
- **telescope.lua** - Fuzzy finder configuration
- **treesitter.lua** - Syntax highlighting
- **ui.lua** - UI plugins (statusline, tree, bufferline)
- **editor.lua** - Editor enhancement plugins
- **git.lua** - Git integration
- **misc.lua** - Utility plugins

---

## Customization

### Adding a New LSP Server

1. Open Mason:
   ```vim
   :Mason
   ```

2. Find and install the server (press `i`)

3. Add to auto-install list in `lua/plugins/lsp.lua`:
   ```lua
   ensure_installed = {
     "lua_ls",
     "ts_ls",
     "pyright",
     "your_new_server",  -- Add here
   },
   ```

4. Add server configuration if needed:
   ```lua
   servers = {
     your_new_server = {
       settings = {
         -- Server-specific settings
       },
     },
   }
   ```

### Changing Leader Key

Edit `lua/config/keymaps.lua`:
```lua
vim.g.mapleader = ","  -- Change to comma
```

### Adding Custom Keybindings

Add to `lua/config/keymaps.lua`:
```lua
keymap.set("n", "<leader>x", ":YourCommand<CR>", opts)
```

### Installing Additional Plugins

Add to the appropriate `lua/plugins/*.lua` file:
```lua
return {
  {
    "author/plugin-name",
    config = function()
      -- Plugin configuration
    end,
  },
}
```

Then restart Neovim or run `:Lazy sync`.

---

## Troubleshooting

### Plugins Not Installing

```vim
:Lazy
```

Press `U` to update, `S` to sync, or `I` to install.

### LSP Not Working

1. Check if server is installed:
   ```vim
   :Mason
   ```

2. Check LSP status:
   ```vim
   :LspInfo
   ```

3. Check for errors:
   ```vim
   :checkhealth
   ```

### Completion Not Showing

1. Verify nvim-cmp is loaded:
   ```vim
   :Lazy
   ```

2. Check LSP is attached:
   ```vim
   :LspInfo
   ```

3. Try triggering manually:
   - Insert mode: `<C-Space>`

### Formatting Not Working

1. Check if formatter is installed:
   ```vim
   :ConformInfo
   ```

2. Install formatter manually:
   ```bash
   npm install -g prettier
   brew install stylua
   ```

### Treesitter Errors

Update parsers:
```vim
:TSUpdate
```

### Reset Configuration

If something breaks:
```bash
# Backup first
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak

# Restart Neovim - plugins will reinstall
nvim
```

---

## Useful Commands

### Lazy.nvim

| Command | Action |
|---------|--------|
| `:Lazy` | Open plugin manager |
| `:Lazy sync` | Update all plugins |
| `:Lazy clean` | Remove unused plugins |
| `:Lazy profile` | Show plugin load times |

### Mason

| Command | Action |
|---------|--------|
| `:Mason` | Open LSP installer |
| `:MasonUpdate` | Update Mason itself |
| `:MasonLog` | View installation logs |

### LSP

| Command | Action |
|---------|--------|
| `:LspInfo` | Show attached LSP clients |
| `:LspStart` | Start LSP manually |
| `:LspRestart` | Restart LSP server |

### Treesitter

| Command | Action |
|---------|--------|
| `:TSUpdate` | Update all parsers |
| `:TSInstall <lang>` | Install parser for language |

---

## Performance Tips

1. **Lazy Loading** - Most plugins are lazy-loaded automatically
2. **Fast Update Time** - Set to 300ms for responsive LSP
3. **Disabled Providers** - Perl and Ruby providers disabled
4. **Persistent Undo** - Undo history saved between sessions
5. **No Swap Files** - Faster file operations

---

## Additional Resources

- [Neovim Documentation](https://neovim.io/doc/)
- [lazy.nvim GitHub](https://github.com/folke/lazy.nvim)
- [Mason.nvim GitHub](https://github.com/williamboman/mason.nvim)
- [nvim-lspconfig Server Configurations](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md)

---

## Quick Reference Card

### Essential Commands
```
<Space>w        Save file
<Space>q        Quit
<Space>ff       Find files
<Space>fg       Search in files
<Space>e        File explorer
jk              Exit insert mode
<Space>ca       Code actions
<Space>f        Format code
gd              Go to definition
K               Hover documentation
```

### Most Used Telescope
```
<Space>ff       Files in project
<Space>fg       Grep in files
<Space>fb       Open buffers
<Space>fr       Recent files
<Space>fc       Git commits
```

### Daily Workflow
1. `<Space>e` - Open file tree
2. `<Space>ff` - Quick file find
3. `gd` - Jump to definition
4. `<Space>ca` - Fix issues
5. `<Space>f` - Format on save

---

**Configuration Location:** `~/dotfiles/editors/neovim/`
**Symlinked To:** `~/.config/nvim/`
**Plugin Data:** `~/.local/share/nvim/`
**Plugin Lockfile:** `~/.config/nvim/lazy-lock.json`
