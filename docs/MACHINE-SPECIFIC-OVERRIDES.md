# Machine-Specific Configuration Overrides

This dotfiles repository supports machine-specific configuration overrides, allowing you to maintain different settings for work, personal, or different machines without forking the repository or creating conflicts with git.

## Overview

**Local override files** are loaded automatically but are **not tracked in git**. This allows you to:

- Use different email addresses for work and personal git commits
- Define work-specific aliases and functions
- Set machine-specific environment variables
- Override settings without modifying the main configs

## Available Override Files

### 1. Shell Configuration

**File:** `~/.zshrc.local`
**Template:** `~/dotfiles/shell/zshrc.local.example`

Loaded at the end of `shell/zshrc`, this file allows you to override or extend shell configuration.

**Setup:**
```bash
# Copy the example template
cp ~/dotfiles/shell/zshrc.local.example ~/.zshrc.local

# Edit with your settings
nvim ~/.zshrc.local
```

**Common Use Cases:**
- Work-specific aliases and functions
- Company proxy settings
- Custom PATH additions
- Environment variables for work projects
- Override prompt theme

**Example:**
```bash
# ~/.zshrc.local
export WORK_ENV=true
export AWS_PROFILE="company-prod"

alias vpn="sudo openvpn --config ~/work.ovpn"
alias deploy="ssh deploy@prod.company.com"

# Override prompt for work machine
export ZSH_THEME="agnoster"
```

### 2. Git Configuration

**File:** `~/.gitconfig.local`
**Template:** `~/dotfiles/git/gitconfig.local.example`

Included at the end of `git/gitconfig`, this file allows you to override git settings per-machine.

**Setup:**
```bash
# Copy the example template
cp ~/dotfiles/git/gitconfig.local.example ~/.gitconfig.local

# Edit with your settings
nvim ~/.gitconfig.local
```

**Common Use Cases:**
- Work email address
- GPG signing keys
- Work-specific aliases
- Custom merge/diff tools
- Private repository URL rewrites

**Example:**
```gitconfig
# ~/.gitconfig.local
[user]
  email = firstname.lastname@company.com
  signingkey = ABCD1234EFGH5678

[commit]
  gpgsign = true

[alias]
  work-log = log --author="firstname.lastname@company.com"
```

## Advanced: Conditional Includes

Git supports conditional includes based on directory paths, allowing different configs for different project types.

### Example: Separate Work and Personal Configs

**1. Create specialized config files:**

```bash
# ~/.gitconfig.work
[user]
  email = work@company.com
  signingkey = WORK_KEY_ID

[commit]
  gpgsign = true
```

```bash
# ~/.gitconfig.personal
[user]
  email = personal@gmail.com
  signingkey = PERSONAL_KEY_ID
```

**2. Use conditional includes in `~/.gitconfig.local`:**

```gitconfig
# ~/.gitconfig.local
[includeIf "gitdir:~/work/"]
  path = ~/.gitconfig.work

[includeIf "gitdir:~/personal/"]
  path = ~/.gitconfig.personal

[includeIf "gitdir:~/projects/opensource/"]
  path = ~/.gitconfig.personal
```

**3. Now git automatically uses the right config:**
```bash
cd ~/work/company-project
git config user.email
# → work@company.com

cd ~/personal/my-project
git config user.email
# → personal@gmail.com
```

## Multi-Machine Workflow

### Scenario: Work Laptop + Personal Desktop

**Work Laptop (`~/.zshrc.local`):**
```bash
# Work-specific settings
export WORK_ENV=true
export HTTP_PROXY="http://proxy.company.com:8080"
export HTTPS_PROXY="http://proxy.company.com:8080"

alias vpn-connect="sudo openvpn --config ~/work.ovpn"
alias ssh-jumpbox="ssh user@jumpbox.company.com"

# Work projects path
export PATH="/opt/company/bin:$PATH"
```

**Work Laptop (`~/.gitconfig.local`):**
```gitconfig
[user]
  email = work@company.com
  signingkey = WORK_GPG_KEY

[commit]
  gpgsign = true

[url "git@github.company.com:"]
  insteadOf = https://github.company.com/
```

**Personal Desktop (`~/.zshrc.local`):**
```bash
# Personal machine settings
export PERSONAL_ENV=true

alias music="ncmpcpp"
alias stream="obs --startrecording"

# Gaming-specific
alias steam="open -a Steam"
```

**Personal Desktop (`~/.gitconfig.local`):**
```gitconfig
[user]
  email = personal@gmail.com

# No GPG signing for personal projects
```

