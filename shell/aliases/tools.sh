#!/usr/bin/env zsh
# Modern CLI tool remappings - replacements for traditional Unix tools
#
# Note: Aliases are only created if the target command is available.
# This prevents errors when optional tools are not installed.

# File listing with eza (modern ls replacement)
if command -v eza &> /dev/null; then
  alias ls="eza"
  alias l="eza"
  alias la="eza -lah --git"
  alias ll="eza -lh --git"
  alias lls="eza -ls=size --git"
  alias lt="eza -lahs=date --git"
fi

# Better alternatives to standard tools
command -v bat &> /dev/null && alias cat="bat"
command -v fd &> /dev/null && alias find="fd"
command -v sd &> /dev/null && alias sed="sd"
command -v htop &> /dev/null && alias top="sudo htop"
command -v prettyping &> /dev/null && alias ping='prettyping --nolegend'
command -v ncdu &> /dev/null && alias du="ncdu --color dark -x --exclude .git --exclude node_modules"
command -v tokei &> /dev/null && alias cloc="tokei"

# Text editor
command -v nvim &> /dev/null && alias vim="nvim"

# Mail client
command -v neomutt &> /dev/null && alias mutt="neomutt"

# Music player
command -v musikcube &> /dev/null && alias mus="musikcube"

# Help and documentation
command -v tldr &> /dev/null && alias help="tldr"

# File operations
if command -v trash &> /dev/null; then
  alias trash="trash -F"
  alias tvf="trash -vF"
fi

# Dark mode toggle (macOS specific)
command -v dark-mode &> /dev/null && alias dm="dark-mode"

# Media download
command -v youtube-dl &> /dev/null && alias ydl="youtube-dl"

# Disk image utility (macOS specific)
command -v hdiutil &> /dev/null && alias hd="hdiutil"

# FZF previews
if command -v fzf &> /dev/null && command -v bat &> /dev/null; then
  alias preview="fzf --preview 'bat --color \"always\" {}'"
fi

# Volume listing (uses eza if available, falls back to standard ls)
if command -v eza &> /dev/null; then
  alias vol="eza /Volumes"
else
  alias vol="ls /Volumes"
fi

# Archive operations (standard utilities)
alias zi="zipinfo"
alias uz="unzip -o"
command -v unrar &> /dev/null && alias ux="unrar x"
command -v unrar &> /dev/null && alias ui="unrar l"

# Weather (requires curl)
alias weather="curl -4 http://wttr.in"

# Beets music library
if command -v beet &> /dev/null; then
  alias b="beet"
  alias bmp="beet -c ~/.config/beets/config-mp3.yaml"
fi
