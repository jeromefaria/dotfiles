-- Keymap Selector
-- Shows startup prompt to choose between classic and modern keymaps

local M = {}

-- Check if running in headless mode or similar
local function is_interactive()
  return vim.fn.has("gui_running") == 1 or vim.env.TERM ~= nil
end

-- Show the selection prompt
function M.show_prompt(callback)
  local keymap_mode = require("config.keymap-mode")

  vim.ui.select(
    { "modern", "classic" },
    {
      prompt = "Select keymap mode:",
      format_item = function(item)
        if item == "classic" then
          return "Classic (comma leader, original vim bindings)"
        else
          return "Modern (space leader, current bindings)"
        end
      end,
    },
    function(choice)
      if choice then
        keymap_mode.init(choice)

        -- Ask if they want to save the preference
        vim.ui.select(
          { "yes", "no" },
          {
            prompt = "Remember this choice for future sessions?",
            format_item = function(item)
              return item == "yes" and "Yes, save preference" or "No, ask me next time"
            end,
          },
          function(save_choice)
            if save_choice == "yes" then
              keymap_mode.save_preference(choice)
            end
            if callback then callback(choice) end
          end
        )
      else
        -- User cancelled, default to modern
        keymap_mode.init("modern")
        if callback then callback("modern") end
      end
    end
  )
end

-- Initialize keymap mode on startup
-- This is called from lazy.lua during startup
function M.init()
  local keymap_mode = require("config.keymap-mode")

  -- Setup commands first
  keymap_mode.setup_commands()

  -- Check for saved preference
  local saved = keymap_mode.get_saved_preference()

  if saved then
    -- Load saved preference immediately
    keymap_mode.init(saved)
  else
    -- Set a default first (modern), then show prompt after UI is ready
    -- This prevents issues with vim.ui.select not being available immediately
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "

    -- Schedule the prompt for after VimEnter when UI is ready
    vim.api.nvim_create_autocmd("VimEnter", {
      once = true,
      callback = function()
        -- Small delay to ensure UI is fully ready
        vim.defer_fn(function()
          if is_interactive() then
            M.show_prompt()
          else
            -- Non-interactive mode, use modern as default
            keymap_mode.init("modern")
          end
        end, 100)
      end,
    })

    -- Load modern keymaps as initial default (will be replaced if user chooses classic)
    require("config.keymaps-modern")
    keymap_mode.current_mode = "modern"
  end
end

return M
