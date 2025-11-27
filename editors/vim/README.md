# Vim Configuration

This directory contains Vim configuration files using vim-plug as the plugin manager.

## Structure

```
vim/
├── vimrc              # Main config (auto-detects portable mode)
├── vimrc.portable     # Portable config for restricted environments
├── plugins.vim        # Plugin definitions
├── general.vim        # General editor settings
├── mappings.vim       # Key mappings
├── colours.vim        # Syntax highlighting customization
├── status.vim         # Status line configuration
├── autocmd.vim        # Autocommands
├── functions.vim      # Custom Vim functions
├── commands.vim       # Custom commands
└── misc.vim           # Plugin-specific settings
```

## Configurations

### Main Configuration (`vimrc`)

The full-featured configuration for macOS/Linux with all tools available:
- CoC.nvim for LSP support
- FZF for fuzzy finding
- Full plugin suite (40+ plugins)

### Portable Configuration (`vimrc.portable`)

Designed for restricted environments (e.g., Git Bash on Windows):
- No external CLI tool dependencies (no fzf, ripgrep, etc.)
- Node.js/npm support when available (enables CoC)
- Only requires vim-plug (auto-installs via curl)

---

## Portable Configuration

### Installation

```bash
# 1. Install vim-plug (Git Bash has curl)
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# 2. Link the portable config
ln -s ~/dotfiles/editors/vim/vimrc.portable ~/.vimrc

# 3. Open vim and install plugins
vim +PlugInstall +qall
```

### Features by Node.js Availability

| Feature | Node.js Available | No Node.js |
|---------|-------------------|------------|
| Autocompletion | CoC.nvim (LSP) | None |
| Go to Definition | Yes (`gd`) | No |
| Diagnostics | Yes (ESLint) | No |
| Formatting | Prettier on save | Manual only |
| Snippets | CoC snippets | No |
| JSON formatting | Node.js | Python fallback |

### Startup Message

```
Portable Vim loaded | Platform: windows | Node.js: yes (CoC enabled)
```

---

## Key Mappings

### Leader Key

The leader key is `,` (comma).

### General

| Mapping | Mode | Action |
|---------|------|--------|
| `jk` | Insert | Escape to normal mode |
| `jj` | Insert | Escape to normal mode |
| `<C-s>` | Normal/Insert | Save file |
| `<leader>w` | Normal | Save file |
| `<leader><space>` | Normal | Clear search highlight |
| `<leader>ev` | Normal | Edit vimrc |
| `<Space>` | Normal | Start search |
| `/` | Normal | Search with magic mode |

### Navigation

| Mapping | Mode | Action |
|---------|------|--------|
| `<C-h>` | Normal | Move to left window |
| `<C-j>` | Normal | Move to down window |
| `<C-k>` | Normal | Move to up window |
| `<C-l>` | Normal | Move to right window |
| `H` | Normal | Previous tab |
| `L` | Normal | Next tab |
| `n` | Normal | Next search result (centered) |
| `N` | Normal | Previous search result (centered) |

### Buffers & Files

| Mapping | Mode | Action |
|---------|------|--------|
| `<leader>b` | Normal | List buffers and select |
| `<leader>l` | Normal | List buffers and select |
| `<leader>d` | Normal | Close current buffer |
| `<leader>p` | Normal | Switch to alternate file |
| `<leader>t` | Normal | Find file (`:find *`) |
| `<leader>m` | Normal | Toggle NERDTree |
| `<leader>n` | Normal | Find current file in NERDTree |
| `-` | Normal | Open netrw (vim-vinegar) |

### Editing

| Mapping | Mode | Action |
|---------|------|--------|
| `<Tab>` | Normal | Indent line |
| `<S-Tab>` | Normal | Unindent line |
| `<Tab>` | Visual | Indent selection |
| `<S-Tab>` | Visual | Unindent selection |
| `<A-j>` | Normal/Insert/Visual | Move line(s) down |
| `<A-k>` | Normal/Insert/Visual | Move line(s) up |
| `.` | Visual | Execute dot on selection |
| `<C-l>` | Insert | Insert ` => ` |

### Plugins

