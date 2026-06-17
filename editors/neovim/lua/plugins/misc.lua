-- Miscellaneous Plugins

return {
  -- Tmux integration
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },

  -- Tmux syntax
  {
    "tmux-plugins/vim-tmux",
    ft = "tmux",
  },

  -- Vimux - interact with tmux
  {
    "preservim/vimux",
    cmd = { "VimuxRunCommand", "VimuxPromptCommand", "VimuxRunLastCommand" },
    keys = {
      { "<leader>vp", ":VimuxPromptCommand<CR>", desc = "Vimux Prompt Command" },
      { "<leader>vl", ":VimuxRunLastCommand<CR>", desc = "Vimux Run Last Command" },
    },
  },

  -- Session management
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp" } },
    keys = {
      {
        "<leader>qs",
        function()
          require("persistence").load()
        end,
        desc = "Restore Session",
      },
      {
        "<leader>ql",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Restore Last Session",
      },
      {
        "<leader>qd",
        function()
          require("persistence").stop()
        end,
        desc = "Don't Save Current Session",
      },
    },
  },

  -- Which-key: key binding help
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      preset = "modern",
      plugins = { spelling = true },
      spec = {
        mode = { "n", "v" },
        { "g", group = "goto" },
        { "gs", group = "surround" },
        { "]", group = "next" },
        { "[", group = "prev" },
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>f", group = "file/find" },
        { "<leader>g", group = "git" },
        { "<leader>h", group = "git hunk" },
        { "<leader>q", group = "quit/session" },
        { "<leader>s", group = "split" },
        { "<leader>t", group = "terminal/todo" },
        { "<leader>u", group = "ui" },
        { "<leader>w", group = "write" },
        { "<leader>x", group = "diagnostics/quickfix" },
      },
    },
  },

  -- Plenary - lua utilities
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
  },

  -- Markdown syntax + filetype
  {
    "tpope/vim-markdown",
    ft = "markdown",
    init = function()
      vim.g.markdown_recommended_style = 0 -- Prevent vim-markdown from overriding tabstop
    end,
  },

  -- Markdown preview (browser, hot-reload, renders Mermaid/diagrams)
  -- Build runs `npm install` in the plugin's app/ — required so the bundled
  -- Node.js server can load its tslib + other deps. The plugin's own
  -- mkdp#util#install() helper is meant to fetch a precompiled binary but
  -- silently falls back to the Node runtime, so explicit npm install is safer.
  -- npm install mutates yarn.lock (npm leaves a trace), which makes lazy.nvim
  -- see the plugin tree as dirty and refuse future updates. The git checkout
  -- discards that side-effect so the tree stays clean for future :Lazy sync.
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = { "markdown" },
    build = "cd app && npm install && git checkout -- yarn.lock 2>/dev/null || true",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_close = 0 -- Keep the browser tab open when buffer closes
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview Toggle", ft = "markdown" },
    },
  },

  -- Vue.js support
  {
    "posva/vim-vue",
    ft = "vue",
  },

  -- GraphQL syntax
  {
    "jparise/vim-graphql",
    ft = "graphql",
  },

  -- TOML syntax
  {
    "cespare/vim-toml",
    ft = "toml",
  },

  -- JSON with comments
  {
    "elzr/vim-json",
    ft = "json",
  },

  -- Repeat plugin commands
  {
    "tpope/vim-repeat",
    event = "VeryLazy",
  },

  -- Better quickfix
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
  },

  -- Todo comments
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next todo comment",
      },
      {
        "[t",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Previous todo comment",
      },
      { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
      { "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Todo" },
      { "<leader>fT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
    },
  },

  -- Trouble - diagnostics list
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    opts = { use_diagnostic_signs = true },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
      { "<leader>xL", "<cmd>TroubleToggle loclist<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix List (Trouble)" },
    },
  },
}
