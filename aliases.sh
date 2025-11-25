# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~" # `cd` is probably faster to type though
alias -- -="cd -"

# System
alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
# alias cd="z"
alias cl="clear"
alias copy="tr -d '\n' | pbcopy"
alias df="df -H"
alias l="eza"
alias la="eza -lah --git"
alias ll="eza -lh --git"
alias lls="eza -ls=size --git"
alias lt="eza -lahs=date --git"
alias o="open"
alias pbc="pbcopy"
alias pbp="pbpaste"
alias rf="rm -rf"
alias so="source"

# Always enable colored `grep` output
# Note: `GREP_OPTIONS="--color=auto"` is deprecated, hence the alias usage.
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Remaps
alias cat="bat"
alias ping='prettyping --nolegend'
alias preview="fzf --preview 'bat --color \"always\" {}'"
alias top="sudo htop" # alias top and fix high sierra bug
alias du="ncdu --color dark -x --exclude .giti --exclude node_modules"
alias help="tldr"
alias vim="nvim"
alias mutt="neomutt"
alias cloc="tokei"
alias ls="eza"
alias sed="sd"
alias trash="trash -F"
alias tvf="trash -vF"
alias dm="dark-mode"
alias ydl="youtube-dl"
alias hd="hdiutil"
alias find="fd"

# Fasd
alias a='fasd -a'        # any
alias s='fasd -si'       # show / search / select
alias d='fasd -d'        # directory
alias f='fasd -f'        # file
# alias sd='fasd -sid'     # interactive directory selection
alias sf='fasd -sif'     # interactive file selection
alias z='fasd_cd -d'     # cd, same functionality as j in autojump
alias zz='fasd_cd -d -i' # cd with interactive selection
# alias v='f -e vim'       # quick opening files with vim
# alias m='f -e mplayer'   # quick opening files with mplayer
# alias o='a -e xdg-open'  # quick opening files with xdg-open

# Folders
alias h="cd $HOME"
alias home="cd $HOME"
alias desk="cd $HOME/Desktop"
alias docs="cd $HOME/Documents"
alias down="cd $HOME/Downloads"
alias movies="cd $HOME/Movies"
alias music="cd $HOME/Music"
alias pics="cd $HOME/Pictures"
alias work="cd $HOME/Work"
alias archive="cd $ARCHIVE"
alias audio="cd $AUDIO"
alias drive="cd $DRIVE"
alias dotfiles="cd $DOTFILES"
alias blog="cd $WORK/blog"
alias mobile="cd $MOBILE"
alias icloud="cd $MOBILE/com~apple~CloudDocs"
alias tmp="cd /private/tmp"
alias vol="ls /Volumes"
alias shared="cd $DRIVE/Shared"
alias portable="cd $PORTABLE"
alias projects="cd $PROJECTS"
alias external="cd $EXTERNAL"
alias media="cd $MEDIA"

# Google Chrome
alias chrome='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
alias canary='/Applications/Google\ Chrome\ Canary.app/Contents/MacOS/Google\ Chrome\ Canary'
alias chromeunsafe="open /Applications/Google\ Chrome\ Canary.app --args --incognito --disable-web-security"
alias chromedev="open /Applications/Google\ Chrome.app --args --incognito --disable-web-security"
#alias cdv="open /Applications/Google\ Chrome\ Canary.app --args --disable-web-security --user-data-dir --auto-open-devtools-for-tabs"
alias cdv="open /Applications/Google\ Chrome\ Canary.app --args --disable-web-security --user-data-dir=\"/tmp/chrome_dev\" --incognito"
alias cdvi="open /Applications/Google\ Chrome\ Canary.app --args --incognito --disable-web-security --user-data-dir --auto-open-devtools-for-tabs"
alias newchromedev="open -n -a /Applications/Google\ Chrome.app --args --user-data-dir=\"/tmp/chrome_dev_session\" --incognito --disable-web-security"
alias ncd="open -n -a /Applications/Google\ Chrome.app --args --user-data-dir=\"/tmp/chrome_dev_session\" --incognito --disable-web-security --auto-open-devtools-for-tabs"
alias chromectrl="/Users/jeromefaria/Work/github/chrome-control/chrome.js"

