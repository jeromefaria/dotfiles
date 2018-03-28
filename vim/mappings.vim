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
nnoremap <leader>a :Ag
nnoremap <leader>d :bd<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader><space> :noh<CR>
"nnoremap <leader>l :ls<CR>:b
nnoremap <leader>l :BLines<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>t :FZF<CR>
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
