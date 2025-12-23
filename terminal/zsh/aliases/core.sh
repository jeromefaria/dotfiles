#!/usr/bin/env zsh
# Core system aliases - navigation, basic commands, and system operations

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias -- -="cd -"

# Use zoxide for smart directory jumping
alias cd="z"

# System operations
alias cl="clear"
alias reload="exec ${SHELL} -l"

# Clipboard operations
alias pbc="pbcopy"
alias pbp="pbpaste"
alias copy="tr -d '\n' | pbcopy"
alias cdir="pwd | tr -d '\n' | pbcopy"

# File operations
alias o="open"

# Colored grep output
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Print PATH entries on separate lines
alias path='echo -e ${PATH//:/\\n}'

# Enable aliases to be sudo'ed
alias sudo='sudo '

# Get week number
alias week='date +%V'

# Encoding utilities
alias rot13="tr 'A-Za-z' 'N-ZA-Mn-za-m'"
alias rot5="tr '0-9' '5-90-4'"
alias rotten="tr 'A-Za-z0-9' 'N-ZA-Mn-za-m5-90-4'"
alias urlencode='python3 -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1]));"'

# JSON prettify
alias json='python -m json.tool'
