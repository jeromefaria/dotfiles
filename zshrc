# ZSH settings
ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"
plugins=(git osx encode64 web-search last-working-dir git-flow-completion zsh-syntax-highlighting vi-mode zsh-autosuggestions git-open brew colored-man-pages)

## FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ZSH INTERACTIVE CD
source $ZSH/plugins/zsh-interactive-cd/zsh-interactive-cd.plugin.zsh
export PATH="/usr/local/sbin:$PATH"

# SOURCES
source $ZSH/oh-my-zsh.sh
source ~/dotfiles/aliases.sh
source ~/dotfiles/functions.sh

# EDITOR
export VISUAL=nvim
export EDITOR="$VISUAL"

# BINDINGS
bindkey '^ ' autosuggest-accept
bindkey -M menuselect '^[[Z' reverse-menu-complete
bindkey -M viins 'jj' vi-cmd-mode

# PATHS
export PATH=$PATH:/usr/local/bin:$PATH:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/opt/ruby/bin:~/.local/bin
# export ANDROID_HOME=/Users/jeromefaria/Library/Android/sdk
# export PATH=$PATH:/Users/jeromefaria/Library/Android/sdk/platform-tools:/Users/jeromefaria/Library/Android/sdk/build-tools/28.0.2:/Users/jeromefaria/Library/Android/sdk/emulator:/Users/jeromefaria/Library/Android/sdk/emulator
export PATH="/usr/local/opt/node@10/bin:$PATH"

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
