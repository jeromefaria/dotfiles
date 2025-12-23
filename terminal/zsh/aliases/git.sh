#!/usr/bin/env zsh
# Git aliases - version control shortcuts and utilities

# Git command shortcuts
alias gcan="git commit --amend --no-edit"
alias gdc="git diff --name-only --diff-filter=U"
alias gds="git diff --staged"
alias gfl="git-flow"
alias grp="git request-pull"
alias gstdf="git stash show -p"

# FZF-enhanced git commands
alias gcob='git checkout $(git branch | fzf)'
