#!/usr/bin/env zsh
# FZF enhancements for vim-like workflow (Telescope-inspired)

# ============================================================================
# FZF ENVIRONMENT VARIABLES
# ============================================================================

# Ctrl-R: Enhanced history search with preview
export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

# Ctrl-T: File finder with preview (like Telescope find_files)
export FZF_CTRL_T_OPTS="
  --preview 'bat -n --color=always --line-range :500 {}'
  --bind 'ctrl-/:toggle-preview'"

# Alt-C: Directory finder with tree preview
export FZF_ALT_C_OPTS="
  --preview 'eza --tree --level=2 --color=always {} || tree -C {} | head -200'"

# ============================================================================
# CUSTOM FZF WIDGETS (Telescope equivalents)
# ============================================================================

# Find git-tracked files (like Telescope find_files / git_files)
# Keybinding: Ctrl-P (matches nvim classic mode)
fzf-git-files() {
  local selected
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    selected=$(git ls-files 2>/dev/null | fzf --height 40% --reverse \
      --preview 'bat --color=always --line-range :500 {}' \
      --header 'Git Files (Ctrl-P)')
  else
    selected=$(fd --type f --hidden --exclude .git | fzf --height 40% --reverse \
      --preview 'bat --color=always --line-range :500 {}' \
      --header 'Files (Ctrl-P)')
  fi

  if [[ -n "$selected" ]]; then
    LBUFFER+="$selected"
  fi
  zle reset-prompt
}
zle -N fzf-git-files

# Live grep with ripgrep (like Telescope live_grep)
# Keybinding: Ctrl-F (matches ,f in nvim classic mode)
fzf-ripgrep() {
  local selected
  selected=$(rg --color=always --line-number --no-heading --smart-case "${*:-}" . 2>/dev/null |
    fzf --ansi \
        --color "hl:-1:underline,hl+:-1:underline:reverse" \
        --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
        --bind 'ctrl-/:toggle-preview' \
        --header 'Live Grep (Ctrl-F)')

  if [[ -n "$selected" ]]; then
    local file=$(echo "$selected" | cut -d: -f1)
    local line=$(echo "$selected" | cut -d: -f2)
    LBUFFER+="$EDITOR +$line $file"
  fi
  zle reset-prompt
}
zle -N fzf-ripgrep

# Fuzzy git branch checkout (like Telescope git_branches)
# Keybinding: gb (in normal mode)
fzf-git-branch() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Not in a git repository"
    return 1
  fi

  local branch
  branch=$(git branch -a --color=always | grep -v HEAD | fzf --ansi --height 40% --reverse \
    --preview 'git log --oneline --graph --color=always {1}' \
    --header 'Git Branches (gb)' |
    /usr/bin/sed 's/remotes\/origin\///' | /usr/bin/sed 's/^[* ]*//' | tr -d ' ')

  if [[ -n "$branch" ]]; then
    git checkout "$branch"
    zle reset-prompt
  fi
}
zle -N fzf-git-branch

# Browse git log with preview (like Telescope git_commits)
# Keybinding: gl (in normal mode)
fzf-git-log() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Not in a git repository"
    return 1
  fi

  local commit
  commit=$(git log --oneline --graph --color=always --decorate |
    fzf --ansi --no-sort --reverse \
        --preview 'echo {} | grep -o "[a-f0-9]\{7,\}" | head -1 | xargs git show --color=always' \
        --preview-window=right:50% \
        --bind 'ctrl-/:toggle-preview' \
        --header 'Git Log (gl)' |
    grep -o "[a-f0-9]\{7,\}" | head -1)

  if [[ -n "$commit" ]]; then
    git show "$commit"
  fi
  zle reset-prompt
}
zle -N fzf-git-log

# Fuzzy git status - stage files interactively
# Keybinding: gs (in normal mode)
fzf-git-status() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Not in a git repository"
    return 1
  fi

  local selected
  selected=$(git status --short |
    fzf --height 40% --reverse --multi \
        --preview 'echo {} | awk "{print \$2}" | xargs git diff --color=always' \
        --header 'Git Status - Tab to select, Enter to stage (gs)' |
    awk '{print $2}')

  if [[ -n "$selected" ]]; then
    echo "$selected" | xargs git add
    echo "Staged: $selected"
  fi
  zle reset-prompt
}
zle -N fzf-git-status

# Fuzzy search and open recent files from history
fzf-recent-files() {
  local file
  file=$(fc -rl 1 |
    awk '{print $2}' |
    grep -E '\.(md|txt|json|js|ts|tsx|jsx|lua|sh|py|rb|go|java|c|cpp|h|hpp|rs|vim|zsh|yaml|yml|toml|conf|cfg)$' |
    sort -u |
    fzf --height 40% --reverse \
        --preview 'bat --color=always --line-range :500 {}' \
        --header 'Recent Files')

  if [[ -n "$file" ]]; then
    $EDITOR "$file"
  fi
  zle reset-prompt
}
zle -N fzf-recent-files

# Fuzzy find in command history and insert (enhanced Ctrl-R alternative)
fzf-history-widget-enhanced() {
  local selected
  selected=$(fc -rl 1 |
    awk '{$1="";print substr($0,2)}' |
    fzf --height 40% --reverse --tac --no-sort \
        --bind 'ctrl-y:execute-silent(echo -n {} | pbcopy)+abort' \
        --header 'Command History - Ctrl-Y to copy')

  if [[ -n "$selected" ]]; then
    LBUFFER="$selected"
  fi
  zle reset-prompt
}
zle -N fzf-history-widget-enhanced

# Fuzzy find and cd to directory (enhanced Alt-C)
fzf-cd-widget-enhanced() {
  local dir
  dir=$(fd --type d --hidden --exclude .git 2>/dev/null |
    fzf --height 40% --reverse \
        --preview 'eza --tree --level=2 --color=always {} || tree -C {} | head -200' \
        --header 'Change Directory')

  if [[ -n "$dir" ]]; then
    cd "$dir"
    zle reset-prompt
  fi
}
zle -N fzf-cd-widget-enhanced

# ============================================================================
# HELPER FUNCTIONS (not bound to keys)
# ============================================================================

# Fuzzy find and kill process
fzf-kill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf --multi --height 40% --reverse \
    --header 'Select process to kill' | awk '{print $2}')

  if [[ -n "$pid" ]]; then
    echo "$pid" | xargs kill -"${1:-9}"
    echo "Killed process(es): $pid"
  fi
}

# Fuzzy find in man pages
fzf-man() {
  man -k . | fzf --height 40% --reverse \
    --preview 'echo {} | awk "{print \$1}" | xargs man' \
    --preview-window=right:60% | awk '{print $1}' | xargs man
}
