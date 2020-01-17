"""""""""""""""""""""""""""""""""""""""
" General settings
"""""""""""""""""""""""""""""""""""""""

"set background=dark
set t_Co=256
set autoindent
set backspace=indent,eol,start
"set colorcolumn=80
set cursorline
set encoding=utf-8
set fileencoding=utf-8
set gdefault
set guioptions-=Be
set guioptions=aAc
set list
set listchars=tab:▸\ ,eol:¬,nbsp:⋅,trail:•
set noswapfile
"set shell=/bin/bash
set shell=/usr/local/bin/zsh
set showmatch
set smartindent
"set term=screen-256color
"set ts=2 sts=2 sw=2 expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
"set noexpandtab
set expandtab
set novisualbell
"set winheight=999
"set winheight=5
"set winminheight=5
"set winwidth=84
set clipboard=unnamed
set history=1000
set wildmenu
set wildmode=full
set magic
set hlsearch
set ignorecase
set incsearch
set smartcase
set number
set relativenumber
set lazyredraw
set ttyfast
set splitbelow
set splitright
set scrolloff=8 " set 7 lines to the cursors - when moving vertical
set wrap
set linebreak
set breakat&vim
set hidden
set wildignorecase

" Folding
"set foldcolumn=4
set foldlevelstart=1
set foldmethod=indent
set foldenable

" Limit syntax highlight for long lines
set synmaxcol=250

" Fuzzy find Vim style
set path+=**

" Enable spell check
" set spell

set title

"""""""""""""""""""""""""""""""""""""""
" Folding
"""""""""""""""""""""""""""""""""""""""
"au BufWinLeave * mkview
"au BufWinEnter * silent loadview
