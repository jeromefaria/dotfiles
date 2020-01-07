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

}

# Downloads YouTube videos
function ydl(){
  youtube-dl -ciw -o "%(title)s.%(ext)s" $1
}

# Open with
function oa(){
  open -a $1 $2
}

# Grab all href links from a webpage
function grab() {
  curl $1 | grep -o -E 'href="([^"#]+)"' | cut -d'"' -f2
}

# Convert flac to mp3
function flac2mp3() {
  for a in *.flac; do < /dev/null ffmpeg -i "$a" -qscale:a 0 "${a[@]/%flac/mp3}"; done
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
