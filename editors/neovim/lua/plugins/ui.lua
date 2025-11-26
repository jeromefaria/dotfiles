-- UI and Theme Plugins

return {
  -- Color schemes
  {
    "mhartington/oceanic-next",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme OceanicNext]])
    end,
  },

  {
    "folke/tokyonight.nvim",
    lazy = true,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = { statusline = { "dashboard", "alpha" } },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- Buffer line
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
      options = {
        mode = "buffers",
        separator_style = "thin",
        always_show_bufferline = false,
        show_buffer_close_icons = false,
        show_close_icon = false,
        color_icons = true,
        diagnostics = "nvim_lsp",
      },
    },
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file explorer" },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      disable_netrw = true,
      hijack_netrw = true,
      view = {
        width = 30,
        side = "left",
      },
      renderer = {
        group_empty = true,
        highlight_git = true,
        icons = {
          show = {
            git = true,
            folder = true,
            file = true,
            folder_arrow = true,
          },
        },
      },
      filters = {
        dotfiles = false,
        custom = { ".git", "node_modules", ".cache" },
      },
    },
  },

  -- Icons
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  -- Notification manager
  {
    "rcarriga/nvim-notify",
    lazy = false,
    priority = 900,
    keys = {
      {
        "<leader>un",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Dismiss all Notifications",
      },
    },
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
    },
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)
      vim.notify = notify
    end,
  },

  -- Dashboard
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    opts = function()
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.header.val = {
        [[                                                    ]],
        [[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗]],
        [[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║]],
        [[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║]],
        [[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║]],
        [[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║]],
        [[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
        [[                                                    ]],
      }
      dashboard.section.buttons.val = {
        dashboard.button("f", " " .. " Find file", ":Telescope find_files <CR>"),
        dashboard.button("n", " " .. " New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("r", " " .. " Recent files", ":Telescope oldfiles <CR>"),
        dashboard.button("g", " " .. " Find text", ":Telescope live_grep <CR>"),
        dashboard.button("c", " " .. " Config", ":e $MYVIMRC <CR>"),
        dashboard.button("l", "󰒲 " .. " Lazy", ":Lazy<CR>"),
        dashboard.button("q", " " .. " Quit", ":qa<CR>"),
      }
      return dashboard
    end,
    config = function(_, dashboard)
      require("alpha").setup(dashboard.opts)
    end,
  },

  -- Better UI for inputs and selects
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },

  -- Highlight matching tags
  {
    "leafOfTree/vim-matchtag",
    ft = { "html", "xml", "jsx", "tsx", "vue" },
  },

  -- Mini modules
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      -- You can configure mini modules here if needed
      -- require('mini.icons').setup()
    end,
  },
}
