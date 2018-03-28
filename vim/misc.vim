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

"""""""""""""""""""""""""""""""""""""""
" YouCompleteMe
"""""""""""""""""""""""""""""""""""""""
"let g:ycm_path_to_python_interpreter = '/usr/bin/python'
"let g:ycm_server_python_interpreter = '/usr/bin/python'
"let g:ycm_python_binary_path = 'python'

"""""""""""""""""""""""""""""""""""""""
" FZF
"""""""""""""""""""""""""""""""""""""""
set rtp+=/usr/local/opt/fzf
" Fuzzy-find with fzf
map <C-p> :Files<cr>
nmap <C-p> :Files<cr>

" View commits in fzf
nmap <Leader>c :Commits<cr>


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
