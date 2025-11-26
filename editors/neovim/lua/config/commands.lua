-- Neovim Custom Commands Configuration

-- Format JSON using Python's json.tool
vim.api.nvim_create_user_command("FormatJSON", function()
	vim.cmd("%!python3 -m json.tool")
end, { desc = "Format JSON using Python json.tool" })

-- Remove multiple consecutive empty lines
vim.api.nvim_create_user_command("RemoveEmptyLines", function()
	vim.cmd([[%s/\v\n{2,}/\r/gge | norm dd]])
end, { desc = "Remove consecutive empty lines" })

-- Strip trailing whitespace
vim.api.nvim_create_user_command("StripWhiteSpace", function()
	vim.cmd([[%s/\s\+$//gge]])
end, { desc = "Strip trailing whitespace from all lines" })

-- Word count for current file
vim.api.nvim_create_user_command("WordCount", function()
	vim.cmd("!wc %")
end, { desc = "Show word count for current file" })

-- Sort words on current line inline
vim.api.nvim_create_user_command("SortInline", function()
	local line = vim.fn.getline(".")
	local words = vim.split(line, " ")
	table.sort(words)
	vim.fn.setline(".", table.concat(words, " "))
end, { desc = "Sort words on current line alphabetically" })

-- Break comma-separated items onto separate lines
vim.api.nvim_create_user_command("BreakLine", function()
	vim.cmd([['<,'>s/, /,\r/gg]])
end, { range = true, desc = "Break comma-separated items onto separate lines" })

-- Clean JavaScript array (remove quotes, trailing commas, and brackets)
vim.api.nvim_create_user_command("CleanJSArray", function()
	vim.cmd([[silent %s/"//g | %s/\v,$//g | normal ds[]])
end, { desc = "Clean JavaScript array formatting" })

-- Quick filetype setters
vim.api.nvim_create_user_command("MD", function()
	vim.bo.filetype = "markdown"
end, { desc = "Set filetype to markdown" })

vim.api.nvim_create_user_command("JS", function()
	vim.bo.filetype = "javascript"
end, { desc = "Set filetype to javascript" })

-- Quick directory navigation
vim.api.nvim_create_user_command("Docs", function()
	vim.cmd("cd ~/Documents")
end, { desc = "Change directory to ~/Documents" })
