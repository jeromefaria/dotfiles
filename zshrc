# Volumes
export ARCHIVE="/Volumes/Archive"
export AUDIO="/Volumes/Audio"
export MEDIA="/Volumes/Media"
export PORTABLE="/Volumes/Portable"
export VIDEO="/Volumes/Video"

# Folders
export DRIVE="$ARCHIVE/Drive"
export DOTFILES="$HOME/dotfiles"
export DOWNLOADS="$HOME/Downloads"
export MOBILE="$HOME/Library/Mobile\ Documents"
export PROJECTS="$AUDIO/Audio/Projects"
export SHARED="$DRIVE/Shared"
export WORK="$HOME/Work"

# ZSH settings
ZSH=$HOME/.oh-my-zsh
ZSH_THEME=""

# ZSH plugins
plugins=(git macos encode64 web-search last-working-dir git-flow-completion zsh-syntax-highlighting zsh-autosuggestions git-open brew omz-git zsh-vi-mode)

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

export ZVM_VI_ESCAPE_BINDKEY=jk
ZVM_CURSOR_STYLE_ENABLED=false
zvm_after_init_commands+=('bindkey "^ " autosuggest-accept')
zvm_after_init_commands+=('[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh')

# PATHS
export PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:~/.local/bin

# export PATH="/usr/local/opt/node@10/bin:$PATH"
# export PATH="/usr/local/opt/node@12/bin:$PATH"
# export PATH="/usr/local/opt/node@14/bin:$PATH"
export PATH="/usr/local/opt/node@22/bin:$PATH"

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

# Warp Terminal settings for ZSH
printf '\eP$f{"hook": "SourcedRcFileForWarp", "value": { "shell": "zsh"}}\x9c'

# cyrus-sasl homebrew version to fix neomutt
export PATH="/opt/homebrew/opt/cyrus-sasl/sbin:$PATH"

# NVM configuration
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Day One CLI
export DAYONE_APP_PATH="/Applications/Day One.app"
# fnm fast node manager
eval "$(fnm env --use-on-cd --shell zsh --version-file-strategy=recursive)"

##########
# HISTORY
##########

HISTFILE=$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

# Immediately append to history file:
setopt INC_APPEND_HISTORY

# Record timestamp in history:
setopt EXTENDED_HISTORY

# Expire duplicate entries first when trimming history:
setopt HIST_EXPIRE_DUPS_FIRST

# Dont record an entry that was just recorded again:
setopt HIST_IGNORE_DUPS

# Delete old recorded entry if new entry is a duplicate:
setopt HIST_IGNORE_ALL_DUPS

# Do not display a line previously found:
setopt HIST_FIND_NO_DUPS

# Dont record an entry starting with a space:
setopt HIST_IGNORE_SPACE

# Dont write duplicate entries in the history file:
setopt HIST_SAVE_NO_DUPS

# Share history between all sessions:
setopt SHARE_HISTORY

# Execute commands using history (e.g.: using !$) immediatel:
unsetopt HIST_VERIFY
