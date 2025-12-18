#!/usr/bin/env zsh
# Git aliases (simplified - zsh-abbr removed due to dependency issues)
# Note: Many of these are already provided by the omz-git plugin
# To use zsh-abbr in the future, install it with proper dependencies

# Skipping zsh-abbr for now due to dependency issues
# Using regular aliases instead (won't expand on space, but will work)
if false; then  # Disabled - use omz-git plugin aliases instead
  # ============================================================================
  # STATUS & INFO
  # ============================================================================
  abbr gs="git status"
  abbr gss="git status -s"                    # Short format
  abbr gd="git diff"
  abbr gds="git diff --staged"
  abbr gdc="git diff --cached"
  abbr gl="git log --oneline --graph --decorate -20"
  abbr gla="git log --oneline --graph --decorate --all -20"
  abbr gll="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
  abbr glo="git log --oneline"
  abbr gsh="git show"
  abbr gwho="git shortlog -sn"                # Contributor stats

  # ============================================================================
  # STAGING
  # ============================================================================
  abbr ga="git add"
  abbr gaa="git add --all"
  abbr gap="git add --patch"                  # Interactive staging
  abbr gau="git add --update"                 # Stage modified/deleted only

  # ============================================================================
  # COMMITTING
  # ============================================================================
  abbr gc="git commit -v"                     # Verbose (shows diff)
  abbr gcm="git commit -m"
  abbr gca="git commit --amend"
  abbr gcan="git commit --amend --no-edit"
  abbr gcf="git commit --fixup"               # Fixup commit for rebase
  abbr gce="git commit --allow-empty -m"      # Empty commit

  # ============================================================================
  # BRANCHES
  # ============================================================================
  abbr gb="git branch"
  abbr gba="git branch --all"                 # All branches
  abbr gbd="git branch -d"                    # Delete branch
  abbr gbD="git branch -D"                    # Force delete
  abbr gco="git checkout"
  abbr gcob="git checkout -b"                 # Create and checkout
  abbr gcom="git checkout main"
  abbr gcod="git checkout develop"
  abbr gbm="git branch --merged"              # Show merged branches
  abbr gbnm="git branch --no-merged"          # Show unmerged branches

  # ============================================================================
  # PUSH/PULL/FETCH
  # ============================================================================
  abbr gp="git push"
  abbr gpf="git push --force-with-lease"      # Safer force push
  abbr gpu="git push -u origin"               # Set upstream
  abbr gpl="git pull"
  abbr gplr="git pull --rebase"               # Pull with rebase
  abbr gf="git fetch"
  abbr gfa="git fetch --all"
  abbr gfo="git fetch origin"

  # ============================================================================
  # STASH
  # ============================================================================
  abbr gst="git stash"
  abbr gsta="git stash apply"
  abbr gstd="git stash drop"
  abbr gstl="git stash list"
  abbr gstp="git stash pop"
  abbr gsts="git stash show"
  abbr gstu="git stash --include-untracked"   # Stash untracked too

  # ============================================================================
  # MERGE/REBASE
  # ============================================================================
  abbr gm="git merge"
  abbr gma="git merge --abort"
  abbr gr="git rebase"
  abbr gri="git rebase -i"                    # Interactive rebase
  abbr grc="git rebase --continue"
  abbr gra="git rebase --abort"
  abbr grs="git rebase --skip"
  abbr grm="git rebase main"
  abbr grd="git rebase develop"

  # ============================================================================
  # RESET & RESTORE
  # ============================================================================
  abbr grh="git reset HEAD"                   # Unstage
  abbr grhh="git reset HEAD --hard"           # Hard reset
  abbr grs="git restore"
  abbr grss="git restore --staged"            # Unstage (new git)
  abbr gclean="git clean -fd"                 # Remove untracked files

  # ============================================================================
  # REMOTE
  # ============================================================================
  abbr grv="git remote -v"
  abbr gra="git remote add"
  abbr grr="git remote remove"
  abbr gru="git remote update"
  abbr grp="git remote prune origin"          # Prune deleted remote branches

  # ============================================================================
  # WORKTREE
  # ============================================================================
  abbr gwt="git worktree"
  abbr gwta="git worktree add"
  abbr gwtl="git worktree list"
  abbr gwtr="git worktree remove"

  # ============================================================================
  # TAGS
  # ============================================================================
  abbr gt="git tag"
  abbr gta="git tag -a"                       # Annotated tag
  abbr gtd="git tag -d"                       # Delete tag
  abbr gtl="git tag -l"                       # List tags

  # ============================================================================
  # MISCELLANEOUS
  # ============================================================================
  abbr gcp="git cherry-pick"
  abbr gcpa="git cherry-pick --abort"
  abbr gcpc="git cherry-pick --continue"
  abbr gbl="git blame"
  abbr gbs="git bisect"
  abbr gbss="git bisect start"
  abbr gbsg="git bisect good"
  abbr gbsb="git bisect bad"
  abbr gbsr="git bisect reset"

  # Aliases (not abbreviations - for complex commands)
  alias gundo='git reset --soft HEAD~1'       # Undo last commit, keep changes
  alias gnuke='git reset --hard HEAD && git clean -fd'  # Nuclear option
  alias gclone='git clone --recurse-submodules'  # Clone with submodules
  alias gwip='git add -A && git commit -m "WIP"'  # Quick WIP commit
  alias gunwip='git log -1 --pretty=%s | grep -q WIP && git reset HEAD~1'  # Undo WIP

  echo "Git abbreviations loaded (type 'abbr' to list all)"
fi

# Note: For now, use the git aliases provided by the omz-git plugin
# They include: ga, gaa, gb, gba, gco, gcb, gd, gds, gl, gp, gpl, gst, and many more
# Run 'alias | grep git' to see all available git aliases
