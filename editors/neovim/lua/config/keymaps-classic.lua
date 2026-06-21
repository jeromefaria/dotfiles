-- Classic Keymaps Configuration
-- Restored from original vim-plug era configuration.
-- Leader key: , (comma).
--
-- Mode-agnostic bindings (window nav, move-line, paste, diagnostic nav,
-- jk-escape, terminal-escape) live in config/keymaps-shared.lua.

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Leader is set by keymap-mode.lua, but ensure it's comma
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Mode-agnostic bindings (shared with modern)
require("config.keymaps-shared").apply()

--------------------------------------------------------------------------------
-- INSERT MODE
--------------------------------------------------------------------------------

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
-- VISUAL MODE
--------------------------------------------------------------------------------

-- Better indenting (keep selection)
keymap.set("v", "<Tab>", ">gv", opts)
keymap.set("v", "<S-Tab>", "<gv", opts)

-- Execute dot command on selection
keymap.set("v", ".", ":norm.<CR>", opts)

--------------------------------------------------------------------------------
-- TERMINAL MODE
--------------------------------------------------------------------------------

-- Exit terminal mode (original used kk; <Esc> is also bound in keymaps-shared)
keymap.set("t", "kk", "<C-\\><C-n>", opts)

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
-- Single shared augroup name (KeymapLsp) with clear=true so a mode toggle
-- replaces the previous handler rather than stacking a second one.
--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("KeymapLsp", { clear = true }),
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
    -- Classic uses <leader>F for format because <leader>f is grep
    keymap.set("n", "<leader>F", function()
      vim.lsp.buf.format({ async = true })
    end, bufopts)
  end,
})

--------------------------------------------------------------------------------
-- DIAGNOSTIC KEYMAPS (classic-specific; [d / ]d / <leader>dl live in keymaps-shared)
--------------------------------------------------------------------------------

-- Note: <leader>e conflicts with file explorer in modern mode, but that's fine
-- because each mode loads only its own set after the toggle.
keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)

--------------------------------------------------------------------------------
-- TERMINAL
--------------------------------------------------------------------------------

keymap.set("n", "<leader>tt", ":terminal<CR>", opts)
