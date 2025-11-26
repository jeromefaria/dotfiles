#!/usr/bin/env zsh
# Media conversion functions - audio and video utilities

# Convert FLAC to MP3
# Usage: flac2mp3 (run in directory with FLAC files)
function flac2mp3() {
  if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg not installed"
    return 1
  fi

  local count=0
  for a in *.flac; do
    if [[ -f "$a" ]]; then
      echo "Converting: $a"
      < /dev/null ffmpeg -i "$a" -qscale:a 0 "${a[@]/%flac/mp3}"
      ((count++))
    fi
  done

  if [[ $count -eq 0 ]]; then
    echo "No FLAC files found in current directory"
    return 1
  fi

  echo "Converted $count file(s)"
}

# Convert FLAC to ALAC (Apple Lossless)
# Usage: flac2alac (run in directory with FLAC files)
function flac2alac() {
  if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg not installed"
    return 1
  fi

  local count=0
  for a in *.flac; do
    if [[ -f "$a" ]]; then
      echo "Converting: $a"
      < /dev/null ffmpeg -i "$a" -vn -c:a alac "${a[@]/%flac/m4a}"
      ((count++))
    fi
  done

  if [[ $count -eq 0 ]]; then
    echo "No FLAC files found in current directory"
    return 1
  fi

  echo "Converted $count file(s)"
}
