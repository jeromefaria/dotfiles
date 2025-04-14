" ~/.vim/sessions/default.vim:
" Vim session script.
" Created by session.vim 2.13.1 on 06 December 2019 at 13:33:01.
" Open this file in Vim and run :source % to restore your session.

if exists('g:syntax_on') != 1 | syntax on | endif
if exists('g:did_load_filetypes') != 1 | filetype on | endif
if exists('g:did_load_ftplugin') != 1 | filetype plugin on | endif
if exists('g:did_indent_on') != 1 | filetype indent on | endif
if &background != 'dark'
	set background=dark
endif
if !exists('g:colors_name') || g:colors_name != 'OceanicNext' | colorscheme OceanicNext | endif
call setqflist([{'lnum': 0, 'col': 0, 'pattern': '', 'valid': 1, 'vcol': 0, 'nr': -1, 'type': '', 'module': '', 'filename': '/Users/jeromefaria/Work/helpr/code/helprapp/platforms/ios/cordova/lib/BridgingHeader.js', 'text': ''}, {'lnum': 0, 'col': 0, 'pattern': '', 'valid': 1, 'vcol': 0, 'nr': -1, 'type': '', 'module': '', 'filename': '/Users/jeromefaria/Work/helpr/code/helprapp/node_modules/pako/lib/zlib/gzheader.js', 'text': ''}, {'lnum': 0, 'col': 0, 'pattern': '', 'valid': 1, 'vcol': 0, 'nr': -1, 'type': '', 'module': '', 'filename': '/Users/jeromefaria/Work/helpr/code/helprapp/node_modules/cordova-ios/bin/templates/scripts/cordova/lib/BridgingHeader.js', 'text': ''}, {'lnum': 0, 'col': 0, 'pattern': '', 'valid': 1, 'vcol': 0, 'nr': -1, 'type': '', 'module': '', 'filename': '/Users/jeromefaria/Work/helpr/code/helprapp/node_modules/har-schema/lib/header.json', 'text': ''}, {'lnum': 0, 'col': 0, 'pattern': '', 'valid': 1, 'vcol': 0, 'nr': -1, 'type': '', 'module': '', 'filename': '/Users/jeromefaria/Work/helpr/code/helprapp/node_modules/less/lib/source-map/source-map-header.js', 'text': ''}, {'lnum': 0, 'col': 0, 'pattern': '', 'valid': 1, 'vcol': 0, 'nr': -1, 'type': '', 'module': '', 'filename': '/Users/jeromefaria/Work/helpr/code/helprapp/node_modules/pacote/node_modules/tar/lib/header.js', 'text': ''}, {'lnum': 0, 'col': 0, 'pattern': '', 'valid': 1, 'vcol': 0, 'nr': -1, 'type': '', 'module': '', 'filename': '/Users/jeromefaria/Work/helpr/code/helprapp/node_modules/jszip/lib/license_header.js', 'text': ''}, {'lnum': 0, 'col': 0, 'pattern': '', 'valid': 1, 'vcol': 0, 'nr': -1, 'type': '', 'module': '', 'filename': '/Users/jeromefaria/Work/helpr/code/helprapp/node_modules/adm-zip/headers/mainHeader.js', 'text': ''}, {'lnum': 0, 'col': 0, 'pattern': '', 'valid': 1, 'vcol': 0, 'nr': -1, 'type': '', 'module': '', 'filename': '/Users/jeromefaria/Work/helpr/code/helprapp/node_modules/adm-zip/headers/entryHeader.js', 'text': ''}, {'lnum': 0, 'col': 0, 'pattern': '', 'valid': 1, 'vcol': 0, 'nr': -1, 'type': '', 'module': '', 'filename': '/Users/jeromefaria/Work/helpr/code/helprapp/node_modules/tar/lib/header.js', 'text': ''}, {'lnum': 0, 'col': 0, 'pattern': '', 'valid': 1, 'vcol': 0, 'nr': -1, 'type': '', 'module': '', 'filename': '/Users/jeromefaria/Work/helpr/code/helprapp/node_modules/tar/lib/extended-header.js', 'text': ''}, {'lnum': 0, 'col': 0, 'pattern': '', 'valid': 1, 'vcol': 0, 'nr': -1, 'type': '', 'module': '', 'filename': '/Users/jeromefaria/Work/helpr/code/helprapp/node_modules/caniuse-lite/data/features/clear-site-data-header.js', 'text': ''}, {'lnum': 0, 'col': 0, 'pattern': '', 'valid': 1, 'vcol': 0, 'nr': -1, 'type': '', 'module': '', 'filename': '/Users/jeromefaria/Work/helpr/code/helprapp/node_modules/fsevents/node_modules/tar/lib/header.js', 'text': ''}])
let SessionLoad = 1
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~/Work/linkfire/code/lnkfi.re
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +13 _layouts/default.html
badd +39 _config.yml
badd +1 ~/dotfiles/tmuxinator/l
badd +69 ~/dotfiles/tmuxinator/l.yml
badd +1 index.md
badd +5 _includes/head.html
badd +1 _includes/header.html
badd +1 _includes/lists.html
badd +1 assets/.gitkeep
badd +232 ~/dotfiles/vim/misc.vim
badd +2 _posts/week52.md
badd +1 _pages/week23.md
badd +1 assets/main.js
badd +5 _includes/footer.html
badd +1 _pages
badd +1 ~/Work/linkfire/code/lnkfi.re
badd +8 _data/week53.yml
badd +6 _pages/2019/week52.md
badd +3 _data/2019/52.yml
badd +1 _data/2019/23.json
badd +1 _data/2019
argglobal
%argdel
edit _config.yml
set splitbelow splitright
wincmd _ | wincmd |
vsplit
wincmd _ | wincmd |
vsplit
2wincmd h
wincmd w
wincmd w
wincmd t
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe 'vert 1resize ' . ((&columns * 76 + 115) / 231)
exe 'vert 2resize ' . ((&columns * 77 + 115) / 231)
exe 'vert 3resize ' . ((&columns * 76 + 115) / 231)
argglobal
setlocal fdm=expr
setlocal fde=Foldexpr_markdown(v:lnum)
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=1
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 39 - ((34 * winheight(0) + 22) / 44)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
39
normal! 014|
wincmd w
argglobal
if bufexists("_pages/2019/week52.md") | buffer _pages/2019/week52.md | else | edit _pages/2019/week52.md | endif
setlocal fdm=indent
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=4
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 7 - ((6 * winheight(0) + 22) / 44)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
7
normal! 0
lcd ~/Work/linkfire/code/lnkfi.re
wincmd w
argglobal
if bufexists("~/Work/linkfire/code/lnkfi.re/_includes/lists.html") | buffer ~/Work/linkfire/code/lnkfi.re/_includes/lists.html | else | edit ~/Work/linkfire/code/lnkfi.re/_includes/lists.html | endif
setlocal fdm=indent
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=5
setlocal fml=1
setlocal fdn=20
setlocal fen
3
silent! normal! zo
9
silent! normal! zo
11
silent! normal! zo
16
silent! normal! zo
let s:l = 5 - ((4 * winheight(0) + 22) / 44)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
5
normal! 05|
wincmd w
3wincmd w
exe 'vert 1resize ' . ((&columns * 76 + 115) / 231)
exe 'vert 2resize ' . ((&columns * 77 + 115) / 231)
exe 'vert 3resize ' . ((&columns * 76 + 115) / 231)
tabnext 1
if exists('s:wipebuf') && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
"   silent exe 'bwipe ' . s:wipebuf
endif
" unlet! s:wipebuf
set winheight=1 winwidth=20 winminheight=1 winminwidth=1 shortmess=filnxtToOF
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save

" Support for special windows like quick-fix and plug-in windows.
" Everything down here is generated by vim-session (not supported
" by :mksession out of the box).

3wincmd w
tabnext 1
if exists('s:wipebuf')
  if empty(bufname(s:wipebuf))
if !getbufvar(s:wipebuf, '&modified')
  let s:wipebuflines = getbufline(s:wipebuf, 1, '$')
  if len(s:wipebuflines) <= 1 && empty(get(s:wipebuflines, 0, ''))
    silent execute 'bwipeout' s:wipebuf
  endif
endif
  endif
endif
doautoall SessionLoadPost
unlet SessionLoad
" vim: ft=vim ro nowrap smc=128
