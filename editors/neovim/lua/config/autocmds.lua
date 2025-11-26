-- Neovim Autocommands Configuration

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
	end,
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("trim_whitespace", { clear = true }),
	pattern = "*",
	callback = function()
		-- Skip if buffer is not modifiable
		if not vim.bo.modifiable then
			return
		end
		local save_cursor = vim.fn.getpos(".")
		vim.cmd([[%s/\s\+$//e]])
		vim.fn.setpos(".", save_cursor)
	end,
})

-- Restore cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	group = vim.api.nvim_create_augroup("restore_cursor", { clear = true }),
	pattern = "*",
	callback = function()
		if vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line("$") then
			vim.fn.setpos(".", vim.fn.getpos("'\""))
			vim.cmd("silent! foldopen")
		end
	end,
})

-- Auto-format on save for specific filetypes (only if LSP is attached)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("auto_format", { clear = true }),
	pattern = { "*.lua", "*.js", "*.ts", "*.jsx", "*.tsx", "*.json", "*.md" },
	callback = function()
		-- Only format if LSP client is attached to buffer
		if #vim.lsp.get_clients({ bufnr = 0 }) > 0 then
			vim.lsp.buf.format({ async = false })
		end
	end,
})

-- Close certain filetypes with q
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("close_with_q", { clear = true }),
	pattern = { "help", "qf", "lspinfo", "man", "startuptime" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})

-- Check if file changed outside of Neovim
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = vim.api.nvim_create_augroup("checktime", { clear = true }),
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd("checktime")
		end
	end,
})

-- Set filetype for specific files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("custom_filetypes", { clear = true }),
	pattern = { "*.conf", "config" },
	callback = function()
		vim.bo.filetype = "conf"
	end,
})
