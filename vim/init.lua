require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = { 'tsserver' }
})

local lspconfig = require('lspconfig')
lspconfig.tsserver.setup({})

require("typescript-tools").setup {
  settings = {
    tsserver_plugins = {
      -- for TypeScript v4.9+
      "@styled/typescript-styled-plugin",
      -- or for older TypeScript versions
      -- "typescript-styled-plugin",
    },
  },
}
