" Based on the settings from @josemota and @nicknisi 

set nocompatible
filetype on

"""""""""""""""""""""""""""""""""""""""
" Plugins
"""""""""""""""""""""""""""""""""""""""

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'gmarik/Vundle.vim'
Plugin 'mileszs/ack.vim'
Plugin 'kien/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes' 
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-ragtag'
Plugin 'vim-ruby/vim-ruby'
Plugin 'tpope/vim-surround'
"Plugin 'mattn/emmet-vim'
Plugin 'honza/vim-snippets'
Plugin 'airblade/vim-gitgutter'
Plugin 'godlygeek/tabular'
Plugin 'whatyouhide/vim-gotham'
Plugin 'kchmck/vim-coffee-script'
Plugin 'rking/ag.vim'
Plugin 'easymotion/vim-easymotion'
Plugin 'Valloric/YouCompleteMe'
Plugin 'scrooloose/nerdcommenter'

" language-specific plugins
Plugin 'mattn/emmet-vim', { 'for': 'html' }
Plugin 'gregsexton/MatchTag', { 'for': 'html' }
Plugin 'othree/html5.vim', { 'for': 'html' }
Plugin 'pangloss/vim-javascript', { 'for': 'javascript' }
Plugin 'moll/vim-node', { 'for': 'javascript' }
Plugin 'jelera/vim-javascript-syntax', { 'for': 'javascript' }
Plugin 'mxw/vim-jsx', { 'for': 'jsx' }
Plugin 'elzr/vim-json', { 'for': 'json' }
Plugin 'Shougo/vimproc.vim', { 'do': 'make' }
Plugin 'leafgarland/typescript-vim', { 'for': 'typescript' }
Plugin 'mustache/vim-mustache-handlebars'
Plugin 'digitaltoad/vim-jade', { 'for': 'jade' }
Plugin 'cakebaker/scss-syntax.vim', { 'for': 'scss' }
Plugin 'wavded/vim-stylus', { 'for': ['stylus', 'markdown'] }
Plugin 'groenewege/vim-less', { 'for': 'less' }
Plugin 'ap/vim-css-color', { 'for': ['css','stylus','scss'] }
Plugin 'hail2u/vim-css3-syntax', { 'for': 'css' }
Plugin 'itspriddle/vim-marked', { 'for': 'markdown', 'on': 'MarkedOpen' }
Plugin 'tpope/vim-markdown', { 'for': 'markdown' }
Plugin 'fatih/vim-go', { 'for': 'go' }
Plugin 'timcharper/textile.vim', { 'for': 'textile' }

call vundle#end()

"""""""""""""""""""""""""""""""""""""""
" Mappings
"""""""""""""""""""""""""""""""""""""""

let mapleader = ","

" Insert mode mappings
inoremap <C-l> <space>=><space>
inoremap <C-s> <Esc>:w<CR>a

" Normal mode mappings
nnoremap <C-s> :w<CR>
nnoremap <leader>ev :vs $MYVIMRC<CR>
nnoremap <leader>gs :Gstatus<CR><C-W>15+
nnoremap <leader>m :NERDTreeToggle<CR>
nnoremap <leader>rs :!clear;time bundle exec rake<CR>
nnoremap <leader>a :Ack 
nnoremap <leader>d :bd<CR> 
nnoremap <leader>w :w<CR>
nnoremap <leader><space> :noh<CR>
nnoremap <leader>l :ls<CR>:b
nnoremap <leader>t :CtrlP<CR>
nnoremap n nzz
nnoremap N Nzz
"nnoremap <leader>c :nohl<CR>

" Visual mode mappings
" vnoremap < <gv
" vnoremap > >gv

" Indent with Tab and Shift+Tab
nnoremap <Tab> >>_
nnoremap <S-Tab> <<_
inoremap <S-Tab> <C-D>
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

" Execute dot in the selection
vnoremap . :norm.<CR>

" Navigate tabs
nnoremap <C-Left> :tabprevious<CR>
nnoremap <C-Right> :tabnext<CR>

"""""""""""""""""""""""""""""""""""""""
" General settings
"""""""""""""""""""""""""""""""""""""""

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
"set list
"set listchars=tab:▸\ ,eol:¬,nbsp:⋅,trail:•
set noswapfile
set shell=/bin/bash
set showmatch
set smartindent
set term=screen-256color
set ts=2 sts=2 sw=2 expandtab
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
"set relativenumber
"set background=dark
"colorscheme material-theme
"colorscheme gotham256
set lazyredraw
set ttyfast

"""""""""""""""""""""""""""""""""""""""
" Folding
"""""""""""""""""""""""""""""""""""""""
"au BufWinLeave * mkview
"au BufWinEnter * silent loadview

"""""""""""""""""""""""""""""""""""""""
" Autocommands
"""""""""""""""""""""""""""""""""""""""

".ru files are Ruby.
au BufRead,BufNewFile *.ru set filetype=ruby
au BufRead,BufNewFile [vV]agrantfile set filetype=ruby

" Markdown gets auto textwidth
"au Bufread,BufNewFile *.md set filetype=markdown textwidth=79
"au Bufread,BufNewFile *.markdown set textwidth=79

" .feature files are Cucumber.
au Bufread,BufNewFile *.feature set filetype=cucumber

" .coffee are CoffeScript
au BufNewFile,BufRead *.coffee set filetype=coffee

" .hbs are Handlebars templates
au BufNewFile,BufRead *.hbs set filetype=html

" Statusline
hi User1 ctermbg=white    ctermfg=black   guibg=#89A1A1 guifg=#002B36
hi User2 ctermbg=red      ctermfg=white   guibg=#aa0000 guifg=#89a1a1

function! GetCWD()
  return expand(":pwd")
endfunction

function! IsHelp()
  return &buftype=='help'?' (help) ':''
endfunction

function! GetName()
  return expand("%:t")==''?'<none>':expand("%:t")
endfunction

set statusline=%1*[%{GetName()}]\ 
set statusline+=%<pwd:%{getcwd()}\ 
set statusline+=%2*%{&modified?'\[+]':''}%*
set statusline+=%{IsHelp()}
set statusline+=%{&readonly?'\ (ro)\ ':''}
set statusline+=[
set statusline+=%{strlen(&fenc)?&fenc:'none'}\|
set statusline+=%{&ff}\|
set statusline+=%{strlen(&ft)?&ft:'<none>'}
set statusline+=]\ 
set statusline+=%=
set statusline+=c%c
set statusline+=,l%l
set statusline+=/%L\ 
set laststatus=2

"""""""""""""""""""""""""""""""""""""""
" Specific configurations
"""""""""""""""""""""""""""""""""""""""

let g:markdown_fenced_languages = ['css', 'erb=eruby', 'javascript', 'js=javascript', 'json=javascript', 'ruby', 'sass', 'xml', 'html']

" vim: foldmethod=marker foldmarker={{{,}}}

syntax enable
filetype plugin indent on
