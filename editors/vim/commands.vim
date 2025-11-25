command FormatJSON %!python3 -m json.tool
command RemoveEmptyLines %s/\v\n{2,}/\r/gge | norm dd
command StripWhiteSpace %s/\s\+$//gge
command WordCount !wc %
command SortInline :call setline(line('.'),join(sort(split(getline('.'))), ' '))
command BreakLine '<,'>s/, /,\r/gg
command CleanJSArray silent %s/"// | %s/\v,$// | normal ds[
command MD set filetype=markdown
command JS set filetype=javascript
command Docs cd ~/Documents
