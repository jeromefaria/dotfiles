# Editors

Two editor configurations live here.

| Dir | Purpose | Use when |
|---|---|---|
| [`neovim/`](neovim/README.md) | Primary editor. Lua config, [`lazy.nvim`](https://github.com/folke/lazy.nvim) plugin manager, LSP + autocompletion + fuzzy-finding + git integration. | Day-to-day editing on a machine where Neovim is installed. |
| [`vim/`](vim/README.md) | Fallback. Vim config using vim-plug. | Machines where Neovim isn't available (restricted environments, remote servers, Git Bash) or when launching plain `vim` is desired. |

Both configs are symlinked into place by `scripts/install.sh` (Neovim → `~/.config/nvim`, Vim → `~/.vim/config`). The Neovim config is the source of truth; the Vim config is intentionally smaller and doesn't try to mirror every Neovim feature.

See each sub-README for the feature inventory, key bindings, and plugin list.
