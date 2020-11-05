set nocompatible
filetype on

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

let g:deoplete#enable_at_startup = 1

" Syntax check
Plug 'dense-analysis/ale'

" Snippets
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'Shougo/neosnippet-snippets'
Plug 'Shougo/neosnippet.vim'
Plug 'tomtom/tlib_vim'

" FZF
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'stsewd/fzf-checkout.vim'

" Tmux
Plug 'benmills/vimux'
Plug 'tmux-plugins/vim-tmux'
Plug 'christoomey/vim-tmux-navigator'

" Airline / Tmuxline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'edkolev/tmuxline.vim'

" Javascript
Plug 'Quramy/vim-js-pretty-template'
Plug 'jason0x43/vim-js-indent'
Plug 'jelera/vim-javascript-syntax', { 'for': 'javascript' }
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }

" Typescript
Plug 'Quramy/vim-dtsm'
Plug 'leafgarland/typescript-vim'
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }
Plug 'mhartington/nvim-typescript', { 'do': './install.sh' }
Plug 'mhartington/vim-typings'

" CSS / SCSS
Plug 'ap/vim-css-color', { 'for': ['css','stylus','scss'] }
Plug 'cakebaker/scss-syntax.vim', { 'for': 'scss' }
Plug 'hail2u/vim-css3-syntax', { 'for': 'css' }

" Language-specific plugins
Plug 'MaxMEllon/vim-jsx-pretty', { 'for': 'jsx' }
Plug 'cespare/vim-toml'
Plug 'elzr/vim-json', { 'for': 'json' }
" Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'itspriddle/vim-marked', { 'for': 'markdown', 'on': 'MarkedOpen' }
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
Plug 'Valloric/MatchTagAlways'
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


"call vundle#end()

" Initialize plugin system
call plug#end()
