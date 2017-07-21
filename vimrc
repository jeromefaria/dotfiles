" Based on the settings from @josemota and @nicknisi

set nocompatible
filetype on

"""""""""""""""""""""""""""""""""""""""
" Plugins
"""""""""""""""""""""""""""""""""""""""

"set rtp+=~/.vim/bundle/Vundle.vim
"call vundle#begin()

" Specify a directory for plugins (for Neovim: ~/.local/share/nvim/plugged)
call plug#begin('~/.vim/plugged')
"call plug#begin('~/.local/share/nvim/plugged')

"Plug 'gmarik/Vundle.vim'
Plug 'mileszs/ack.vim'
"Plug 'ctrlpvim/ctrlp.vim'
Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes' 
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-ragtag'
"Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-surround'
Plug 'honza/vim-snippets'
Plug 'airblade/vim-gitgutter'
Plug 'godlygeek/tabular'
Plug 'whatyouhide/vim-gotham'
"Plug 'kchmck/vim-coffee-script'
Plug 'rking/ag.vim'
Plug 'easymotion/vim-easymotion'
Plug 'Valloric/YouCompleteMe'
Plug 'scrooloose/nerdcommenter'
"Plug 'scrooloose/syntastic'
Plug 'benmills/vimux'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-vinegar'
Plug 'sjl/gundo.vim'
Plug 'vitalk/vim-simple-todo'
Plug 'tmux-plugins/vim-tmux'
Plug 'edkolev/tmuxline.vim'
"Plug 'wincent/command-t'
Plug 'terryma/vim-multiple-cursors'
Plug 'christoomey/vim-tmux-navigator'
Plug 'vim-scripts/LustyExplorer'
Plug 'godlygeek/csapprox'
Plug 'Shutnik/jshint2.vim'
Plug 'xolox/vim-session'
Plug 'xolox/vim-misc'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'junegunn/limelight.vim'
Plug 'junegunn/goyo.vim'
Plug 'vim-scripts/restore_view.vim'
Plug 'vim-syntastic/syntastic'

" language-specific plugins
Plug 'mattn/emmet-vim', { 'for': 'html' }
Plug 'gregsexton/MatchTag', { 'for': 'html' }
Plug 'othree/html5.vim', { 'for': 'html' }
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'moll/vim-node', { 'for': 'javascript' }
Plug 'jelera/vim-javascript-syntax', { 'for': 'javascript' }
Plug 'mxw/vim-jsx', { 'for': 'jsx' }
Plug 'elzr/vim-json', { 'for': 'json' }
Plug 'Shougo/vimproc.vim', { 'do': 'make' }
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }
"Plug 'mustache/vim-mustache-handlebars'
Plug 'digitaltoad/vim-jade', { 'for': 'jade' }
Plug 'cakebaker/scss-syntax.vim', { 'for': 'scss' }
Plug 'wavded/vim-stylus', { 'for': ['stylus', 'markdown'] }
"Plug 'groenewege/vim-less', { 'for': 'less' }
Plug 'ap/vim-css-color', { 'for': ['css','stylus','scss'] }
Plug 'hail2u/vim-css3-syntax', { 'for': 'css' }
Plug 'itspriddle/vim-marked', { 'for': 'markdown', 'on': 'MarkedOpen' }
Plug 'tpope/vim-markdown', { 'for': 'markdown' }
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'timcharper/textile.vim', { 'for': 'textile' }

" AngularJS plugins
Plug 'burnettk/vim-angular'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'matthewsimo/angular-vim-snippets'
Plug 'claco/jasmine.vim'

" Typescript
Plug 'leafgarland/typescript-vim'
Plug 'Quramy/vim-js-pretty-template'
Plug 'jason0x43/vim-js-indent'
Plug 'Quramy/vim-dtsm'
Plug 'mhartington/vim-typings'
Plug 'Quramy/ng-tsserver'
Plug 'Quramy/tsuquyomi'

" Colour schemes
Plug 'flazz/vim-colorschemes'

"call vundle#end()

" Initialize plugin system
call plug#end()

"""""""""""""""""""""""""""""""""""""""
" Mappings
"""""""""""""""""""""""""""""""""""""""

let mapleader = ","

" Insert mode mappings
inoremap <C-l> <space>=><space>
inoremap <C-s> <Esc>:w<CR>a

" Remap esc
inoremap jk <esc>
imap <expr> <tab> emmet#expandAbbrIntelligent("\<tab>")

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

" Indent with Tab and Shift+Tab
nnoremap <Tab> >>_
nnoremap <S-Tab> <<_
inoremap <S-Tab> <C-D>
vnoremap <Tab> >gv
vnoremap <S-Tab> <gv

" Execute dot in the selection
vnoremap . :norm.<CR>

" Navigate tabs
nnoremap H gT
nnoremap L gt

