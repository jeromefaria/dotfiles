# ALIASES

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# System
alias ll="ls -lah"
alias lt="ls -laht"
alias cl="clear"
alias rf="rm -rf"
alias f="find"
alias v="vim"
alias copy="tr -d '\n' | pbcopy"
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"

# Folders 
alias home="cd ~/"
alias desk="cd ~/Desktop"
alias down="cd ~/Downloads"
alias docs="cd ~/Documents"
alias pics="cd ~/Pictures"
alias work="cd /Volumes/System/Users/jeromefaria/Work"
alias music="cd /Volumes/Music/iTunes/iTunes\ Media/Music"
alias dropbox="cd ~/Dropbox"
alias drive="cd ~/Drive"
alias dotfiles="cd ~/dotfiles"

# Work
alias helpr="/Users/jeromefaria/Work/helpr"

# Apps
alias chromeunsafe="open /Applications/Google\ Chrome\ Canary.app --args --incognito --disable-web-security"
alias chromedev="open /Applications/Google\ Chrome.app --args --incognito --disable-web-security"
#alias cdv="open /Applications/Google\ Chrome\ Canary.app --args --disable-web-security --user-data-dir --auto-open-devtools-for-tabs"
alias cdv="open /Applications/Google\ Chrome\ Canary.app --args --disable-web-security --user-data-dir --incognito"
alias cdvi="open /Applications/Google\ Chrome\ Canary.app --args --incognito --disable-web-security --user-data-dir --auto-open-devtools-for-tabs"
alias newchromedev="open -n -a /Applications/Google\ Chrome.app --args --user-data-dir=\"/tmp/chrome_dev_session\" --incognito --disable-web-security"
alias ncd="open -n -a /Applications/Google\ Chrome.app --args --user-data-dir=\"/tmp/chrome_dev_session\" --incognito --disable-web-security --auto-open-devtools-for-tabs"
alias pf="open -a Path\ Finder $1"
alias iaw="open -a iA\ Writer\ Pro $1"
alias ws="open -a WebStorm $1"
alias kdf="git difftool -y -t Kaleidoscope"
alias vlc="open -a VLC $1"
alias vdf="vim ~/dotfiles"

# Ionic
alias is="ionic serve -b"
alias iba="ionic build android"
alias ira="ionic run android"

# Gulp
alias gw="gulp watch"
alias gs="gulp sass"

# JSHint
alias jh="jshint"

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

# cat files with syntax highlighting
alias ccat="pygmentize -O style=native -g"

# Copy current directory to clipboard
alias cdir="pwd | tr -d '\n' | pbcopy"

# Run python script to tag mp3 files according to lastfm
alias mpt="python ~/Work/github/mp3tagger/tagger.py $1"

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
