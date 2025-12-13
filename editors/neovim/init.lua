-- Neovim Configuration Entry Point
-- Author: Jerome Faria
-- Description: Modern Neovim configuration using lazy.nvim

-- Set initial leader key (may be changed by keymap selector)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load core configuration (doesn't depend on plugins)
require("config.options")
require("config.commands")

-- Initialize keymap mode selector (handles classic/modern keymap switching)
-- This loads the appropriate keymaps based on saved preference or shows a prompt
require("config.keymap-selector").init()

-- Bootstrap and load lazy.nvim with plugins
require("config.lazy")

-- Load autocmds after plugins are available
require("config.autocmds")
