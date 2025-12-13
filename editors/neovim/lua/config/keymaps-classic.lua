-- Classic Keymaps Configuration
-- Restored from original vim-plug era configuration
-- Leader key: , (comma)

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Leader is set by keymap-mode.lua, but ensure it's comma
vim.g.mapleader = ","
vim.g.maplocalleader = ","

--------------------------------------------------------------------------------
-- INSERT MODE
--------------------------------------------------------------------------------

-- Remap escape
keymap.set("i", "jk", "<Esc>", opts)

-- Arrow for fat arrow (useful for JS/TS)
keymap.set("i", "<C-l>", " => ", opts)

-- Save from insert mode
keymap.set("i", "<C-s>", "<Esc>:w<CR>a", opts)

-- Dedent in insert mode
keymap.set("i", "<S-Tab>", "<C-D>", opts)

--------------------------------------------------------------------------------
-- NORMAL MODE - Core
--------------------------------------------------------------------------------

-- Save file (multiple ways)
keymap.set("n", "<C-s>", ":w<CR>", opts)
keymap.set("n", "<leader>w", ":w<CR>", opts)

-- Edit vimrc/init.lua
keymap.set("n", "<leader>ev", ":vs $MYVIMRC<CR>", opts)

-- Delete buffer
keymap.set("n", "<leader>d", ":bdelete<CR>", opts)

-- Clear search highlighting
keymap.set("n", "<leader><space>", ":nohlsearch<CR>", opts)

-- Center screen after search
keymap.set("n", "n", "nzz", opts)
keymap.set("n", "N", "Nzz", opts)

-- Very magic search (regex by default)
keymap.set("n", "/", "/\\v", { noremap = true })

-- Space to search
keymap.set("n", "<Space>", "/", { noremap = true })

-- Reload buffer
keymap.set("n", "<leader><leader>c", ":checktime<CR>", opts)

-- Quit
keymap.set("n", "<leader>q", ":q<CR>", opts)
keymap.set("n", "<leader>Q", ":qa!<CR>", opts)

--------------------------------------------------------------------------------
-- NORMAL MODE - Indenting
--------------------------------------------------------------------------------

keymap.set("n", "<Tab>", ">>_", opts)
keymap.set("n", "<S-Tab>", "<<_", opts)

--------------------------------------------------------------------------------
-- NORMAL MODE - Tab Navigation (original used tabs, not buffers)
--------------------------------------------------------------------------------

keymap.set("n", "H", "gT", opts) -- Previous tab
keymap.set("n", "L", "gt", opts) -- Next tab

--------------------------------------------------------------------------------
-- NORMAL MODE - Move Lines
--------------------------------------------------------------------------------

keymap.set("n", "<A-j>", ":m .+1<CR>==", opts)
keymap.set("n", "<A-k>", ":m .-2<CR>==", opts)

--------------------------------------------------------------------------------
-- NORMAL MODE - Window Navigation
--------------------------------------------------------------------------------

keymap.set("n", "<C-h>", "<C-w>h", opts)
keymap.set("n", "<C-j>", "<C-w>j", opts)
keymap.set("n", "<C-k>", "<C-w>k", opts)
keymap.set("n", "<C-l>", "<C-w>l", opts)

--------------------------------------------------------------------------------
-- VISUAL MODE
--------------------------------------------------------------------------------

-- Better indenting (keep selection)
keymap.set("v", "<Tab>", ">gv", opts)
keymap.set("v", "<S-Tab>", "<gv", opts)

-- Execute dot command on selection
keymap.set("v", ".", ":norm.<CR>", opts)

-- Move lines
keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)

-- Better paste (don't yank replaced text)
keymap.set("v", "p", '"_dP', opts)

--------------------------------------------------------------------------------
-- TERMINAL MODE
--------------------------------------------------------------------------------

-- Exit terminal mode (original used kk)
keymap.set("t", "kk", "<C-\\><C-n>", opts)
keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)

--------------------------------------------------------------------------------
-- PLUGIN MAPPINGS - File Explorer (NERDTree -> NvimTree)
--------------------------------------------------------------------------------

keymap.set("n", "<leader>m", ":NvimTreeToggle<CR>", opts)

--------------------------------------------------------------------------------
-- PLUGIN MAPPINGS - Fuzzy Finding (FZF -> Telescope)
--------------------------------------------------------------------------------

-- Original: ,t for FZF files
keymap.set("n", "<leader>t", ":Telescope find_files<CR>", opts)

-- Original: Ctrl-P for files
keymap.set("n", "<C-p>", ":Telescope find_files<CR>", opts)

-- Original: ,f for Rg (ripgrep)
keymap.set("n", "<leader>f", ":Telescope live_grep<CR>", opts)

-- Original: ,b for buffers
keymap.set("n", "<leader>b", ":Telescope buffers<CR>", opts)

-- Original: ,l for BLines (buffer lines)
keymap.set("n", "<leader>l", ":Telescope current_buffer_fuzzy_find<CR>", opts)

-- Original: ,c for commits
keymap.set("n", "<leader>c", ":Telescope git_commits<CR>", opts)

-- Original: ,gc for git checkout (branches)
keymap.set("n", "<leader>gc", ":Telescope git_branches<CR>", opts)

-- Original: ,a for Ag (silver searcher) - map to grep
keymap.set("n", "<leader>a", ":Telescope live_grep<CR>", opts)

--------------------------------------------------------------------------------
-- PLUGIN MAPPINGS - Git (Fugitive)
--------------------------------------------------------------------------------

-- Original: ,gs for Gstatus (now :Git)
keymap.set("n", "<leader>gs", ":Git<CR>", opts)

--------------------------------------------------------------------------------
-- PLUGIN MAPPINGS - Undo Tree (Gundo -> undotree)
--------------------------------------------------------------------------------

-- Original: F5 for GundoToggle
keymap.set("n", "<F5>", ":UndotreeToggle<CR>", opts)

--------------------------------------------------------------------------------
-- PLUGIN MAPPINGS - EasyMotion -> flash.nvim
-- Note: EasyMotion used ,, prefix. flash.nvim uses 's' by default.
-- We'll add the ,, prefix to trigger flash for familiarity.
--------------------------------------------------------------------------------

keymap.set("n", "<leader><leader>w", function()
  require("flash").jump({
    search = { mode = "search", max_length = 0 },
    label = { after = { 0, 0 } },
    pattern = "\\<",
  })
end, { desc = "Flash to word (EasyMotion style)" })

keymap.set("n", "<leader><leader>s", function()
  require("flash").jump()
end, { desc = "Flash jump" })

--------------------------------------------------------------------------------
-- LSP KEYMAPS (set when LSP attaches)
-- These remain mostly the same as they're standard
--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("ClassicLspConfig", { clear = true }),
  callback = function(ev)
    local bufopts = { noremap = true, silent = true, buffer = ev.buf }
    keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
    keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
    keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
    keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
    keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
    keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, bufopts)
    keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
    keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
    keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
    keymap.set("n", "<leader>F", function()
      vim.lsp.buf.format({ async = true })
    end, bufopts)
  end,
})

--------------------------------------------------------------------------------
-- DIAGNOSTIC KEYMAPS
--------------------------------------------------------------------------------

keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts) -- Note: conflicts with file explorer in modern mode
keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, opts)

--------------------------------------------------------------------------------
-- TERMINAL
--------------------------------------------------------------------------------

keymap.set("n", "<leader>tt", ":terminal<CR>", opts)
