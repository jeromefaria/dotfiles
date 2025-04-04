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

"let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
"if executable('ag')
  "let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
"endif

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

"""""""""""""""""""""""""""""""""""""""
" YouCompleteMe
"""""""""""""""""""""""""""""""""""""""
"let g:ycm_path_to_python_interpreter = '/usr/bin/python'
"let g:ycm_server_python_interpreter = '/usr/bin/python'
"let g:ycm_python_binary_path = 'python'

"""""""""""""""""""""""""""""""""""""""
" FZF
"""""""""""""""""""""""""""""""""""""""
" set rtp+=/usr/local/opt/fzf
set rtp+=/home/linuxbrew/.linuxbrew/opt/fzf
" Fuzzy-find with fzf
map <C-p> :Files<cr>
nmap <C-p> :Files<cr>

" View commits in fzf
nmap <Leader>c :Commits<cr>

let g:fzf_layout = { 'window': { 'width': 0.8, 'height': 0.8 } }
let $FZF_DEFAULT_OPTS='--reverse'
nnoremap <leader>gc :GCheckout<CR>


"""""""""""""""""""""""""""""""""""""""
" Limelight
"""""""""""""""""""""""""""""""""""""""
" Color name (:help cterm-colors) or ANSI code
let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_ctermfg = 240

" Color name (:help gui-colors) or RGB color
let g:limelight_conceal_guifg = 'DarkGray'
let g:limelight_conceal_guifg = '#777777'

" Default: 0.5
let g:limelight_default_coefficient = 0.7

" Number of preceding/following paragraphs to include (default: 0)
let g:limelight_paragraph_span = 1

" Beginning/end of paragraph
"   When there's no empty line between the paragraphs
"   and each paragraph starts with indentation
let g:limelight_bop = '^\s'
let g:limelight_eop = '\ze\n^\s'

" Highlighting priority (default: 10)
"   Set it to -1 not to overrule hlsearch
let g:limelight_priority = -1

"""""""""""""""""""""""""""""""""""""""
" Easymotion
"""""""""""""""""""""""""""""""""""""""
map <leader><leader> <Plug>(easymotion-prefix)

"""""""""""""""""""""""""""""""""""""""
" Syntastic
"""""""""""""""""""""""""""""""""""""""
"map §§ <Plug>(easymotion-prefix)
let g:syntastic_check_on_open = 0
let g:syntastic_mode_map = { "mode": "passive" }

"""""""""""""""""""""""""""""""""""""""
" Multiple Cursors
"""""""""""""""""""""""""""""""""""""""
"let g:multi_cursor_quit_key='jk'

"""""""""""""""""""""""""""""""""""""""
" Markdown Folding
"""""""""""""""""""""""""""""""""""""""
" folding for Markdown headers, both styles (atx- and setex-)
" http://daringfireball.net/projects/markdown/syntax#header
"
" this code can be placed in file
"   $HOME/.vim/after/ftplugin/markdown.vim

func! Foldexpr_markdown(lnum)
    let l1 = getline(a:lnum)

    if l1 =~ '^\s*$'
        " ignore empty lines
        return '='
    endif

    let l2 = getline(a:lnum+1)

    if  l2 =~ '^==\+\s*'
        " next line is underlined (level 1)
        return '>1'
    elseif l2 =~ '^--\+\s*'
        " next line is underlined (level 2)
        return '>2'
    elseif l1 =~ '^#'
        " current line starts with hashes
        return '>'.matchend(l1, '^#\+')
    elseif a:lnum == 1
        " fold any 'preamble'
        return '>1'
    else
        " keep previous foldlevel
        return '='
    endif
endfunc

setlocal foldexpr=Foldexpr_markdown(v:lnum)
setlocal foldmethod=expr

"---------- everything after this is optional -----------------------
" change the following fold options to your liking
" see ':help fold-options' for more
setlocal foldenable
setlocal foldlevel=0
setlocal foldcolumn=0

" Do not autoload sessions
let g:session_autoload = 'no'

"""""""""""""""""""""""""""""""""""""""
" Vim Airline theme
"""""""""""""""""""""""""""""""""""""""
" let g:airline_theme = 'oceanicnext'

"""""""""""""""""""""""""""""""""""""""
" Tmuxline preset
"""""""""""""""""""""""""""""""""""""""
" let g:tmuxline_preset = 'custom'

"""""""""""""""""""""""""""""""""""""""
" Neoplete
"""""""""""""""""""""""""""""""""""""""
"
" Plugin key-mappings.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" SuperTab like snippets behavior.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
"imap <expr><TAB>
" \ pumvisible() ? "\<C-n>" :
" \ neosnippet#expandable_or_jumpable() ?
" \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For conceal markers.
if has('conceal')
  set conceallevel=2 concealcursor=niv
endif

"""""""""""""""""""""""""""""""""""""""
" TypeScript
"""""""""""""""""""""""""""""""""""""""
let g:nvim_typescript#diagnosticsEnable = 0
let g:nvim_typescript#diagnostics_enable = 0

"""""""""""""""""""""""""""""""""""""""
" ALE
"""""""""""""""""""""""""""""""""""""""
let g:ale_linters = {
\   'javascript': ['eslint'],
\   'typescript': ['tsserver', 'tslint'],
\}

let g:ale_fixers = {
\    'javascript': ['eslint'],
\    'typescript': ['prettier'],
\    'scss': ['prettier'],
\    'html': ['prettier']
\}
let g:ale_fix_on_save = 0

"""""""""""""""""""""""""""""""""""""""
" NERD Commenter
"""""""""""""""""""""""""""""""""""""""
let g:NERDSpaceDelims = 1
let g:ft = ''

function! NERDCommenter_before()
  if &ft == 'vue'
    let g:ft = 'vue'
    let stack = synstack(line('.'), col('.'))
    if len(stack) > 0
      let syn = synIDattr((stack)[0], 'name')
      if len(syn) > 0
        exe 'setf ' . substitute(tolower(syn), '^vue_', '', '')
      endif
    endif
  endif
endfunction

function! NERDCommenter_after()
  if g:ft == 'vue'
    setf vue
    let g:ft = ''
  endif
endfunction

"""""""""""""""""""""""""""""""""""""""
" vim-vue
"""""""""""""""""""""""""""""""""""""""
let g:vue_pre_processors = 'detect_on_enter'

"""""""""""""""""""""""""""""""""""""""
" pathogen
"""""""""""""""""""""""""""""""""""""""
" execute pathogen#infect()