## Checking What's Active

### Shell Settings

```bash
# Check if local config exists
ls -la ~/.zshrc.local

# View what's defined
cat ~/.zshrc.local

# Test environment variables
echo $WORK_ENV

# List custom aliases
alias | grep "work\|custom"
```

### Git Settings

```bash
# Check if local config exists
ls -la ~/.gitconfig.local

# View what's defined
cat ~/.gitconfig.local

# Check effective git config
git config --list --show-origin | grep local

# Check specific values
git config user.email
git config user.signingkey
```

## Security Considerations

### DO NOT Track These Files

The `.gitignore` in the repository excludes:
- `*.local`
- `*.local.example` files are safe (templates only)

**Verify:**
```bash
git status
# Should NOT show .local files

git check-ignore ~/.zshrc.local
# Should return: .zshrc.local
```

### Sensitive Data

**Never commit:**
- API keys
- Passwords
- Private keys
- Company secrets
- Personal information

**Instead:**
- Store in `.local` files (not tracked)
- Use password managers (1Password, etc.)
- Use macOS Keychain for tokens
- Use environment variables from `.local` files

### Example: Secure Token Storage

```bash
# ~/.zshrc.local
# Reference token from macOS Keychain
export GITHUB_TOKEN=$(security find-generic-password -s github_token -w)

# Or source from encrypted file
[ -f ~/.secrets.gpg ] && source <(gpg -d ~/.secrets.gpg)
```

## Troubleshooting

### Local Config Not Loading

**Shell:**
```bash
# Verify it's sourced in zshrc
grep "zshrc.local" ~/dotfiles/shell/zshrc

# Manually source to test
source ~/.zshrc.local

# Check for syntax errors
zsh -n ~/.zshrc.local
```

**Git:**
```bash
# Verify include is in gitconfig
grep "gitconfig.local" ~/dotfiles/git/gitconfig

# Check if file is being included
git config --list --show-origin

# Manually test
git config --file ~/.gitconfig.local user.email
```

### Conflicts with Main Config

**Resolution order:**
1. Main config loaded first (`zshrc` or `gitconfig`)
2. Local config loaded last (overrides main)

**To override:**
```bash
# In ~/.zshrc.local - overwrites previous value
export EDITOR="code"  # Overrides nvim from main config

# In ~/.gitconfig.local - overwrites previous value
[user]
  email = different@email.com  # Overrides main gitconfig
```

## Best Practices

### 1. Start with Templates

Always copy from `.example` files:
```bash
cp ~/dotfiles/shell/zshrc.local.example ~/.zshrc.local
cp ~/dotfiles/git/gitconfig.local.example ~/.gitconfig.local
```

### 2. Document Your Changes

Add comments explaining why:
```bash
# ~/.zshrc.local
# Work requires HTTP proxy for package managers
export HTTP_PROXY="http://proxy:8080"
```

### 3. Keep It Simple

Only add what's necessary:
- ✅ Machine-specific settings
- ✅ Work-required configurations
- ❌ Don't duplicate main config
- ❌ Don't add "nice-to-have" aliases here

### 4. Backup Your Local Configs

Since `.local` files aren't in git:
```bash
# Create private backup repo or encrypted archive
tar czf ~/backups/dotfiles-local-$(date +%Y%m%d).tar.gz \
  ~/.zshrc.local \
  ~/.gitconfig.local
```

### 5. Test Changes

After editing:
```bash
# Test shell config
source ~/.zshrc.local

# Test git config
git config --list | grep -i "email\|signing"
```

## Migration Between Machines

### Export to New Machine

```bash
# On old machine
scp ~/.zshrc.local newmachine:~/
scp ~/.gitconfig.local newmachine:~/
```

### Sync via Encrypted Cloud Storage

```bash
# Store in 1Password, Bitwarden, or encrypted cloud folder
# Reference from local config:
cp ~/Dropbox/Private/zshrc.local ~/.zshrc.local
```

## Summary

| File | Purpose | Example Use |
|------|---------|-------------|
| `~/.zshrc.local` | Shell overrides | Work aliases, paths, env vars |
| `~/.gitconfig.local` | Git overrides | Work email, GPG keys, aliases |

**Key Points:**
- ✅ NOT tracked in git (safe for secrets)
- ✅ Loaded automatically
- ✅ Override main configs
- ✅ Use templates to get started

---

**See Also:**
- [Architecture Documentation](ARCHITECTURE.md) - How configs work together
- [Main README](../README.md) - Installation and overview
