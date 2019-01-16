" Enable mouse
set mouse=a

" Remap ESC to return to normal mode on terminal
:tnoremap kk <C-\><C-n>

" Start terminal in insert mode
"autocmd TermOpen * startinsert

"OceanicNext
"" For Neovim 0.1.3 and 0.1.4
"let $NVIM_TUI_ENABLE_TRUE_COLOR=1

"" Or if you have Neovim >= 0.1.5
if (has("termguicolors"))
 set termguicolors
endif

" Theme
"syntax enable
colorscheme OceanicNext

" Use deoplete.
let g:deoplete#enable_at_startup = 1
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
