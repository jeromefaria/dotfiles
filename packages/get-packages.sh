#!/bin/bash
declare -a PACKAGES=("brew" "cask" "gem" "mas" "npm" "pip");
clear

for package in ${PACKAGES[@]}
do
  case $package in
    "brew")
      echo "Downloading $package package list..."
      brew list > $package.log
      ;;
    "cask")
      echo "Downloading $package package list..."
      brew list --cask > "$package.log"
      ;;
    "gem")
      echo "Downloading $package package list..."
      gem list | cut -d " " -f 1 > $package.log
      ;;
    "mas")
      echo "Downloading $package package list..."
      mas list | awk '{print $1}' > $package.log
      ;;
    "npm")
      echo "Downloading $package package list..."
      npm list -g --depth 0 2>/dev/null | cut -d " " -f2 | cut -d "@" -f1 | egrep "[a-z]" | egrep -v "UNMET" | tail -n +2 > $package.log
      ;;
    "pip")
      echo "Downloading $package package list..."
      pip3 list | cut -d " " -f 1 | egrep "[a-z]" | tail -n +2 > $package.log
      ;;
  esac
done

