#!/bin/bash
set -e

declare -a PACKAGES=("brew" "cask" "gem" "mas" "npm" "pip")
clear

echo "Starting package list export..."
echo

# Check if commands exist before running
check_command() {
  local cmd=$1
  if ! command -v "$cmd" &> /dev/null; then
    echo "⚠️  Warning: $cmd not found, skipping..."
    return 1
  fi
  return 0
}

for package in "${PACKAGES[@]}"
do
  case $package in
    "brew")
      if check_command brew; then
        echo "📦 Exporting $package package list..."
        if brew list > "$package.log" 2>/dev/null; then
          echo "✅ Successfully exported $(wc -l < "$package.log") packages"
        else
          echo "❌ Failed to export $package packages"
        fi
      fi
      ;;
    "cask")
      if check_command brew; then
        echo "📦 Exporting $package package list..."
        if brew list --cask > "$package.log" 2>/dev/null; then
          echo "✅ Successfully exported $(wc -l < "$package.log") casks"
        else
          echo "❌ Failed to export $package packages"
        fi
      fi
      ;;
    "gem")
      if check_command gem; then
        echo "📦 Exporting $package package list..."
        if gem list | cut -d " " -f 1 > "$package.log" 2>/dev/null; then
          echo "✅ Successfully exported $(wc -l < "$package.log") gems"
        else
          echo "❌ Failed to export $package packages"
        fi
      fi
      ;;
    "mas")
      if check_command mas; then
        echo "📦 Exporting $package package list..."
        if mas list | awk '{print $1}' > "$package.log" 2>/dev/null; then
          echo "✅ Successfully exported $(wc -l < "$package.log") Mac App Store apps"
        else
          echo "❌ Failed to export $package packages"
        fi
      fi
      ;;
    "npm")
      if check_command npm; then
        echo "📦 Exporting $package package list..."
        if npm list -g --depth 0 2>/dev/null | cut -d " " -f2 | cut -d "@" -f1 | grep -E "[a-z]" | grep -Ev "UNMET" | tail -n +2 > "$package.log"; then
          echo "✅ Successfully exported $(wc -l < "$package.log") npm packages"
        else
          echo "❌ Failed to export $package packages"
        fi
      fi
      ;;
    "pip")
      if check_command pip3; then
        echo "📦 Exporting $package package list..."
        if pip3 list | cut -d " " -f 1 | grep -E "[a-z]" | tail -n +2 > "$package.log" 2>/dev/null; then
          echo "✅ Successfully exported $(wc -l < "$package.log") pip packages"
        else
          echo "❌ Failed to export $package packages"
        fi
      fi
      ;;
  esac
  echo
done

echo "✨ Package export complete!"

