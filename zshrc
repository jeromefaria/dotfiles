# Variables
export ARCHIVE="/Volumes/Archive"
export AUDIO="/Volumes/External/Audio"
export DOTFILES="$HOME/dotfiles"
export DOWNLOADS="$HOME/Downloads"
export DRIVE="/Volumes/Drive"
export EXTERNAL="/Volumes/External"
export MOBILE="$HOME/Library/Mobile\ Documents"
export PORTABLE="/Volumes/Portable"
export PROJECTS="/Volumes/External/Audio/Projects"
export SHARED="$DRIVE/Shared"
export VIDEO="/Volumes/External/Video"
export WORK="$HOME/Work"

# ZSH settings
ZSH=$HOME/.oh-my-zsh
ZSH_THEME=""

# ZSH plugins
plugins=(git macos encode64 web-search last-working-dir git-flow-completion zsh-syntax-highlighting vi-mode zsh-autosuggestions git-open brew omz-git)

# ZSH INTERACTIVE CD
source $ZSH/plugins/zsh-interactive-cd/zsh-interactive-cd.plugin.zsh
export PATH="/usr/local/sbin:$PATH"

# SOURCES
source $ZSH/oh-my-zsh.sh
source $DOTFILES/aliases.sh
source $DOTFILES/functions.sh

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

# export PATH="/usr/local/opt/node@10/bin:$PATH"
# export PATH="/usr/local/opt/node@12/bin:$PATH"
export PATH="/usr/local/opt/node@14/bin:$PATH"

# export PATH="/usr/local/opt/ruby/bin:~/.gem/ruby/2.6.0/bin:$PATH"
export PATH="/usr/local/opt/ruby/bin:$PATH"

# export ANDROID_SDK=$HOME/Library/Android/sdk
# export PATH=$ANDROID_SDK/emulator:$ANDROID_SDK/tools:$PATH

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

# export FZF_DEFAULT_COMMAND="fd . $HOME"
# export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# export FZF_ALT_C_COMMAND="fd -t d . $HOME"

# Initialise rbenv
eval "$(rbenv init -)"

# Initialise Starship
eval "$(starship init zsh)"

source $HOME/Library/Preferences/org.dystroy.broot/launcher/bash/br
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

eval $(thefuck --alias)

# Supress Ruby warnings
export RUBYOPT=-W0
eval "$(/opt/homebrew/bin/brew shellenv)"

# 1Password CLI integration
OP_BIOMETRIC_UNLOCK_ENABLED=true

# BEETS ENV VARIABLE
BEETSDIR=~/.config/beets/
