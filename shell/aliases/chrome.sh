#!/usr/bin/env zsh
# Google Chrome development aliases - testing and debugging

# Chrome executables
alias chrome='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
alias canary='/Applications/Google\ Chrome\ Canary.app/Contents/MacOS/Google\ Chrome\ Canary'

# Chrome development modes
alias chromeunsafe="open /Applications/Google\ Chrome\ Canary.app --args --incognito --disable-web-security"
alias chromedev="open /Applications/Google\ Chrome.app --args --incognito --disable-web-security"
alias cdv="open /Applications/Google\ Chrome\ Canary.app --args --disable-web-security --user-data-dir=\"/tmp/chrome_dev\" --incognito"
alias cdvi="open /Applications/Google\ Chrome\ Canary.app --args --incognito --disable-web-security --user-data-dir --auto-open-devtools-for-tabs"
alias newchromedev="open -n -a /Applications/Google\ Chrome.app --args --user-data-dir=\"/tmp/chrome_dev_session\" --incognito --disable-web-security"
alias ncd="open -n -a /Applications/Google\ Chrome.app --args --user-data-dir=\"/tmp/chrome_dev_session\" --incognito --disable-web-security --auto-open-devtools-for-tabs"

# Chrome control script
alias chromectrl="$HOME/Work/github/chrome-control/chrome.js"

# Kill Chrome tabs to free memory
alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"
