set -o vi
bind '"jk": vi-movement-mode'

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~" # `cd` is probably faster to type though
alias -- -="cd -"

# System
#alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
#alias cd="z"
alias cl="clear"
#alias copy="tr -d '\n' | pbcopy"
#alias df="df -H"
#alias l="eza"
#alias la="eza -lah --git"
#alias ll="eza -lh --git"
#alias lls="eza -ls=size --git"
#alias lt="eza -lahs=date --git"
#alias o="open"
#alias pbc="pbcopy"
#alias pbp="pbpaste"
alias rf="rm -rf"
alias so="source"

# Always enable colored `grep` output
# Note: `GREP_OPTIONS="--color=auto"` is deprecated, hence the alias usage.
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Folders
alias h="cd $HOME"
alias home="cd $HOME"
alias desk="cd $HOME/Desktop"
alias docs="cd $HOME/Documents"
alias down="cd $HOME/Downloads"

# Google Chrome
#alias chrome='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
#alias canary='/Applications/Google\ Chrome\ Canary.app/Contents/MacOS/Google\ Chrome\ Canary'
#alias chromeunsafe="open /Applications/Google\ Chrome\ Canary.app --args --incognito --disable-web-security"
#alias chromedev="open /Applications/Google\ Chrome.app --args --incognito --disable-web-security"
#alias cdv="open /Applications/Google\ Chrome\ Canary.app --args --disable-web-security --user-data-dir --auto-open-devtools-for-tabs"
#alias cdv="open /Applications/Google\ Chrome\ Canary.app --args --disable-web-security --user-data-dir=\"/tmp/chrome_dev\" --incognito"
#alias cdvi="open /Applications/Google\ Chrome\ Canary.app --args --incognito --disable-web-security --user-data-dir --auto-open-devtools-for-tabs"
#alias newchromedev="open -n -a /Applications/Google\ Chrome.app --args --user-data-dir=\"/tmp/chrome_dev_session\" --incognito --disable-web-security"
#alias ncd="open -n -a /Applications/Google\ Chrome.app --args --user-data-dir=\"/tmp/chrome_dev_session\" --incognito --disable-web-security --auto-open-devtools-for-tabs"
#alias chromectrl="/Users/jeromefaria/Work/github/chrome-control/chrome.js"

# Git
alias g="git"
alias gcan="git commit --amend --no-edit"
alias gdc="git diff --name-only --diff-filter=U"
alias gds="git diff --staged"
alias gfl="git-flow"
alias grp="git request-pull"
alias gstdf="git stash show -p $1"

# Reload the shell (i.e. invoke as a login shell)
alias reload="exec ${SHELL} -l"

# Copy current directory to clipboard
alias cdir="pwd | tr -d '\n' | pbcopy"


# Load Angular CLI autocompletion.
#source <(ng completion script)

# Run SSH Agent
env=~/.ssh/agent.env

agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }

agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ; }

agent_load_env

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
#agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

#if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    #agent_start
    #ssh-add
#elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    #ssh-add
#fi

#unset env
