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
"Plug 'mileszs/ack.vim'
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
"Plug 'Shutnik/jshint2.vim'
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
"Plug 'digitaltoad/vim-jade', { 'for': 'jade' }
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

" Writing
Plug 'vim-scripts/VOoM'
Plug 'reedes/vim-pencil'
Plug 'jacekd/vim-iawriter'

"Processing
Plug 'sophacles/vim-processing'

"call vundle#end()

" Initialize plugin system
call plug#end()
