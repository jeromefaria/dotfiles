#!/usr/bin/env zsh
# Development environment aliases - Docker, Tmux, MySQL, Jekyll, etc.

# Docker Compose
alias dcu="docker compose up"
alias dcud="docker compose up -d"
alias dcd="docker compose down"
alias dcs="docker compose stop"
alias dcb="docker compose build"

# MySQL
alias mysqlstart="mysql.server start"
alias mysqlstop="mysql.server stop"

# Tmux
alias tmx="tmux new -s"
alias tmxa="tmux attach"
alias tmxl="tmux ls"
alias tmxpane="tmux resize-pane -D 100; resize-pane -U 10"

# Tmuxinator
alias mux="tmuxinator"

# Jekyll
alias jk="jekyll"
alias jks="bundle exec jekyll serve"
alias jkb="bundle exec jekyll build"

# Node.js / NPM system update
alias update='sudo -v && mas upgrade && brew update && brew upgrade --formulae && brew cu -ay && brew cleanup && sudo npm install -g npm && sudo npm update -g && gem update --system && gem update && gem cleanup && omz update && tldr --update'

# Project-specific (consider moving to project-local config)
alias sb="seamless bootstrap --all --clean"
alias a2m="python3 ~/Work/github/aria-control-file-parser/aria2_to_magnet.py"
alias rbg="sqlite3 ~/Movies/rarbg_db.sqlite"
alias checktransferlogs="cat /tmp/*.log|rg 'Download complete: /Volumes'"
