# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# System
alias ll="ls -lah"
alias lt="ls -laht"
alias lls="ls -lS"
alias cl="clear"
alias rf="rm -rf"
alias df="df -H"
alias copy="tr -d '\n' | pbcopy"
alias pbc="pbcopy"
alias pbp="pbpaste"
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

# Remaps
alias cat="bat"
alias ping='prettyping --nolegend'
alias preview="fzf --preview 'bat --color \"always\" {}'"
# add support for ctrl+o to open selected file in VS Code
export FZF_DEFAULT_OPTS="--bind='ctrl-o:execute(vim {})+abort'"
alias top="sudo htop" # alias top and fix high sierra bug
alias du="ncdu --color dark -x --exclude .giti --exclude node_modules"
alias help="tldr"
alias vim="nvim"

# Fasd
alias a='fasd -a'        # any
alias s='fasd -si'       # show / search / select
alias d='fasd -d'        # directory
alias f='fasd -f'        # file
alias sd='fasd -sid'     # interactive directory selection
alias sf='fasd -sif'     # interactive file selection
alias z='fasd_cd -d'     # cd, same functionality as j in autojump
alias zz='fasd_cd -d -i' # cd with interactive selection
alias v='f -e vim'       # quick opening files with vim
alias m='f -e mplayer'   # quick opening files with mplayer
alias o='a -e xdg-open'  # quick opening files with xdg-open

# Folders
alias home="cd ~/"
alias h="cd ~/"
alias desk="cd ~/Desktop"
alias down="cd ~/Downloads"
alias docs="cd ~/Documents"
alias pics="cd ~/Pictures"
alias work="cd ~/Work"
alias drive="cd /Volumes/Drive/Drive"
alias dotfiles="cd ~/dotfiles"
alias blog="cd ~/Work/blog"
alias mobile="cd ~/Library/Mobile\ Documents"
alias icloud="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs"

# Chrome
alias chromeunsafe="open /Applications/Google\ Chrome\ Canary.app --args --incognito --disable-web-security"
alias chromedev="open /Applications/Google\ Chrome.app --args --incognito --disable-web-security"
#alias cdv="open /Applications/Google\ Chrome\ Canary.app --args --disable-web-security --user-data-dir --auto-open-devtools-for-tabs"
alias cdv="open /Applications/Google\ Chrome\ Canary.app --args --disable-web-security --user-data-dir --incognito"
alias cdvi="open /Applications/Google\ Chrome\ Canary.app --args --incognito --disable-web-security --user-data-dir --auto-open-devtools-for-tabs"
alias newchromedev="open -n -a /Applications/Google\ Chrome.app --args --user-data-dir=\"/tmp/chrome_dev_session\" --incognito --disable-web-security"
alias ncd="open -n -a /Applications/Google\ Chrome.app --args --user-data-dir=\"/tmp/chrome_dev_session\" --incognito --disable-web-security --auto-open-devtools-for-tabs"

# Apps
alias pf="open -a Path\ Finder $1"
alias iaw="open -a iA\ Writer $1"
alias vlc="open -a VLC $1"
alias vdf="vim ~/dotfiles"
alias grammarly="open -a Grammarly"
alias tsm="transmission-remote"

# Vagrant
alias vg="vagrant"
alias vgu="vagrant up"
alias vgs="vagrant ssh"
alias vgh="vagrant halt"

# Ionic
alias is="ionic serve --no-open"
alias ic="ionic cordova"

# iOS
alias ipi="ionic cordova prepare ios"
alias ibi="ionic cordova build ios"
alias iri="ionic cordova run ios"
alias iril="ionic cordova run ios --lc"
alias iei="ionic cordova emulate ios"

# Android
alias iba="ionic cordova build android"
alias ira="ionic cordova run android"
alias iral="ionic cordova run android --lc"
alias iea="ionic cordova emulate android"

# Gulp
alias gw="gulp watch"
alias gs="gulp sass"

# Karma
alias ks="karma start"

# Eslint
alias el="eslint"

# NPM
alias nr="npm run"

# MySQL
alias mysqlstart="mysql.server start"
alias mysqlstop="mysql.server stop"

# Tmux
alias tmx="tmux new -s"
alias tmxa="tmux attach"
alias tmxl="tmux ls"

# Tmuxinator
alias mux="tmuxinator"

# Archives
alias zi="zipinfo"
alias uz="unzip -o"
alias ux="unrar x"
alias ui="unrar l"

# Git
alias gdc="git diff --name-only --diff-filter=U"
alias gstdf="git stash show -p $1"
alias gfl="git-flow"
alias gds="git diff --staged"
alias gdb="git fetch -p; for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do git branch -D $branch; done"
alias grp="git request-pull"

# FZF
alias gcob='git checkout $(git branch | fzf)'
alias fcd='cd $(fzf)'

# Brew
alias bu="brew update && brew upgrade"

# Jekyll
alias jk="jekyll"
alias jks="jekyll serve"
alias jkb="jekyll build"

# JSON prettify
alias json='python -m json.tool'

# Runs a simple http server on current directory
alias serve="http-server"

# Reload shell settings
alias reload="source ~/.zshrc"

# Copy current directory to clipboard
alias cdir="pwd | tr -d '\n' | pbcopy"

# Starts a python SimpleHTTPServer on current directory (deprecated, now using serve to run nodejs http server)
alias server="python -m SimpleHTTPServer"

# some stuff I grabbed from @lennyjpg at https://github.com/lennyjpg/dotfiles/blob/master/.aliases

# wifi controls
alias wifi="networksetup -setairportpower en1 on"
alias nofi="networksetup -setairportpower en1 off"

# hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# Empty the Trash on all mounted volumes and the main HDD
# Also, clear Apple’s System Logs to improve shell startup speed
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias ips="ifconfig -a | grep -o 'inet6\? \(\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\)\|[a-fA-F0-9:]\+\)' | sed -e 's/inet6* //'"

# Displays weather
alias weather="curl -4 http://wttr.in"
