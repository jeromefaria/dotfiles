-- Neovim Options Configuration
local opt = vim.opt

-- General
opt.mouse = "a" -- Enable mouse support
opt.clipboard = "unnamedplus" -- Use system clipboard
opt.swapfile = false -- Disable swap files
opt.completeopt = "menu,menuone,noselect" -- Completion options

-- UI
opt.number = true -- Show line numbers
opt.relativenumber = true -- Show relative line numbers
opt.cursorline = true -- Highlight current line
opt.signcolumn = "yes" -- Always show sign column
opt.scrolloff = 8 -- Keep 8 lines above/below cursor
opt.sidescrolloff = 8 -- Keep 8 columns left/right of cursor
opt.termguicolors = true -- Enable 24-bit RGB colors
opt.showmode = false -- Don't show mode (airline/lualine shows it)
opt.wrap = false -- Disable line wrap

-- Splits
opt.splitright = true -- Vertical split to the right
opt.splitbelow = true -- Horizontal split to the bottom

-- Search
opt.ignorecase = true -- Ignore case in search
opt.smartcase = true -- Override ignorecase if search contains uppercase
opt.hlsearch = true -- Highlight search results
opt.incsearch = true -- Incremental search

-- Indentation
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftwidth = 2 -- Size of indent
opt.tabstop = 2 -- Number of spaces tabs count for
opt.softtabstop = 2 -- Number of spaces for editing
opt.smartindent = true -- Smart autoindenting
opt.autoindent = true -- Copy indent from current line

-- Performance
opt.updatetime = 300 -- Faster completion
opt.timeoutlen = 400 -- Faster key sequence completion
opt.lazyredraw = true -- Don't redraw during macros

-- Backup
opt.backup = false -- Disable backup
opt.writebackup = false -- Disable backup before write
opt.undofile = true -- Enable persistent undo

-- Folding
opt.foldmethod = "indent" -- Use indent for folding (treesitter will override this when loaded)
opt.foldenable = false -- Don't fold by default

-- Wildmenu
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.wildignore = { "*.o", "*.obj", "*~", "*.pyc", "*.class" }

-- Other
opt.hidden = true -- Enable background buffers
opt.history = 1000 -- Command history size
opt.spell = false -- Disable spell checking by default
opt.title = true -- Set terminal title

-- Disable providers we don't use
vim.g.loaded_perl_provider = 0 -- Disable Perl provider
vim.g.loaded_ruby_provider = 0 -- Disable Ruby provider
