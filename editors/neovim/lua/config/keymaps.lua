-- Neovim Keymaps Configuration
local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Remap escape in insert mode
keymap.set("i", "jk", "<Esc>", opts)

-- Better window navigation
keymap.set("n", "<C-h>", "<C-w>h", opts)
keymap.set("n", "<C-j>", "<C-w>j", opts)
keymap.set("n", "<C-k>", "<C-w>k", opts)
keymap.set("n", "<C-l>", "<C-w>l", opts)

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

-- Move text up and down
keymap.set("n", "<A-j>", ":m .+1<CR>==", opts)
keymap.set("n", "<A-k>", ":m .-2<CR>==", opts)
keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)

-- Keep visual selection after indenting
keymap.set("v", "<", "<gv", opts)
keymap.set("v", ">", ">gv", opts)

-- Better paste in visual mode (doesn't yank replaced text)
keymap.set("v", "p", '"_dP', opts)

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

-- LSP keymaps (set when LSP attaches)
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
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

-- Diagnostic keymaps
keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, opts)

-- Terminal
keymap.set("n", "<leader>tt", ":terminal<CR>", opts)
keymap.set("t", "<Esc>", "<C-\\><C-n>", opts) -- Exit terminal mode