" Navigate splits
" map <silent> <C-h> :call WinMove('h')<cr>
" map <silent> <C-j> :call WinMove('j')<cr>
" map <silent> <C-k> :call WinMove('k')<cr>
" map <silent> <C-l> :call WinMove('l')<cr>

" Gundo key
nnoremap <F5> :GundoToggle<CR>

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
set list
set listchars=tab:▸\ ,eol:¬,nbsp:⋅,trail:•
set noswapfile
set shell=/bin/bash
set showmatch
set smartindent
set term=screen-256color
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
set so=8 " set 7 lines to the cursors - when moving vertical
set wrap
set linebreak
set breakat&vim
set hidden
" Folding
"set foldcolumn=4
set foldlevelstart=20
set foldmethod=indent
set foldenable
" Limit syntax highlight for long lines
set synmaxcol=250
" Fuzzy find Vim style
set path+=**

" Change search highlight color
highlight Search cterm=NONE ctermfg=black ctermbg=white
" Change tabs and end of line chars olor
highlight NonText guifg=#333333
highlight SpecialKey guifg=#333333
" Change code folding color
highlight Folded ctermfg=white ctermbg=240

"""""""""""""""""""""""""""""""""""""""
" Folding
"""""""""""""""""""""""""""""""""""""""
"au BufWinLeave * mkview
"au BufWinEnter * silent loadview

"""""""""""""""""""""""""""""""""""""""
" Autocommands
"""""""""""""""""""""""""""""""""""""""

".ru files are Ruby.
autocmd BufRead,BufNewFile *.ru set filetype=ruby
autocmd BufRead,BufNewFile [vV]agrantfile set filetype=ruby

" Markdown gets auto textwidth
"au Bufread,BufNewFile *.md set filetype=markdown textwidth=79
"au Bufread,BufNewFile *.markdown set textwidth=79

" .feature files are Cucumber.
autocmd Bufread,BufNewFile *.feature set filetype=cucumber

" .coffee are CoffeScript
autocmd BufNewFile,BufRead *.coffee set filetype=coffee

" .hbs are Handlebars templates
autocmd BufNewFile,BufRead *.hbs set filetype=html

" Reload vimrc when saved
autocmd BufWritePost vimrc source %

" Statusline
hi User1 ctermbg=white    ctermfg=black   guibg=#89A1A1 guifg=#002B36
hi User2 ctermbg=red      ctermfg=white   guibg=#aa0000 guifg=#89a1a1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Window movement shortcuts
" move to the window in the direction shown, or create a new window
function! WinMove(key)
    let t:curwin = winnr()
    exec "wincmd ".a:key
    if (t:curwin == winnr())
        if (match(a:key,'[jk]'))
            wincmd v
        else
            wincmd s
        endif
        exec "wincmd ".a:key
    endif
endfunction

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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" close NERDTree after a file is opened
let g:NERDTreeQuitOnOpen=0
" show hidden files in NERDTree
let NERDTreeShowHidden=1
" remove some files by extension
" let NERDTreeIgnore = ['\.js.map$']
" Toggle NERDTree
" nmap <silent> <leader>k :NERDTreeToggle<cr>
" expand to the path of the file in the current buffer
" nmap <silent> <leader>y :NERDTreeFind<cr>

"""""""""""""""""""""""""""""""""""""""
" Improve Ctrl P performance using Ag
"""""""""""""""""""""""""""""""""""""""

let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
if executable('ag')
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif

"""""""""""""""""""""""""""""""""""""""
" Specific configurations
"""""""""""""""""""""""""""""""""""""""

let g:markdown_fenced_languages = ['css', 'erb=eruby', 'javascript', 'js=javascript', 'json=javascript', 'ruby', 'sass', 'xml', 'html']

" vim: foldmethod=marker foldmarker={{{,}}}

syntax enable
filetype plugin indent on

"""""""""""""""""""""""""""""""""""""""
" Syntastic noob settings
"""""""""""""""""""""""""""""""""""""""

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:syntastic_javascript_checkers = ['eslint']

"""""""""""""""""""""""""""""""""""""""
" Ignore
"""""""""""""""""""""""""""""""""""""""

set wildignore+=*/tmp/*,*.so,*.swp,*.zip,/.tmp/     " MacOSX/Linux

let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn|tmp)$'
let g:ctrlp_user_command = 'find %s -type f | egrep -v "(build|bower_components|node_modules|\.tmp|\.sass-cache|\.git|\.idea|platforms)"'

let g:ycm_server_python_interpreter = '/usr/bin/python'
let g:ycm_server_python_interpreter = '/usr/local/bin/python'
"let $PATH = '/usr/local/opt/python/Frameworks/Python.framework/Versions/2.7/lib/libpython2.7.dylib -DPYTHON_INCLUDE_DIR=/usr/local/opt/python/Frameworks/Python.framework/Versions/2.7'.$PATH
'
