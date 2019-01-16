# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Uncomment this to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how often before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want to disable command autocorrection
# DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much,
# much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git svn sublime osx encode64 web-search last-working-dir git-flow-completion zsh-syntax-highlighting vi-mode zsh-autosuggestions git-open)

source $ZSH/oh-my-zsh.sh
source ~/dotfiles/aliases.sh
source ~/dotfiles/functions.sh
source ~/.oh-my-zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.oh-my-zsh/t-completion/t-completion.zsh

# Customize to your needs...
export PATH=$PATH:/usr/local/bin:$PATH:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/opt/ruby/bin:~/.local/bin

# Android SDK
export ANDROID_HOME=/Users/jeromefaria/Library/Android/sdk
export PATH=$PATH:/Users/jeromefaria/Library/Android/sdk/platform-tools:/Users/jeromefaria/Library/Android/sdk/build-tools/28.0.2:/Users/jeromefaria/Library/Android/sdk/emulator:/Users/jeromefaria/Library/Android/sdk/emulator

# Z
. /usr/local/etc/profile.d/z.sh

# Crontab
export EDITOR=vim
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Powerline stuff
if [[ -r ~/.local/lib/python2.7/site-packages/powerline/bindings/zsh/powerline.zsh ]]; then
  source ~/.local/lib/python2.7/site-packages/powerline/bindings/zsh/powerline.zsh
fi

# Go
export PATH=$PATH:/usr/local/opt/go/libexec/bin

# zsh syntax highlighting
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# key bindings
bindkey '^ ' autosuggest-accept
bindkey -M menuselect '^[[Z' reverse-menu-complete
bindkey -M viins 'jj' vi-cmd-mode

# Ruby Version Manager
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"  # This loads RVM into a shell session.
export rvmsudo_secure_path=1

# Fix Python version for RTV
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zsh interactive cd
source ~/.oh-my-zsh/plugins/zsh-interactive-cd/zsh-interactive-cd.plugin.zsh
export PATH="/usr/local/sbin:$PATH"

# Fasd
eval "$(fasd --init auto)"

# hub mapping for git
eval "$(hub alias -s)"

# oh my zsh fix
export ZSH=$HOME/.oh-my-zsh

# Set Neovim as the default editor
export VISUAL=nvim
export EDITOR="$VISUAL"

fpath=(~/.zsh/completions $fpath)
autoload -U compinit && compinit
