-- Neovim Configuration Entry Point
-- Author: Jerome Faria
-- Description: Modern Neovim configuration using lazy.nvim

-- Set leader key before loading anything
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load core configuration (doesn't depend on plugins)
require("config.options")
require("config.keymaps")
require("config.commands")

-- Bootstrap and load lazy.nvim with plugins
require("config.lazy")

-- Load autocmds after plugins are available
require("config.autocmds")