| Mapping | Mode | Action |
|---------|------|--------|
| `<leader><leader>` | Normal | EasyMotion prefix |
| `<F5>` | Normal | Toggle Undotree |

### CoC.nvim (When Node.js Available)

| Mapping | Mode | Action |
|---------|------|--------|
| `<Tab>` | Insert | Next completion item |
| `<S-Tab>` | Insert | Previous completion item |
| `<CR>` | Insert | Confirm completion |
| `<C-Space>` | Insert | Trigger completion |
| `gd` | Normal | Go to definition |
| `gy` | Normal | Go to type definition |
| `gi` | Normal | Go to implementation |
| `gr` | Normal | Show references |
| `K` | Normal | Show documentation |
| `<leader>rn` | Normal | Rename symbol |
| `<leader>f` | Normal/Visual | Format selected |
| `<leader>a` | Normal/Visual | Code action on selected |
| `<leader>ac` | Normal | Code action at cursor |
| `<leader>qf` | Normal | Quick fix |
| `[g` | Normal | Previous diagnostic |
| `]g` | Normal | Next diagnostic |
| `<leader>ca` | Normal | Show all diagnostics |
| `<leader>cc` | Normal | Show commands |
| `<leader>cs` | Normal | Search symbols |

---

## Custom Commands

### File Operations

| Command | Description |
|---------|-------------|
| `:FormatJSON` | Format JSON (Node.js or Python) |
| `:RemoveEmptyLines` | Remove consecutive empty lines |
| `:StripWhiteSpace` | Remove trailing whitespace |
| `:WordCount` | Count words in file |

### Filetype Shortcuts

| Command | Description |
|---------|-------------|
| `:MD` | Set filetype to markdown |
| `:JS` | Set filetype to javascript |
| `:JSX` | Set filetype to javascriptreact |
| `:TS` | Set filetype to typescript |
| `:TSX` | Set filetype to typescriptreact |
| `:HTML` | Set filetype to html |
| `:CSS` | Set filetype to css |
| `:VUE` | Set filetype to vue |
| `:JSON` | Set filetype to json |

### npm Commands (When Node.js Available)

| Command | Description |
|---------|-------------|
| `:Npm <script>` | Run `npm run <script>` |
| `:NpmStart` | Run `npm start` |
| `:NpmDev` | Run `npm run dev` |
| `:NpmBuild` | Run `npm run build` |
| `:NpmTest` | Run `npm test` |
| `:NpmLint` | Run `npm run lint` |

---

## Plugins (Portable Config)

### Always Loaded

| Plugin | Description |
|--------|-------------|
| `scrooloose/nerdtree` | File explorer |
| `Xuyuanp/nerdtree-git-plugin` | Git status in NERDTree |
| `tpope/vim-fugitive` | Git integration |
| `airblade/vim-gitgutter` | Git diff in gutter |
| `easymotion/vim-easymotion` | Quick cursor movement |
| `vim-airline/vim-airline` | Status line |
| `vim-airline/vim-airline-themes` | Airline themes |
| `jiangmiao/auto-pairs` | Auto bracket pairing |
| `tpope/vim-surround` | Surround text objects |
| `tpope/vim-repeat` | Repeat plugin commands |
| `tpope/vim-commentary` | Comment code |
| `mg979/vim-visual-multi` | Multiple cursors |
| `godlygeek/tabular` | Text alignment |
| `vitalk/vim-simple-todo` | Todo management |
| `mbbill/undotree` | Undo visualization |
| `xolox/vim-session` | Session management |
| `tpope/vim-vinegar` | Enhanced netrw |
| `junegunn/goyo.vim` | Distraction-free writing |
| `junegunn/limelight.vim` | Focus mode |
| `reedes/vim-pencil` | Writing mode |

### Language Support (Syntax)

