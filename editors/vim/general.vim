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
set list
set listchars=tab:▸\ ,eol:¬,nbsp:⋅,trail:•
set noswapfile

" Platform-aware shell configuration
if exists('g:vim_platform')
  if g:vim_platform == 'gitbash' || g:vim_platform == 'windows'
    set shell=bash
    set shellcmdflag=-c
  elseif g:vim_platform == 'macos'
    if executable('/usr/local/bin/zsh')
      set shell=/usr/local/bin/zsh
    elseif executable('/opt/homebrew/bin/zsh')
      set shell=/opt/homebrew/bin/zsh
    else
      set shell=/bin/zsh
    endif
  else
    " Linux or unknown - use sh for maximum compatibility
    set shell=/bin/sh
  endif
else
  " Fallback if platform detection hasn't run
  set shell=/bin/sh
endif
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
