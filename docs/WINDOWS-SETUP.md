# Windows/Git Bash Portable Setup

This guide is for setting up dotfiles on Windows systems where you don't have admin rights and can't create symlinks.

## Quick Start

If you've already cloned the dotfiles repository to a custom location (e.g., `~/usr/src/dotfiles`):

```bash
# Navigate to your dotfiles directory
cd ~/usr/src/dotfiles

# Run the Windows setup script
./scripts/setup-portable-windows.sh
```

This will:
1. ✅ Configure the `DOTFILES` environment variable in your `.bash_profile`
2. ✅ Copy portable bash and vim configs to your home directory
3. ✅ Create a helper script (`~/sync-dotfiles.sh`) for future updates

## Manual Setup

If you prefer to set up manually:

### Step 1: Set DOTFILES Variable

Edit `~/.bash_profile` (create if it doesn't exist):

```bash
# Dotfiles location - UPDATE THIS to your actual path
export DOTFILES="$HOME/usr/src/dotfiles"

# Source profile and bashrc
test -f ~/.profile && . ~/.profile
test -f ~/.bashrc && . ~/.bashrc
```

### Step 2: Copy Portable Configs

```bash
# Navigate to dotfiles
cd ~/usr/src/dotfiles  # Or wherever you cloned it

# Run sync script
./scripts/sync-portable-configs.sh
```

### Step 3: Reload Shell

```bash
source ~/.bash_profile
```

## Updating Configs After Git Pull

Since symlinks don't work on your Windows system, you need to manually sync configs after pulling updates:

### Option 1: Use Helper Script

```bash
~/sync-dotfiles.sh
```

### Option 2: Manual Sync

```bash
cd ~/usr/src/dotfiles
git pull
./scripts/sync-portable-configs.sh
```

## What Gets Synced

The sync script copies these files from your dotfiles repo to your home directory:

| Source | Target | Description |
|--------|--------|-------------|
| `terminal/bash/bashrc.portable` | `~/.bashrc` | Portable bash configuration |
| `editors/vim/vimrc` | `~/.vimrc` | Vim configuration |
| `terminal/mintty/minttyrc` | `~/.minttyrc` | Mintty terminal config (if exists) |

## Why Not Symlinks?

On Windows, creating symlinks requires:
- Administrator privileges, OR
- Developer Mode enabled (Windows 10+), OR
- Specific group policies configured

If you don't have these, the hard copy approach is the best solution.

## Verifying Your Setup

Check that everything is configured correctly:

```bash
# 1. Check DOTFILES variable
echo "DOTFILES: $DOTFILES"
# Should show: /c/Users/YourName/usr/src/dotfiles (or your path)

# 2. Check that bashrc is from dotfiles
head -5 ~/.bashrc
# Should show portable bash config header

# 3. Check that vimrc exists
test -f ~/.vimrc && echo "✓ vimrc exists" || echo "✗ vimrc missing"
```

## Troubleshooting

### DOTFILES points to wrong location

**Problem:** `echo $DOTFILES` shows `/c/Users/xxx/dotfiles` instead of your actual path

**Solution:**
1. Edit `~/.bash_profile` and update the `DOTFILES` path
2. Run: `source ~/.bash_profile`
3. Verify: `echo $DOTFILES`

### Configs not updating after git pull

**Problem:** You pulled new changes but bash/vim still uses old config

**Solution:** You forgot to sync! Run:
```bash
~/sync-dotfiles.sh
# Then restart your shell
```

### Helper script not found

**Problem:** `~/sync-dotfiles.sh` doesn't exist

**Solution:** Re-run the setup:
```bash
cd ~/usr/src/dotfiles
./scripts/setup-portable-windows.sh
```

## Workflow Summary

```
┌─────────────────────────────────────────┐
│  Dotfiles Repository                    │
│  ~/usr/src/dotfiles/                    │
│                                          │
│  ├── terminal/bash/bashrc.portable      │
│  ├── editors/vim/vimrc                  │
│  └── scripts/sync-portable-configs.sh   │
└─────────────────┬───────────────────────┘
                  │
                  │ git pull
                  ▼
          ┌───────────────┐
          │  Run Sync     │
          │  Script       │
          └───────┬───────┘
                  │
                  │ copy files
                  ▼
┌─────────────────────────────────────────┐
│  Home Directory                         │
│  ~/ (C:/Users/YourName)                 │
│                                          │
│  ├── .bash_profile (sets DOTFILES var)  │
│  ├── .bashrc (copied)                   │
│  ├── .vimrc (copied)                    │
│  └── sync-dotfiles.sh (helper)          │
└─────────────────────────────────────────┘
```

## Alternative: WSL

If you have Windows Subsystem for Linux (WSL) available, you can use the full dotfiles installation with symlinks:

```bash
# In WSL
cd ~
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles
./scripts/install.sh
```

WSL fully supports symlinks and all other dotfiles features.
