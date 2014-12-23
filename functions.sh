# font cache reset to fix an old bug in chrome

function resetfontcache() {
  atsutil databases -removeUser;
  sudo atsutil databases -remove;
  atsutil server -shutdown;
  atsutil server -ping;
}

# run maintenance scripts and purge used memory

function cleanup() {
  echo "Running periodic scripts...";
  sudo periodic daily weekly monthly;
  echo "Periodic scripts done.";
  echo "Purging memory...";
  purge;
  echo "All good and clean!";
}

# base64 encoding

function enc(){
  openssl base64 < $1 | tr -d '\n' | pbcopy
}

# base64 decoding

function dec(){
  openssl base64 > $1 | tr -d '\n' | pbcopy
}

# fetch latest version of jquery, before I started using bower...

function getjquery {
  curl http://code.jquery.com/jquery-latest.min.js > $1
}

# self update nodejs

function upgradenode {
  sudo npm cache clean -f;
  sudo npm install -g n;
  sudo n stable;
}

# Create a new directory and enter it
function take() {
  mkdir $1
  cd $1
}

# Checks for MusicBrainz tag on MusicBrainz Picard
function brainz(){
  open -a "Musicbrainz Picard" $1
}

# Copies and opens in iTunes
function itunes(){
  open -a "iTunes" $1
}

# Convert audio files with Max
function max(){
  open /Applications/Max.app $1
}

# Downloads YouTube videos
function ydl(){
  youtube-dl -citw $1
}

# Open with
function oa(){
  open -a $1 $2
}

# Grab all href links from a webpage
function grab() {
  curl $1 | grep -o -E 'href="([^"#]+)"' | cut -d'"' -f2
}

# Start Yeoman server
function gs() {
  grunt serve &
}

# Start Yeoman server
function gsd() {
  grunt serve:dist &
}

# Kill Yeoman server
function ks() {
  jobs -l | awk '{print $3}' | xargs kill
}

# Convert flac to mp3
function flac2mp3() {
  for a in *.flac; do < /dev/null ffmpeg -i "$a" -qscale:a 0 "${a[@]/%flac/mp3}"; done
}

# Read specific line from file
function rl() {
  head -$2 $1 | tail -1
}