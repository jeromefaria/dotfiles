"""""""""""""""""""""""""""""""""""""""
" Plugins
"""""""""""""""""""""""""""""""""""""""

" Specify a directory for plugins (for Neovim: ~/.local/share/nvim/plugged)
call plug#begin('~/.vim/plugged')
"call plug#begin('~/.local/share/nvim/plugged')

" Async completion
Plug 'Shougo/deoplete.nvim'

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

" let g:deoplete#enable_at_startup = 1

" Syntax check
" Plug 'dense-analysis/ale'

" Snippets
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'Shougo/neosnippet-snippets'
Plug 'Shougo/neosnippet.vim'
Plug 'tomtom/tlib_vim'

" FZF
"Plug 'junegunn/fzf'
"Plug 'junegunn/fzf.vim'
"Plug 'stsewd/fzf-checkout.vim'

Plug 'ctrlpvim/ctrlp.vim'

" Tmux
"Plug 'benmills/vimux'
"Plug 'tmux-plugins/vim-tmux'
"Plug 'christoomey/vim-tmux-navigator'

" Airline / Tmuxline
"Plug 'vim-airline/vim-airline'
"Plug 'vim-airline/vim-airline-themes'
Plug 'edkolev/tmuxline.vim'

" Javascript
Plug 'Quramy/vim-js-pretty-template'
" Plug 'jason0x43/vim-js-indent'
" Plug 'jelera/vim-javascript-syntax', { 'for': 'javascript' }
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }

" Typescript
Plug 'Quramy/vim-dtsm'
Plug 'leafgarland/typescript-vim'
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }

" CSS / SCSS
Plug 'ap/vim-css-color', { 'for': ['css','stylus','scss'] }
Plug 'cakebaker/scss-syntax.vim', { 'for': 'scss' }
Plug 'hail2u/vim-css3-syntax', { 'for': 'css' }

" Language-specific plugins
" Plug 'Shougo/vimproc.vim', { 'do': 'make' }
Plug 'MaxMEllon/vim-jsx-pretty', { 'for': 'jsx' }
Plug 'cespare/vim-toml'
Plug 'elzr/vim-json', { 'for': 'json' }
" Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'itspriddle/vim-marked', { 'for': 'markdown', 'on': 'MarkedOpen' }
" Plug 'mattn/emmet-vim', { 'for': 'html' }
Plug 'moll/vim-node', { 'for': 'javascript' }
Plug 'othree/html5.vim', { 'for': 'html' }
Plug 'posva/vim-vue'
Plug 'sophacles/vim-processing', { 'for': 'processing' }
Plug 'tpope/vim-markdown', { 'for': 'markdown' }

" Colour schemes
Plug 'flazz/vim-colorschemes'
Plug 'whatyouhide/vim-gotham'
Plug 'mhartington/oceanic-next'

" Writing
Plug 'jacekd/vim-iawriter'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'reedes/vim-pencil'
Plug 'vim-scripts/VOoM'

" Misc
"Plug 'Valloric/MatchTagAlways'
Plug 'airblade/vim-gitgutter'
Plug 'easymotion/vim-easymotion'
Plug 'godlygeek/tabular'
Plug 'jiangmiao/auto-pairs'
Plug 'mg979/vim-visual-multi'
Plug 'prettier/vim-prettier', { 'do': 'yarn install' }
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'sjl/gundo.vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-ragtag' " Up for review
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-vinegar'
Plug 'vim-scripts/restore_view.vim'
Plug 'vim-syntastic/syntastic' " Up for review
Plug 'vitalk/vim-simple-todo'
Plug 'xolox/vim-misc' " Up for review
Plug 'xolox/vim-session'
" Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }

Plug 'alvan/vim-closetag'

" TREX
Plug 'yaegassy/coc-volar'
Plug 'pmizio/typescript-tools.nvim'
Plug 'MunifTanjim/eslint.nvim'
Plug 'windwp/nvim-ts-autotag'
Plug 'jparise/vim-graphql'
Plug 'nvim-neotest/neotest'
" Plug 'MunifTanjim/prettier.nvim'

Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/plenary.nvim'

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
" imap <expr> <tab> emmet#expandAbbrIntelligent("\<tab>")

" Normal mode mappings
nnoremap <C-s> :w<CR>
nnoremap <leader>ev :vs $MYVIMRC<CR>
nnoremap <leader>gs :Gstatus<CR><C-W>15+
nnoremap <leader>m :NERDTreeToggle<CR>
nnoremap <leader>rs :!clear;time bundle exec rake<CR>
nnoremap <leader>a :Ag
nnoremap <leader>d :bd<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader><space> :noh<CR>
"nnoremap <leader>l :ls<CR>:b
nnoremap <leader>l :BLines<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>t :FZF<CR>
nnoremap <leader>f :Rg<CR>
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

" Move lines and blocks
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Reload buffer
map <leader><leader>c :checktime<cr>

" Always sets magic mode for search
nnoremap / /\v

" Map <Space> to / (search)
map <Space> /

" Splits navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Vim Terminal

tnoremap <Esc><Esc> <C-\><C-n>
tnoremap <C-h> <C-w>h
tnoremap <C-j> <C-w>j
tnoremap <C-k> <C-w>k
tnoremap <C-l> <C-w>l

"""""""""""""""""""""""""""""""""""""""
" General settings
"""""""""""""""""""""""""""""""""""""""

set nocompatible
set path+=autoload
set mouse=a
filetype on

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
"set shell=/bin/bash
set shell=/usr/bin/bash
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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Status
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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
" Colours
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Set the colorscheme
colorscheme minimalist

" Change search highlight color
highlight Search cterm=NONE ctermfg=black ctermbg=white

" Change tabs and end of line chars olor
highlight NonText guifg=#333333
highlight SpecialKey guifg=#333333

" Change code folding color
highlight Folded ctermfg=white ctermbg=240

" Change bad spelling highlight style
highlight clear SpellBad
highlight SpellBad cterm=underline ctermfg=red

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

function Say() range
  echo system('echo '.shellescape(join(getline(a:firstline, a:lastline), "\n")).'| say')
endfunction

com -range=% -nargs=0 Say :<line1>,<line2>call Say()

command FormatJSON %!python3 -m json.tool
command RemoveEmptyLines %s/\v\n{2,}/\r/gge | norm dd
command StripWhiteSpace %s/\s\+$//gge
command WordCount !wc %
command SortInline :call setline(line('.'),join(sort(split(getline('.'))), ' '))
command BreakLine '<,'>s/, /,\r/gg
command CleanJSArray silent %s/"// | %s/\v,$// | normal ds[
command MD set filetype=markdown
command JS set filetype=javascript
command Docs cd ~/Documents
