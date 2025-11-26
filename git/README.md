# Git Configuration

Comprehensive Git configuration with useful aliases, improved diff viewing, and machine-specific override support.

## Configuration File

**Location:** `~/dotfiles/git/gitconfig` → `~/.gitconfig`

## Features

- Custom aliases for common operations
- diff-so-fancy for beautiful diffs
- Git LFS (Large File Storage) support
- Rebase-first pull strategy
- Machine-specific overrides

---

## User Configuration

```gitconfig
[user]
  name = Jerome Faria
  email = jerome.faria@gmail.com
```

**Note:** For machine-specific emails (work vs. personal), use `~/.gitconfig.local` (see [Machine-Specific Overrides](#machine-specific-overrides)).

---

## Git Aliases

### Basic Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `git co` | `checkout` | Switch branches or restore files |
| `git ci` | `commit` | Record changes |
| `git st` | `status` | Show working tree status |
| `git br` | `branch` | List, create, or delete branches |

### Advanced Aliases

| Alias | Full Command | Description |
|-------|--------------|-------------|
| `git hist` | `log --pretty=format:"%h %ad \| %s%d [%an]" --graph --date=short` | Pretty graph log with date and author |
| `git type` | `cat-file -t` | Show object type |
| `git dump` | `cat-file -p` | Pretty-print object contents |

### Usage Examples

```bash
# Basic workflow
git co -b feature/new-feature
git st
git ci -m "Add new feature"

# View history
git hist                    # Pretty graph of commits
git hist --all              # All branches
git hist -10                # Last 10 commits

# Inspect objects
git type HEAD               # Show type (commit, tree, blob)
git dump HEAD               # Show commit contents
```

---

## Diff Configuration

### diff-so-fancy

Beautiful, human-readable Git diffs with:
- Simplified headers
- Highlighted changes
- Better readability

**Pager Settings:**
```gitconfig
[core]
  pager = diff-so-fancy | less --tabs=4 -RFX

[pager]
  diff = diff-so-fancy | less --tabs=4 -RFXS --pattern '^(Date|added|deleted|modified): '
```

**Installation:**
```bash
brew install diff-so-fancy
```

**Example Output:**
```diff
modified: README.md
@ README.md:10 @
-Old text here
+New text here
```

---

## Git LFS (Large File Storage)

Configuration for tracking large files outside the main repository.

```gitconfig
[filter "lfs"]
  clean = git-lfs clean -- %f
  smudge = git-lfs smudge -- %f
  process = git-lfs filter-process
  required = true
```

### Using Git LFS

```bash
# Install
brew install git-lfs
git lfs install

# Track large files
git lfs track "*.psd"
git lfs track "*.mp4"
git lfs track "*.zip"

# Verify
git lfs ls-files
```

---

## Pull Strategy

```gitconfig
[pull]
  rebase = true
```

**Behavior:** `git pull` will rebase local commits on top of fetched commits instead of creating a merge commit.

**Benefits:**
- Cleaner history (linear)
- No unnecessary merge commits
- Easier to review changes

**Equivalent to:**
```bash
git pull --rebase
```

**To temporarily use merge:**
```bash
git pull --no-rebase
```

---

## Push Configuration

```gitconfig
[push]
  default = current
```

**Behavior:** Pushes the current branch to a branch with the same name on the remote.

**Example:**
```bash
# On branch 'feature/new'
git push
# Pushes to origin/feature/new
```

**Alternative behaviors:**
- `simple` - Push to upstream branch (default in Git 2.0+)
- `upstream` - Push to configured upstream
- `matching` - Push all matching branches

---

## Color Configuration

```gitconfig
[color]
  ui = true
```

Enables colored output for all Git commands (diff, status, branch, etc.).

---

## Machine-Specific Overrides

### Local Configuration

Create `~/.gitconfig.local` for machine-specific settings:

**Template:** `~/dotfiles/git/gitconfig.local.example`

```bash
# Copy template
cp ~/dotfiles/git/gitconfig.local.example ~/.gitconfig.local

# Edit with machine-specific settings
nvim ~/.gitconfig.local
```

### Common Use Cases

#### Work Email

```gitconfig
# ~/.gitconfig.local
[user]
  email = work@company.com
```

#### GPG Signing

```gitconfig
# ~/.gitconfig.local
[user]
  signingkey = ABCD1234EFGH5678

[commit]
  gpgsign = true
```

#### Conditional Includes

Different configs for different directories:

```gitconfig
# ~/.gitconfig.local
[includeIf "gitdir:~/work/"]
  path = ~/.gitconfig.work

[includeIf "gitdir:~/personal/"]
  path = ~/.gitconfig.personal
```

Then create:
```bash
# ~/.gitconfig.work
[user]
  email = work@company.com

# ~/.gitconfig.personal
[user]
  email = personal@gmail.com
```

---

## Additional Settings

### Merge Tool

```gitconfig
[mergetool]
  keepBackup = true
```

Keeps `.orig` backup files after merge conflicts.

### GitHub Integration

```gitconfig
[github]
  user = jeromefaria

[ghi]
  token = !security find-internet-password -a jeromefaria -s github.com -l 'ghi token' -w
```

Uses macOS Keychain for secure token storage.

---

## Useful Commands

### View Configuration

```bash
# All settings
git config --list

# Specific setting
git config user.email

# Show where setting comes from
git config --show-origin user.email

# Global settings only
git config --global --list

# Local (repo-specific) settings
git config --local --list
```

### Edit Configuration

```bash
# Edit global config
git config --global --edit

# Edit local config
git config --local --edit

# Edit local override
nvim ~/.gitconfig.local
```

### Set Values

```bash
# Set global value
git config --global user.name "Your Name"

# Set local value (current repo only)
git config --local user.email "work@company.com"

# Unset value
git config --global --unset user.email
```

---

## Common Workflows

### Daily Development

```bash
# Start work
git co -b feature/new-thing
# ... make changes ...
git st                      # Check status
git diff                    # Review changes (uses diff-so-fancy)
git ci -m "Add new thing"
git push
```

### Code Review

```bash
# View history
git hist -10                # Last 10 commits
git hist --all --graph      # Full graph

# Compare branches
git diff main..feature
git diff main...feature     # Since branch diverged

# View specific commit
git show abc123
```

### Syncing

```bash
# Update from remote
git pull                    # Rebases by default

# Push current branch
git push                    # Pushes to same branch name
```

---

## Troubleshooting

### Diff Not Colored

```bash
# Check if diff-so-fancy is installed
which diff-so-fancy

# Install if missing
brew install diff-so-fancy

# Test
git diff
```

### Pull Creates Merge Commits

Your config has `pull.rebase = true`, but if you still get merge commits:

```bash
# Verify setting
git config pull.rebase

# Should output: true

# If not set
git config --global pull.rebase true
```

### Local Override Not Working

```bash
# Check if file exists
ls -la ~/.gitconfig.local

# Verify include directive
git config --show-origin --get-regexp include

# Should show:
# file:/Users/you/dotfiles/git/gitconfig  include.path=~/.gitconfig.local
```

### LFS Files Not Tracking

```bash
# Verify LFS is installed
git lfs version

# Install hooks
git lfs install

# Check tracked patterns
cat .gitattributes

# Track new pattern
git lfs track "*.mov"
git add .gitattributes
git commit -m "Track .mov files with LFS"
```

---

## Aliases Cheat Sheet

```bash
# Checkout
git co main                 # Switch to main
git co -b new-branch        # Create and switch

# Status
git st                      # Short status

# Commit
git ci -m "message"         # Commit with message
git ci -am "message"        # Add all and commit

# Branch
git br                      # List branches
git br -a                   # List all (including remote)
git br -d old-branch        # Delete branch

# History
git hist                    # Pretty log
git hist --all              # All branches
git hist -10                # Last 10

# Inspect
git type HEAD~1             # Show object type
git dump abc123             # Show commit contents
```

---

## Security Notes

### Token Storage

The config uses macOS Keychain for GitHub tokens:

```gitconfig
[ghi]
  token = !security find-internet-password -a jeromefaria -s github.com -l 'ghi token' -w
```

**Add token to Keychain:**
```bash
security add-internet-password \
  -a jeromefaria \
  -s github.com \
  -l 'ghi token' \
  -w your_token_here
```

### Never Commit Secrets

- Use `.gitconfig.local` for sensitive data
- Store tokens in Keychain, not config files
- Use environment variables for CI/CD

---

## Related Documentation

- [Main README](../README.md) - Dotfiles overview
- [Machine-Specific Overrides](../docs/MACHINE-SPECIFIC-OVERRIDES.md) - Local config guide
- [Git Official Docs](https://git-scm.com/doc)
- [diff-so-fancy](https://github.com/so-fancy/diff-so-fancy)
- [Git LFS](https://git-lfs.github.com/)

---

**Configuration Location:** `~/dotfiles/git/gitconfig`
**Symlinked To:** `~/.gitconfig`
**Local Overrides:** `~/.gitconfig.local` (not tracked)
