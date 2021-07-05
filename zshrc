# Variables
export ARCHIVE="/Volumes/Archive"
export AUDIO="/Volumes/Audio"
export DOTFILES="$HOME/dotfiles"
export DOWNLOADS="$HOME/Downloads"
export DRIVE="/Volumes/Drive"
export MOBILE="$HOME/Library/Mobile\ Documents"
export WORK="$HOME/Work"

# ZSH settings
ZSH=$HOME/.oh-my-zsh
ZSH_THEME=""

# ZSH plugins
plugins=(git osx encode64 web-search last-working-dir git-flow-completion zsh-syntax-highlighting vi-mode zsh-autosuggestions git-open brew omz-git)

# ZSH INTERACTIVE CD
source $ZSH/plugins/zsh-interactive-cd/zsh-interactive-cd.plugin.zsh
export PATH="/usr/local/sbin:$PATH"

# SOURCES
source $ZSH/oh-my-zsh.sh
source $DOTFILES/aliases.sh
source $DOTFILES/functions.sh
source $DOTFILES/linkfire

# EDITOR
export VISUAL=nvim
export EDITOR="$VISUAL"

# MAN PAGES
export MANPAGER='nvim +Man!'

# HISTORY
export HISTCONTROL=ignorespace

# BINDINGS
bindkey '^ ' autosuggest-accept
bindkey -M menuselect '^[[Z' reverse-menu-complete
bindkey -M viins 'jj' vi-cmd-mode

# PATHS
export PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:~/.local/bin

export PATH="/usr/local/opt/node@10/bin:$PATH"
export PATH="/usr/local/opt/ruby/bin:$PATH"


# CUSTOM
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

## FASD
eval "$(fasd --init auto)"

## HUB
eval "$(hub alias -s)"

## POWERLINE
if [[ -r ~/.local/lib/python2.7/site-packages/powerline/bindings/zsh/powerline.zsh ]]; then
  source ~/.local/lib/python2.7/site-packages/powerline/bindings/zsh/powerline.zsh
fi

## RTV
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

fpath=(~/.zsh/completions $fpath)

autoload -U compinit && compinit

## FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Initialise rbenv
eval "$(rbenv init -)"

# Initialise Starship
eval "$(starship init zsh)"

source $HOME/Library/Preferences/org.dystroy.broot/launcher/bash/br
