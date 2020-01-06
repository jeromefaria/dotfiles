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