| Plugin | Languages |
|--------|-----------|
| `pangloss/vim-javascript` | JavaScript |
| `MaxMEllon/vim-jsx-pretty` | JSX |
| `leafgarland/typescript-vim` | TypeScript |
| `ap/vim-css-color` | CSS color preview |
| `cakebaker/scss-syntax.vim` | SCSS |
| `hail2u/vim-css3-syntax` | CSS3 |
| `othree/html5.vim` | HTML5 |
| `alvan/vim-closetag` | Auto close HTML tags |
| `Valloric/MatchTagAlways` | Highlight matching tags |
| `posva/vim-vue` | Vue.js |
| `elzr/vim-json` | JSON |
| `tpope/vim-markdown` | Markdown |
| `jparise/vim-graphql` | GraphQL |
| `cespare/vim-toml` | TOML |
| `moll/vim-node` | Node.js |

### Color Schemes

| Plugin | Schemes |
|--------|---------|
| `flazz/vim-colorschemes` | Collection |
| `morhetz/gruvbox` | Gruvbox (default) |
| `whatyouhide/vim-gotham` | Gotham |
| `mhartington/oceanic-next` | Oceanic Next |

### Node.js Only

| Plugin | Description |
|--------|-------------|
| `neoclide/coc.nvim` | LSP client |
| `honza/vim-snippets` | Snippet collection |
| `prettier/vim-prettier` | Code formatting |

---

## CoC Extensions (Auto-installed)

When Node.js is available, these CoC extensions are automatically installed:

| Extension | Description |
|-----------|-------------|
| `coc-tsserver` | TypeScript/JavaScript LSP |
| `coc-json` | JSON LSP |
| `coc-html` | HTML LSP |
| `coc-css` | CSS LSP |
| `coc-eslint` | ESLint integration |
| `coc-prettier` | Prettier integration |
| `coc-snippets` | Snippet support |
| `coc-emmet` | Emmet abbreviations |

---

## Settings

### Indentation

- 2 spaces (front-end standard)
- Spaces, not tabs
- Auto-indent enabled

### Display

- Line numbers (relative)
- Cursor line highlighted
- 256 colors
- Gruvbox dark theme

### Search

- Case-insensitive (smart case)
- Incremental search
- Highlight matches

### Behavior

- No swap files
- Hidden buffers allowed
- Split below and right
- Mouse disabled

---

## Portable Mode Detection

The main `vimrc` automatically detects when to use portable mode:

1. **Git Bash detected** (`win32unix`) AND
2. **fzf not available**

Or manually enable in `~/.vimrc.local`:
```vim
let g:vim_portable_mode = 1
```

---

## File Navigation (Without fzf)

Since fzf is not available in restricted environments, use these alternatives:

### Built-in `:find`

```vim
" Find files (with wildcard)
:find *component*<Tab>

" Or use the mapping
,t component<Tab>
```

The `path+=**` setting enables recursive searching.

### NERDTree

```vim
" Toggle file tree
,m

" Find current file in tree
,n
```

### vim-vinegar (netrw)

```vim
" Open directory listing
-

" Navigate up
-
```

### Buffer Navigation

```vim
" List and select buffer
,b

" Switch to alternate file
,p
```

---

## Comparison with Full Config

| Feature | Full (`vimrc`) | Portable (`vimrc.portable`) |
|---------|----------------|----------------------------|
| FZF | Yes | No (use `:find`) |
| Ripgrep | Yes | No (use `:grep`) |
| CoC.nvim | Yes | Yes (with Node.js) |
| Tmux integration | Yes | No |
| Powerline fonts | Yes | No (ASCII fallback) |
| External formatters | Multiple | Prettier only |
| Language servers | Full | Front-end focused |

---

## Troubleshooting

### Plugins not installing

Ensure vim-plug is installed:
```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

Then run `:PlugInstall` in Vim.

### CoC not working

1. Check Node.js is available: `:echo executable('node')`
2. Check npm is available: `:echo executable('npm')`
3. Run `:CocInfo` to see status
4. Run `:CocInstall coc-tsserver` manually if needed

### Colors look wrong

Try setting your terminal to support 256 colors:
```bash
export TERM=xterm-256color
```

### Airline symbols missing

The portable config uses ASCII symbols by default. If you have a patched font, add to `~/.vimrc.local`:
```vim
let g:airline_powerline_fonts = 1
```

### Slow startup

This is normal on first run while CoC installs extensions. Subsequent starts will be faster.
