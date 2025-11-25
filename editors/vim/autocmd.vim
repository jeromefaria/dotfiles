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
