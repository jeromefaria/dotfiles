#!/usr/bin/env zsh
# Modern CLI tool remappings - replacements for traditional Unix tools

# File listing with eza (modern ls replacement)
alias ls="eza"
alias l="eza"
alias la="eza -lah --git"
alias ll="eza -lh --git"
alias lls="eza -ls=size --git"
alias lt="eza -lahs=date --git"

# Better alternatives to standard tools
alias cat="bat"
alias find="fd"
alias sed="sd"
alias top="sudo htop"
alias ping='prettyping --nolegend'
alias du="ncdu --color dark -x --exclude .git --exclude node_modules"
alias cloc="tokei"

# Text editor
alias vim="nvim"

# Mail client
alias mutt="neomutt"

# Music player
alias mus="musikcube"

# Help and documentation
alias help="tldr"

# File operations
alias trash="trash -F"
alias tvf="trash -vF"

# Dark mode toggle
alias dm="dark-mode"

# Media download
alias ydl="youtube-dl"

# Disk image utility
alias hd="hdiutil"

# FZF previews
alias preview="fzf --preview 'bat --color \"always\" {}'"

# Volume listing
alias vol="ls /Volumes"

# Archive operations
alias zi="zipinfo"
alias uz="unzip -o"
alias ux="unrar x"
alias ui="unrar l"

# Weather
alias weather="curl -4 http://wttr.in"

# Beets music library
alias b="beet"
alias bmp="beet -c ~/.config/beets/config-mp3.yaml"
