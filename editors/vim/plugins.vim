" ============================================================================
" Vim Plugins Configuration (vim-plug)
" Vim 8.0+ only - Neovim uses separate configuration
" ============================================================================

set nocompatible
filetype on

" Specify plugin directory
call plug#begin('~/.vim/plugged')

" ============================================================================
" Completion & Snippets
" ============================================================================

" YouCompleteMe or COC for completion (choose one)
" Plug 'ycm-core/YouCompleteMe', { 'do': './install.py' }
Plug 'neoclide/coc.nvim', { 'branch': 'release' }

" Snippets
Plug 'honza/vim-snippets'

" ============================================================================
" Fuzzy Finder & Navigation
" ============================================================================

" FZF
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'stsewd/fzf-checkout.vim'

" File explorer
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

" Easy motion
Plug 'easymotion/vim-easymotion'

" ============================================================================
" Git Integration
" ============================================================================

Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" ============================================================================
" Tmux Integration
" ============================================================================

Plug 'benmills/vimux'
Plug 'tmux-plugins/vim-tmux'
Plug 'christoomey/vim-tmux-navigator'

" ============================================================================
" UI & Status Line
" ============================================================================

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'edkolev/tmuxline.vim'

" ============================================================================
" Language Support
" ============================================================================

" JavaScript & TypeScript
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'MaxMEllon/vim-jsx-pretty', { 'for': ['jsx', 'javascript'] }
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }
Plug 'Quramy/vim-js-pretty-template'

" CSS / SCSS
Plug 'ap/vim-css-color', { 'for': ['css','stylus','scss'] }
Plug 'cakebaker/scss-syntax.vim', { 'for': 'scss' }
Plug 'hail2u/vim-css3-syntax', { 'for': 'css' }

" HTML
Plug 'othree/html5.vim', { 'for': 'html' }
Plug 'alvan/vim-closetag'
Plug 'Valloric/MatchTagAlways'

" Vue
Plug 'posva/vim-vue'

" JSON
Plug 'elzr/vim-json', { 'for': 'json' }

" Markdown
Plug 'tpope/vim-markdown', { 'for': 'markdown' }
Plug 'itspriddle/vim-marked', { 'for': 'markdown', 'on': 'MarkedOpen' }

" GraphQL
Plug 'jparise/vim-graphql'

" TOML
Plug 'cespare/vim-toml'

" Processing
Plug 'sophacles/vim-processing', { 'for': 'processing' }

" Node.js
Plug 'moll/vim-node', { 'for': 'javascript' }

" ============================================================================
" Editing Enhancements
" ============================================================================

" Auto pairs
Plug 'jiangmiao/auto-pairs'

" Surround
Plug 'tpope/vim-surround'

" Repeat
Plug 'tpope/vim-repeat'

" Commentary
Plug 'scrooloose/nerdcommenter'

" Multiple cursors
Plug 'mg979/vim-visual-multi'

" Tabular alignment
Plug 'godlygeek/tabular'

" Todo
Plug 'vitalk/vim-simple-todo'

" Formatting
Plug 'prettier/vim-prettier', { 'do': 'yarn install' }

" ============================================================================
" Color Schemes
" ============================================================================

Plug 'flazz/vim-colorschemes'
Plug 'whatyouhide/vim-gotham'
Plug 'mhartington/oceanic-next'
Plug 'morhetz/gruvbox'

" ============================================================================
" Writing & Focus
" ============================================================================

Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'reedes/vim-pencil'
Plug 'jacekd/vim-iawriter'

" ============================================================================
" Utilities
" ============================================================================

" Undo tree
Plug 'sjl/gundo.vim'

" Session management
Plug 'xolox/vim-misc'
Plug 'xolox/vim-session'

" Restore view
Plug 'vim-scripts/restore_view.vim'

" Vinegar (file navigation)
Plug 'tpope/vim-vinegar'

" Outline viewer
Plug 'vim-scripts/VOoM'

" Initialize plugin system
call plug#end()

" ============================================================================
" Plugin Settings
" ============================================================================

" COC extensions
let g:coc_global_extensions = [
  \ 'coc-tsserver',
  \ 'coc-json',
  \ 'coc-html',
  \ 'coc-css',
  \ 'coc-eslint',
  \ 'coc-prettier',
  \ 'coc-snippets',
  \ ]

" NERDTree settings
let NERDTreeShowHidden=1
let NERDTreeIgnore=['\.git$', '\.DS_Store$', 'node_modules']

" Airline settings
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

" Session settings
let g:session_autosave = 'no'
let g:session_autoload = 'no'

" FZF settings
let g:fzf_layout = { 'down': '40%' }

" Prettier settings
let g:prettier#autoformat = 0
let g:prettier#exec_cmd_async = 1

" Close tag settings
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.jsx,*.tsx,*.vue'
