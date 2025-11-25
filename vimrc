" ============================================================================
" Vim Configuration (vim-plug based)
" Compatible with Vim 8.0+
" For Neovim, use ~/.config/nvim instead
" ============================================================================

" Ensure Vim-only (skip for Neovim)
if has('nvim')
  echom "Neovim detected! Use ~/.config/nvim for Neovim configuration"
  finish
endif

" Source Vim configuration modules
" Note: install.sh creates symlink from dotfiles/vim to ~/.vim/config
so ~/.vim/config/plugins.vim
so ~/.vim/config/general.vim
so ~/.vim/config/mappings.vim
so ~/.vim/config/colours.vim
so ~/.vim/config/status.vim
so ~/.vim/config/autocmd.vim
so ~/.vim/config/functions.vim
so ~/.vim/config/commands.vim
so ~/.vim/config/misc.vim
