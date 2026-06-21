-- Modern Keymaps Configuration
-- Leader key: <Space>
-- This is the current lazy.nvim era configuration.
--
-- Mode-agnostic bindings (window nav, move-line, paste, diagnostic nav,
-- jk-escape, terminal-escape) live in config/keymaps-shared.lua.

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Leader is set by keymap-mode.lua, but ensure it's space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Mode-agnostic bindings (shared with classic)
require("config.keymaps-shared").apply()

-- Resize windows
keymap.set("n", "<C-Up>", ":resize -2<CR>", opts)
keymap.set("n", "<C-Down>", ":resize +2<CR>", opts)
keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap.set("n", "<S-l>", ":bnext<CR>", opts)
keymap.set("n", "<S-h>", ":bprevious<CR>", opts)
keymap.set("n", "<leader>bd", ":bdelete<CR>", opts)

-- Clear search highlighting
keymap.set("n", "<leader>h", ":nohlsearch<CR>", opts)

-- Better indenting
keymap.set("v", "<", "<gv", opts)
keymap.set("v", ">", ">gv", opts)

-- Save file
keymap.set("n", "<leader>w", ":w<CR>", opts)

-- Quit
keymap.set("n", "<leader>q", ":q<CR>", opts)
keymap.set("n", "<leader>Q", ":qa!<CR>", opts)

-- Split windows
keymap.set("n", "<leader>sv", ":vsplit<CR>", opts)
keymap.set("n", "<leader>sh", ":split<CR>", opts)

-- Toggle file explorer
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", opts)

-- Telescope keymaps
keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", opts)
keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", opts)
keymap.set("n", "<leader>fb", ":Telescope buffers<CR>", opts)
keymap.set("n", "<leader>fh", ":Telescope help_tags<CR>", opts)
keymap.set("n", "<leader>fr", ":Telescope oldfiles<CR>", opts)
keymap.set("n", "<leader>fc", ":Telescope git_commits<CR>", opts)
keymap.set("n", "<leader>fs", ":Telescope git_status<CR>", opts)

-- LSP keymaps (set when LSP attaches).
-- Single shared augroup name (KeymapLsp) with clear=true so re-loading
-- after a mode toggle replaces the previous handler instead of stacking
-- a second one on top of it.
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
		keymap.set("n", "<leader>f", function()
			vim.lsp.buf.format({ async = true })
		end, bufopts)
	end,
})

-- Diagnostic (modern-specific; [d / ]d / <leader>dl live in keymaps-shared)
keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

-- Terminal
keymap.set("n", "<leader>tt", ":terminal<CR>", opts)
