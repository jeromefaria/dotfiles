# Font cache reset to fix an old bug in chrome
function resetfontcache() {
  atsutil databases -removeUser;
  sudo atsutil databases -remove;
  atsutil server -shutdown;
  atsutil server -ping;
}

# Run maintenance scripts and purge used memory
function periodic() {
  sudo periodic daily weekly monthly;
  purge;
}

# Base64 encoding
function enc(){
  openssl base64 < $1 | tr -d '\n' | pbcopy
}

# Base64 decoding
function dec(){
  openssl base64 > $1 | tr -d '\n' | pbcopy
}

# Self update nodejs
function upgradenode {
  sudo npm cache clean -f;
  sudo npm install -g n;
  sudo n stable;
}

# Create a new directory and enter it
function mkd() {
  mkdir -p "$@" && cd "$_";
}

# Change working directory to the top-most Finder window location
function cdf() { # short for `cdfinder`
  cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')";
}

# Determine size of a file or total size of a directory
function fs() {
  if du -b /dev/null > /dev/null 2>&1; then
    local arg=-sbh;
  else
    local arg=-sh;
  fi
  if [[ -n "$@" ]]; then
    du $arg -- "$@";
  else
    du $arg .[^.]* ./*;
  fi;
}

# Create a data URL from a file
function dataurl() {
  local mimeType=$(file -b --mime-type "$1");
  if [[ $mimeType == text/* ]]; then
    mimeType="${mimeType};charset=utf-8";
  fi
  echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')";
}

# Start an HTTP server from a directory, optionally specifying the port
function server() {
  local port="${1:-8000}";
  sleep 1 && open "http://localhost:${port}/" &
  # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
  # And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
  python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port";
}

# Start a PHP server from a directory, optionally specifying the port
# (Requires PHP 5.4.0+.)
function phpserver() {
  local port="${1:-4000}";
  local ip=$(ipconfig getifaddr en1);
  sleep 1 && open "http://${ip}:${port}/" &
  php -S "${ip}:${port}";
}

# Run `dig` and display the most useful info
function digga() {
  dig +nocmd "$1" any +multiline +noall +answer;
}

# `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
function tre() {
  tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX;
}

# Grab all href links from a webpage
function links() {
  curl $1 | grep -o -E 'href="([^"#]+)"' | cut -d'"' -f2
}

# Convert flac to mp3
function flac2mp3() {
  for a in *.flac; do < /dev/null ffmpeg -i "$a" -qscale:a 0 "${a[@]/%flac/mp3}"; done
}

# Convert flac to alac
function flac2alac() {
  for a in *.flac; do < /dev/null ffmpeg -i "$a" -vn -c:a alac "${a[@]/%flac/m4a}"; done
}

# Read specific line from file
function rl() {
  head -$2 $1 | tail -1
}

# Runs a processing project from the command line
function p5() {
  processing-java --sketch=$PWD --run
}

# Clear Finder Go To History
function clearFinderHistory() {
  defaults delete com.apple.finder GoToField
  defaults delete com.apple.finder GoToFieldHistory
}

# Kill and restart Touch Bar
function restartTouchBar() {
  sudo pkill "Touch Bar agent";
  sudo killall "ControlStrip";
}

# Open the Jira ticket for the current branch
function oj() {
  if [ -d .git ]
  then
    open https://linkfire.atlassian.net/browse$(git branch | egrep "\*" | egrep -o "\/\w+\-\d+")
  else
    return 1
  fi;
}

# Get the date of the current latest commit
function ggd() {
  if [ -d .git ]
  then
    g show | awk 'NR==3' | egrep "Date\:" | cut -d " " -f4-9 | tr "\n" " "
  else
    return 1
  fi;
}

# Remove tracking branches no longer on remote
function gdb() {
  if [ -d .git ]
  then
    git fetch -p; for branch in $(git branch -vv | grep ': gone]' | awk '{print $1}'); do git branch -D $branch; done
  else
    return 1
  fi;
}


# Get app version
function appver() {
  plutil -p /Applications/$1.app/Contents/Info.plist | egrep -i CFBundleShortVersionString | awk '{print $3}' 
}

# Path to Spotifyd plist file
SPOTIFYD="/Library/LaunchDaemons/rustlang.spotifyd.plist"

# Start spotifyd daemon
function startspotifyd() {
  sudo launchctl load -w $SPOTIFYD && sudo launchctl start $SPOTIFYD
}

# Stop spotifyd daemon
function stopspotifyd() {
  sudo launchctl unload -w $SPOTIFYD && sudo launchctl stop $SPOTIFYD
}

# Optimise and inline svg icons. Output to stdout. Pipe into $EDITOR to clean up.
function svg2css() {
  svgo * 1>/dev/null 1>/dev/null
  for i in *
  do
    echo ."${i%.*} {\n  background-image: url('data:image/svg+xml;base64,$(\cat $i | encode64)');\n}\n"
  done
}

# rsync a file/folder to a new location and removes the origin once finished
function sync() {
  rsync -rzHPX --append-verify --remove-source-files $1 $2
}

# Generate a random number between interval
function randNum() {
  echo $(($1 + RANDOM % $2))
}
