command FormatJSON %!python -m json.tool
command RemoveEmptyLines %s/\v\n{2,}/\r/gge | norm dd
command StripWhiteSpace %s/\s\+$//gge
