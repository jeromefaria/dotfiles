#!/usr/bin/env zsh
# Directory shortcuts - quick navigation to common folders

# Home directories
alias h="cd $HOME"
alias home="cd $HOME"
alias desk="cd $HOME/Desktop"
alias docs="cd $HOME/Documents"
alias down="cd $HOME/Downloads"
alias movies="cd $HOME/Movies"
alias music="cd $HOME/Music"
alias pics="cd $HOME/Pictures"

# Work directories
alias work="cd $HOME/Work"
alias blog="cd $WORK/jeromefaria.github.io"
# $PROJECTS lives on the audio volume, so it is personal-only like the block
# further down; on a work machine use the repo you are actually working in.
[[ "$DOTFILES_PROFILE" == "personal" ]] && alias projects="cd $PROJECTS"

# System directories
alias tmp="cd /private/tmp"
alias dotfiles="cd $DOTFILES"

# External volumes and cloud storage. Only on this user's own machine: the
# variables behind them are set in zshrc under the same profile gate, and an
# alias built on an unset variable expands to a bare `cd`, which silently goes
# home instead of failing. The generic shortcuts above stay everywhere.
if [[ "$DOTFILES_PROFILE" == "personal" ]]; then
  alias archive="cd $ARCHIVE"
  alias audio="cd $AUDIO"
  alias media="cd $MEDIA"
  alias portable="cd $PORTABLE"
  alias video="cd $VIDEO"

  alias drive="cd $DRIVE"
  alias shared="cd $DRIVE/Shared"
  alias mobile="cd $MOBILE"
  alias icloud="cd $MOBILE/com~apple~CloudDocs"
fi
