-- Keymap Mode Manager
-- Allows switching between classic (comma leader) and modern (space leader) keymaps

local M = {}

M.current_mode = nil -- 'classic' or 'modern'
M.preference_file = vim.fn.stdpath("config") .. "/keymap-mode"

-- List of keymaps to clear when switching modes
-- These are the keymaps defined in our keymap files (not plugin-defined ones)
M.managed_keymaps = {
  n = {}, -- Will be populated dynamically
  i = {},
  v = {},
  t = {},
}

-- Track keymaps we set so we can clear them
function M.track_keymap(mode, lhs)
  table.insert(M.managed_keymaps[mode] or {}, lhs)
end

-- Clear all tracked keymaps
function M.clear_keymaps()
  for mode, maps in pairs(M.managed_keymaps) do
    for _, lhs in ipairs(maps) do
      pcall(vim.keymap.del, mode, lhs)
    end
    M.managed_keymaps[mode] = {}
  end
end

-- Read saved preference
function M.get_saved_preference()
  local file = io.open(M.preference_file, "r")
  if file then
    local content = file:read("*all")
    file:close()
    content = content:gsub("%s+", "")
    if content == "classic" or content == "modern" then
      return content
    end
  end
  return nil
end

-- Save preference to file
function M.save_preference(mode)
  local file = io.open(M.preference_file, "w")
  if file then
    file:write(mode)
    file:close()
    return true
  end
  return false
end

-- Clear saved preference
function M.clear_preference()
  os.remove(M.preference_file)
end

-- Load classic keymaps
function M.set_classic()
  M.clear_keymaps()
  vim.g.mapleader = ","
  vim.g.maplocalleader = ","

  -- Load classic keymaps module
  package.loaded["config.keymaps-classic"] = nil
  require("config.keymaps-classic")

  M.current_mode = "classic"
  vim.notify("Keymap mode: Classic (leader: ,)", vim.log.levels.INFO)
end

-- Load modern keymaps
function M.set_modern()
  M.clear_keymaps()
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "

  -- Load modern keymaps module
  package.loaded["config.keymaps-modern"] = nil
  require("config.keymaps-modern")

  M.current_mode = "modern"
  vim.notify("Keymap mode: Modern (leader: <Space>)", vim.log.levels.INFO)
end

-- Toggle between modes
function M.toggle()
  if M.current_mode == "classic" then
    M.set_modern()
  else
    M.set_classic()
  end
end

-- Get current mode info
function M.info()
  local mode = M.current_mode or "not set"
  local leader = vim.g.mapleader or "not set"
  local saved = M.get_saved_preference() or "none"

  local msg = string.format(
    "Keymap Mode Info:\n  Current: %s\n  Leader: %s\n  Saved preference: %s",
    mode, leader == " " and "<Space>" or leader, saved
  )
  vim.notify(msg, vim.log.levels.INFO)
end

-- Initialize with a specific mode (called during startup)
function M.init(mode)
  if mode == "classic" then
    M.set_classic()
  else
    M.set_modern()
  end
end

-- Setup user commands
function M.setup_commands()
  vim.api.nvim_create_user_command("ClassicMode", function()
    M.set_classic()
  end, { desc = "Switch to classic keymaps (comma leader)" })

  vim.api.nvim_create_user_command("ModernMode", function()
    M.set_modern()
  end, { desc = "Switch to modern keymaps (space leader)" })

  vim.api.nvim_create_user_command("KeymapMode", function()
    M.info()
  end, { desc = "Show current keymap mode" })

  vim.api.nvim_create_user_command("KeymapToggle", function()
    M.toggle()
  end, { desc = "Toggle between classic and modern keymaps" })

  vim.api.nvim_create_user_command("KeymapSave", function(opts)
    local mode = opts.args
    if mode == "" then
      mode = M.current_mode
    end
    if mode == "classic" or mode == "modern" then
      M.save_preference(mode)
      vim.notify("Saved keymap preference: " .. mode, vim.log.levels.INFO)
    else
      vim.notify("Invalid mode. Use 'classic' or 'modern'", vim.log.levels.ERROR)
    end
  end, {
    nargs = "?",
    complete = function() return { "classic", "modern" } end,
    desc = "Save keymap mode preference"
  })

  vim.api.nvim_create_user_command("KeymapClearPreference", function()
    M.clear_preference()
    vim.notify("Cleared keymap preference. Will prompt on next startup.", vim.log.levels.INFO)
  end, { desc = "Clear saved keymap preference" })
end

return M