# Kill all the tabs in Chrome to free up memory
# [C] explained: http://www.commandlinefu.com/commands/view/402/exclude-grep-from-your-grepped-output-of-ps-alias-included-in-description
alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"

# Docker
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

# Archives
alias zi="zipinfo"
alias uz="unzip -o"
alias ux="unrar x"
alias ui="unrar l"

# Git
alias gcan="git commit --amend --no-edit"
alias gdc="git diff --name-only --diff-filter=U"
alias gds="git diff --staged"
alias gfl="git-flow"
alias grp="git request-pull"
alias gstdf="git stash show -p $1"

# FZF
alias gcob='git checkout $(git branch | fzf)'
alias fcd='cd $(fzf)'

# Jekyll
alias jk="jekyll"
alias jks="bundle exec jekyll serve"
alias jkb="bundle exec jekyll build"

# JSON prettify
alias json='python -m json.tool'

# Reload the shell (i.e. invoke as a login shell)
alias reload="exec ${SHELL} -l"

# Copy current directory to clipboard
alias cdir="pwd | tr -d '\n' | pbcopy"

# some stuff I grabbed from @lennyjpg at https://github.com/lennyjpg/dotfiles/blob/master/.aliases

# wifi controls
alias wifi="networksetup -setairportpower en1 on"
alias nofi="networksetup -setairportpower en1 off"

# Show/hide hidden files in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# Empty the Trash on all mounted volumes and the main HDD.
# Also, clear Apple’s System Logs to improve shell startup speed.
# Finally, clear download history from quarantine. https://mths.be/bum
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl; sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'"

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Show active network interfaces
alias ifactive="ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active'"

# Flush Directory Service cache
alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"

# Clean up LaunchServices to remove duplicates in the “Open With” menu
alias lscleanup="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"

# Displays weather
alias weather="curl -4 http://wttr.in"

# Enable aliases to be sudo’ed
alias sudo='sudo '

# Get week number
alias week='date +%V'

# Get macOS Software Updates, and update installed Ruby gems, Homebrew, npm, and their installed packages
# alias update='sudo softwareupdate -i -a && mas upgrade && brew update && brew upgrade && brew upgrade --cask && brew cleanup && sudo npm install -g npm && sudo npm update -g && gem update --system && gem update && gem cleanup && omz update && tldr --update'
alias update='sudo -v && mas upgrade && brew update && brew upgrade --formulae && brew cu -ay && brew cleanup && sudo npm install -g npm && sudo npm update -g && gem update --system && gem update && gem cleanup && omz update && tldr --update'

# Trim new lines and copy to clipboard
alias c="tr -d '\n' | pbcopy"

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# URL-encode strings
alias urlencode='python3 -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1]));"'

# Stuff I never really use but cannot delete either because of http://xkcd.com/530/
alias stfu="osascript -e 'set volume output muted true'"
alias pumpitup="osascript -e 'set volume output volume 100'"

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'

# Remove Xcode device simulator data
alias cleanXcode="xcrun simctl delete unavailable"

# Verify all mounted volumes
alias verifyvolumes="for v in /Volumes/*; do m disk verify volume $v; done"

# Repair all mounted volumes
alias repairvolumes="for v in /Volumes/*; do m disk repair volume $v; done"

# Encode to ROT13
alias rot13="tr 'A-Za-z' 'N-ZA-Mn-za-m'"

# Encode to ROT5
alias rot5="tr '0-9' '5-90-4'"

# ROT13 for letters and ROT5 for numbers
alias rotten="tr 'A-Za-z0-9' 'N-ZA-Mn-za-m5-90-4'"

# Restart GPG agent
alias gpgrestart="gpgconf --kill gpg-agent"

# TODO
alias a2m="python3 ~/Work/github/aria-control-file-parser/aria2_to_magnet.py"
alias rbg="sqlite3 ~/Movies/rarbg_db.sqlite"
alias bmp="beet -c ~/.config/beets/config-mp3.yaml"
alias mus="musikcube"
alias b="beet"
alias checktransferlogs="cat /tmp/*.log|rg 'Download complete: /Volumes'"
alias sb="seamless bootstrap --all --clean"
