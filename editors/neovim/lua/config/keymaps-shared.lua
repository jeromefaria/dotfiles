-- Mode-agnostic keymaps shared between the classic (comma-leader) and
-- modern (space-leader) variants. Bindings here do not reference the
-- leader key, so they're safe to load under either mode.
--
-- Call M.apply() from keymaps-modern.lua and keymaps-classic.lua before
-- (or after — same set, doesn't matter) the leader-specific bindings.

local M = {}

function M.apply()
  local keymap = vim.keymap
  local opts = { noremap = true, silent = true }

  -- Insert mode: jk to escape
  keymap.set("i", "jk", "<Esc>", opts)

  -- Window navigation (Ctrl-h/j/k/l)
  keymap.set("n", "<C-h>", "<C-w>h", opts)
  keymap.set("n", "<C-j>", "<C-w>j", opts)
  keymap.set("n", "<C-k>", "<C-w>k", opts)
  keymap.set("n", "<C-l>", "<C-w>l", opts)

  -- Move text up/down (Alt-j/k) in normal and visual modes
  keymap.set("n", "<A-j>", ":m .+1<CR>==", opts)
  keymap.set("n", "<A-k>", ":m .-2<CR>==", opts)
  keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
  keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)

  -- Better paste in visual mode (does not yank the replaced text)
  keymap.set("v", "p", '"_dP', opts)

  -- Diagnostic navigation
  keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, opts)

  -- Terminal: Esc to exit terminal mode
  keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)
end

return M
