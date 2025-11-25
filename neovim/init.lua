-- Neovim Configuration Entry Point
-- Author: Jerome Faria
-- Description: Modern Neovim configuration using lazy.nvim

-- Set leader key before loading plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load configuration
require("config")

-- Bootstrap and load lazy.nvim
require("config.lazy")
