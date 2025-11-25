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
