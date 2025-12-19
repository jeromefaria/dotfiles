#!/usr/bin/env zsh
# Command palette - fuzzy searchable custom commands (like nvim :Commands)

# Main command palette function
# Keybinding: Ctrl-X Ctrl-P
palette() {
  # Define commands in format: "name:description:command"
  local commands=(
    # Text manipulation
    "format-json:Format JSON in clipboard:pbpaste | python3 -m json.tool | pbcopy && echo 'JSON formatted'"
    "format-json-file:Format JSON file:read '?File: ' file && python3 -m json.tool \$file > \$file.formatted && mv \$file.formatted \$file"
    "strip-whitespace:Remove trailing whitespace from files:find . -type f \( -name '*.sh' -o -name '*.md' -o -name '*.txt' \) -exec sed -i '' 's/[[:space:]]*\$//' {} +"
    "remove-empty-lines:Remove consecutive empty lines:find . -type f \( -name '*.sh' -o -name '*.md' \) -exec sed -i '' '/^\$/N;/^\\n\$/D' {} +"
    "lowercase:Convert clipboard to lowercase:pbpaste | tr '[:upper:]' '[:lower:]' | pbcopy"
    "uppercase:Convert clipboard to uppercase:pbpaste | tr '[:lower:]' '[:upper:]' | pbcopy"
    "trim:Trim whitespace from clipboard:pbpaste | sed 's/^[[:space:]]*//;s/[[:space:]]*\$//' | pbcopy"
    "sort-lines:Sort lines in clipboard:pbpaste | sort | pbcopy"
    "unique-lines:Get unique lines from clipboard:pbpaste | sort -u | pbcopy"
    "count-lines:Count lines in clipboard:pbpaste | wc -l"
    "count-words:Count words in clipboard:pbpaste | wc -w"
    "base64-encode:Base64 encode clipboard:pbpaste | base64 | pbcopy"
    "base64-decode:Base64 decode clipboard:pbpaste | base64 -d | pbcopy"
    "url-encode:URL encode clipboard:pbpaste | python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read()))' | pbcopy"
    "url-decode:URL decode clipboard:pbpaste | python3 -c 'import sys, urllib.parse; print(urllib.parse.unquote(sys.stdin.read()))' | pbcopy"

    # System maintenance
    "update-all:Update all system packages:update"
    "clean-brew:Clean Homebrew cache:brew cleanup --prune=all"
    "clean-npm:Clean npm cache:npm cache clean --force"
    "clean-docker:Clean Docker (containers, images, volumes):docker system prune -a --volumes"
    "disk-usage:Show disk usage by directory:du -sh * | sort -h"
    "disk-space:Show disk space:df -h"
    "memory-usage:Show memory usage:top -l 1 | head -n 10"
    "process-tree:Show process tree:pstree -p \$\$"
    "network-info:Show network info:ifconfig | grep inet"
    "listening-ports:Show listening ports:lsof -i -P | grep LISTEN"
    "dns-flush:Flush DNS cache:sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder"

    # File operations
    "find-large-files:Find largest files (top 20):find . -type f -exec du -h {} + | sort -rh | head -20"
    "find-old-files:Find files modified >30 days ago:find . -type f -mtime +30"
    "find-broken-symlinks:Find broken symbolic links:find . -type l ! -exec test -e {} \\; -print"
    "count-files:Count files in current directory:find . -type f | wc -l"
    "count-dirs:Count directories:find . -type d | wc -l"
    "file-extensions:List all file extensions:find . -type f | sed 's/.*\\.//' | sort -u"

    # Git operations
    "git-clean-branches:Remove merged branches:git branch --merged | grep -v '\\*\\|main\\|master\\|develop' | xargs -n 1 git branch -d"
    "git-undo-commit:Undo last commit (keep changes):git reset --soft HEAD~1"
    "git-stats:Show git repository stats:git log --all --shortstat --no-merges --since='1 year ago' | grep -E 'files? changed' | awk '{files+=\$1; inserted+=\$4; deleted+=\$6} END {print files,\"files changed,\",inserted,\"insertions(+),\",deleted,\"deletions(-)\"}'"
    "git-contributors:Show all contributors:git log --format='%aN' | sort -u"
    "git-recent-branches:Show recently used branches:git for-each-ref --sort=-committerdate --format='%(refname:short) (%(committerdate:relative))' refs/heads/ | head -10"
    "git-file-history:Show file history with diffs:read '?File: ' file && git log -p -- \$file"
    "git-who-wrote:Show who wrote most lines:git ls-files | xargs -n1 git blame --line-porcelain | sed -n 's/^author //p' | sort | uniq -c | sort -rn | head -10"

    # Development
    "server:Start HTTP server on port 8000:python3 -m http.server 8000"
    "server-port:Start HTTP server on custom port:read '?Port: ' port && python3 -m http.server \$port"
    "json-server:Start JSON server with file:read '?JSON file: ' file && json-server --watch \$file"
    "kill-port:Kill process on port:read '?Port: ' port && lsof -ti:\$port | xargs kill -9"
    "npm-update:Update npm packages:npm update && npm outdated"
    "node-version:Show node and npm versions:echo \"Node: \$(node --version)\" && echo \"NPM: \$(npm --version)\""

    # Configuration
    "edit-zshrc:Edit zsh config:nvim ~/dotfiles/shell/zshrc"
    "edit-nvim:Edit nvim config:nvim ~/dotfiles/config/nvim/init.lua"
    "edit-tmux:Edit tmux config:nvim ~/dotfiles/terminal/tmux.conf"
    "edit-git:Edit git config:nvim ~/.gitconfig"
    "edit-starship:Edit starship config:nvim ~/dotfiles/config/starship.toml"
    "reload-shell:Reload shell config:source ~/.zshrc && echo 'Shell reloaded'"
    "reload-tmux:Reload tmux config:tmux source-file ~/.tmux.conf && echo 'Tmux reloaded'"

    # Navigation
    "cd-project:Jump to project directory:z"
    "cd-dotfiles:Jump to dotfiles:cd ~/dotfiles"
    "cd-downloads:Jump to downloads:cd ~/Downloads"
    "cd-work:Jump to work directory:cd ~/Work"
    "cd-desktop:Jump to desktop:cd ~/Desktop"

    # Tmux
    "tmux-list:List tmux sessions:tmux list-sessions"
    "tmux-kill-all:Kill all tmux sessions:tmux kill-server"
    "tmux-kill-session:Kill tmux session:tmux list-sessions | fzf | cut -d: -f1 | xargs tmux kill-session -t"

    # History
    "history-stats:Show command history stats:history | awk '{print \$2}' | sort | uniq -c | sort -nr | head -20"
    "history-clear:Clear command history:echo '' > ~/.zsh_history && history -c"
    "history-search:Search command history:history | fzf"

    # Misc
    "weather:Show weather:curl wttr.in"
    "ip-external:Show external IP:curl -s ifconfig.me"
    "ip-internal:Show internal IP:ipconfig getifaddr en0"
    "qr-code:Generate QR code from clipboard:pbpaste | qrencode -t ansiutf8"
    "timer:Start countdown timer:read '?Minutes: ' min && echo \"Timer set for \$min minutes\" && sleep \$((min*60)) && echo 'Time is up!' && osascript -e 'display notification \"Timer finished!\" with title \"Timer\"'"
    "random-password:Generate random password:openssl rand -base64 32 | tr -d '=+/' | cut -c1-20 | pbcopy && echo 'Password copied to clipboard'"
  )

  # Use fzf to select command
  local selected=$(printf '%s\n' "${commands[@]}" |
    fzf --height 50% --reverse \
        --header="Command Palette (Ctrl-X Ctrl-P)" \
        --delimiter=":" \
        --preview='echo {3}' \
        --preview-window=up:3:wrap \
        --with-nth=1,2 \
        --bind 'ctrl-/:toggle-preview')

  if [[ -n "$selected" ]]; then
    local command=$(echo "$selected" | cut -d: -f3)
    # Insert into command line for editing before execution
    LBUFFER="$command"
    zle reset-prompt
  fi
}
zle -N palette

# Quick palette alias (can be called directly from prompt)
alias pal='palette'
