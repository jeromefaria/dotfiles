set nocompatible
filetype on

"""""""""""""""""""""""""""""""""""""""
" Plugins
"""""""""""""""""""""""""""""""""""""""

" Specify a directory for plugins (for Neovim: ~/.local/share/nvim/plugged)
call plug#begin('~/.vim/plugged')
"call plug#begin('~/.local/share/nvim/plugged')

Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-ragtag' "Up for review
Plug 'airblade/vim-gitgutter'
Plug 'godlygeek/tabular'
Plug 'rking/ag.vim' "Up for review (deprecated)
Plug 'easymotion/vim-easymotion'
Plug 'mhartington/nvim-typescript', { 'do': './install.sh' }
Plug 'stsewd/fzf-checkout.vim'

" For async completion
Plug 'Shougo/deoplete.nvim'

Plug 'HerringtonDarkholme/yats.vim'
Plug 'mhartington/nvim-typescript', {'do': './install.sh'}

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
let g:deoplete#enable_at_startup = 1

Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'

Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-vinegar'
Plug 'sjl/gundo.vim'
Plug 'vitalk/vim-simple-todo'
Plug 'terryma/vim-multiple-cursors'
Plug 'godlygeek/csapprox' "Up for review
Plug 'xolox/vim-session'
Plug 'xolox/vim-misc'
Plug 'junegunn/limelight.vim'
Plug 'junegunn/goyo.vim'
Plug 'vim-scripts/restore_view.vim'
Plug 'vim-syntastic/syntastic'
Plug 'jiangmiao/auto-pairs'
Plug 'prettier/vim-prettier', { 'do': 'yarn install' }
Plug 'cespare/vim-toml'

" FZF
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

" Tmux
Plug 'benmills/vimux'
Plug 'tmux-plugins/vim-tmux'
Plug 'christoomey/vim-tmux-navigator'

" Airline / Tmuxline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'edkolev/tmuxline.vim'

"Snippets
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'

" Language-specific plugins
Plug 'Valloric/MatchTagAlways'
Plug 'othree/html5.vim', { 'for': 'html' }
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'moll/vim-node', { 'for': 'javascript' }
Plug 'jelera/vim-javascript-syntax', { 'for': 'javascript' }
Plug 'mxw/vim-jsx', { 'for': 'jsx' }
Plug 'elzr/vim-json', { 'for': 'json' }
Plug 'Shougo/vimproc.vim', { 'do': 'make' }
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }
Plug 'cakebaker/scss-syntax.vim', { 'for': 'scss' }
Plug 'wavded/vim-stylus', { 'for': ['stylus', 'markdown'] }
Plug 'ap/vim-css-color', { 'for': ['css','stylus','scss'] }
Plug 'hail2u/vim-css3-syntax', { 'for': 'css' }
Plug 'itspriddle/vim-marked', { 'for': 'markdown', 'on': 'MarkedOpen' }
Plug 'tpope/vim-markdown', { 'for': 'markdown' }
" Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'timcharper/textile.vim', { 'for': 'textile' }
Plug 'sophacles/vim-processing', { 'for': 'processing' }
Plug 'posva/vim-vue'

" AngularJS plugins
" Plug 'burnettk/vim-angular'
" Plug 'othree/javascript-libraries-syntax.vim'
" Plug 'matthewsimo/angular-vim-snippets'
" Plug 'claco/jasmine.vim'

" Typescript
Plug 'leafgarland/typescript-vim'
Plug 'Quramy/vim-js-pretty-template'
Plug 'jason0x43/vim-js-indent'
Plug 'Quramy/vim-dtsm'
Plug 'mhartington/vim-typings'
Plug 'Quramy/ng-tsserver'

" Colour schemes
Plug 'flazz/vim-colorschemes'
Plug 'whatyouhide/vim-gotham'
Plug 'mhartington/oceanic-next'

" Writing
Plug 'vim-scripts/VOoM'
Plug 'reedes/vim-pencil'
Plug 'jacekd/vim-iawriter'

" Syntax check
Plug 'dense-analysis/ale'

"call vundle#end()

" Initialize plugin system
call plug#end()
