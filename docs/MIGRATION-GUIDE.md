# Migration Guide

Guide for upgrading between major versions of this dotfiles configuration.

## Table of Contents

- [Version History](#version-history)
- [Upgrading](#upgrading)
- [Migration Checklist](#migration-checklist)
- [Breaking Changes](#breaking-changes)
- [Rollback Procedures](#rollback-procedures)
- [Version-Specific Notes](#version-specific-notes)

---

## Version History

### Current Version (December 2024)

**Documentation Overhaul**
- Date: December 2024
- Status: Current

**Major Changes:**
- Comprehensive documentation for all 50+ configurations
- New Quick Start Guide for 5-minute setup
- Troubleshooting guide with solutions by symptom
- Developer documentation (ROADMAP, CONTRIBUTING)
- Component docs: Musikcube, Vifm, Starship, Aria2

**Migration Required:** No (documentation only)

### Version 2.0 (November 2024)

**Shell Modular Refactoring**
- Date: November 26, 2024
- Status: Stable

**Major Changes:**
- Shell configuration split from monolithic to modular structure
- 7 categorized alias files (chrome, core, dev, folders, git, macos, tools)
- 4 categorized function files (core, dev, macos, media)
- Package management system with profiles (minimal, dev, music, full)
- Mail offline sync implementation (mbsync + notmuch + neomutt)
- Fixed critical bugs in enc() and dec() functions
- zoxide integration for smart directory jumping

**Migration Required:** Automatic (see [below](#from-version-10-to-20))

### Version 1.0 (Initial)

**Monolithic Configuration**
- Date: Pre-November 2024
- Status: Deprecated

**Structure:**
- Single `aliases.sh` file (235 lines)
- Single `functions.sh` file (200 lines)
- Basic Brewfile without categorization
- Limited documentation

---

## Upgrading

### From Version 2.0 to Current

**Summary:** This is a documentation-only update. No breaking changes to configurations.

**Steps:**

1. **Pull latest changes:**
   ```bash
   cd ~/dotfiles
   git pull origin master
   ```

2. **Review new documentation:**
   ```bash
   ls docs/
   # New: QUICK-START.md, TROUBLESHOOTING.md, MIGRATION-GUIDE.md
   # New: docs/dev/ directory with ROADMAP.md, CONTRIBUTING.md

   ls config/*/README.md
   # New: musikcube, vifm, starship, aria2 documentation
   ```

3. **No configuration changes needed** - Continue using existing setup

**New Features Available:**
- Quick Start Guide for new users
- Comprehensive troubleshooting by symptom
- Component-specific documentation (Musikcube, Vifm, Starship, Aria2)
- Enhanced README with better navigation
- Developer documentation for contributors

---

### From Version 1.0 to 2.0

**Summary:** Major shell refactoring from monolithic to modular structure. Configuration is preserved, but file organization changes significantly.

**Breaking Changes:** None - All aliases and functions work identically or better.

**Migration Steps:**

#### 1. Backup Current Configuration

```bash
cd ~/dotfiles

# Create backup
cp shell/aliases.sh shell/aliases.sh.backup
cp shell/functions.sh shell/functions.sh.backup
```

#### 2. Pull Updates

```bash
git pull origin master
```

#### 3. Review Changes

**Old Structure:**
```
shell/
├── aliases.sh (235 lines)
├── functions.sh (200 lines)
└── zshrc
```

**New Structure:**
```
shell/
├── aliases/
│   ├── chrome.sh    # Chrome development (19 lines)
│   ├── core.sh      # Core system (42 lines)
│   ├── dev.sh       # Development tools (32 lines)
│   ├── folders.sh   # Directory shortcuts (32 lines)
│   ├── git.sh       # Git commands (9 lines)
│   ├── macos.sh     # macOS-specific (39 lines)
│   └── tools.sh     # Modern CLI tools (50 lines)
├── functions/
│   ├── core.sh      # Essential utilities (105 lines)
│   ├── dev.sh       # Development (99 lines)
│   ├── macos.sh     # macOS functions (66 lines)
│   └── media.sh     # Media conversion (46 lines)
├── CHANGELOG.md
├── QUICK_REFERENCE.md
├── README.md
└── zshrc (updated)
```

#### 4. Install zoxide

New dependency for smart directory navigation:

```bash
brew install zoxide
```

#### 5. Reload Shell

```bash
source ~/.zshrc
# or
reload
```

#### 6. Test Functionality

```bash
# Test smart navigation
z dotfiles    # Should jump to dotfiles
zi            # Interactive picker

# Test aliases
ll            # Enhanced ls
cat README.md # Syntax highlighted

# Test functions
mkd test_dir  # Create and enter directory
cd ..
rmdir test_dir
```

#### 7. Review Fixed Functions

**enc() function - Fixed file encoding:**
```bash
# Before (broken):
enc /path/to/file  # Failed

# After (working):
enc /path/to/file  # Encodes file to base64 in clipboard
```

**dec() function - Fixed base64 decoding:**
```bash
# Before (broken):
# Was encoding instead of decoding

# After (working):
pbcopy < encoded.txt  # Copy base64 to clipboard
dec output.txt        # Decode from clipboard to file
```

#### 8. Remove Backups (Optional)

After verifying everything works:

```bash
cd ~/dotfiles/shell
rm aliases.sh.backup functions.sh.backup
```

---

## Migration Checklist

Use this checklist when upgrading:

### Pre-Migration

- [ ] **Backup current setup**
  ```bash
  ./scripts/backup.sh  # If script exists
  # or manually backup configs
  ```

- [ ] **Note customizations**
  - Document any custom aliases/functions
  - Note machine-specific settings
  - Record manual configuration changes

- [ ] **Check git status**
  ```bash
  cd ~/dotfiles
  git status  # Ensure clean working directory
  ```

### During Migration

- [ ] **Pull latest changes**
  ```bash
  git pull origin master
  ```

- [ ] **Review breaking changes** (see below)

- [ ] **Install new dependencies**
  ```bash
  brew bundle install
  ```

- [ ] **Run install script** (if needed)
  ```bash
  ./scripts/install.sh
  ```

### Post-Migration

- [ ] **Reload shell**
  ```bash
  source ~/.zshrc
  ```

- [ ] **Test key functionality**
  - Shell aliases work
  - Functions execute correctly
  - Plugins load without errors
  - Neovim/Vim opens properly

- [ ] **Run health check**
  ```bash
  ./scripts/health-check.sh
  ```

- [ ] **Verify plugins**
  - Neovim: `:checkhealth`
  - Tmux: `tmux source ~/.tmux.conf`
  - Git: `git config --list`

- [ ] **Check machine-specific overrides**
  ```bash
  # Verify .local files still work
  cat ~/.zshrc.local
  cat ~/.gitconfig.local
  ```

- [ ] **Re-apply customizations** (if needed)

---

## Breaking Changes

### Version 2.0 (November 2024)

**None.** Migration is backward compatible.

**Changes that might affect you:**
- Old `aliases.sh` and `functions.sh` no longer used (but backed up automatically)
- New modular structure may require locating aliases in different files
- Added zoxide dependency (but `cd` still works normally)

**Deprecated:**
- ❌ `rf` alias removed (was dangerous `rm -rf`)
- ❌ `fcd` alias removed (replaced by zoxide's `zi`)
- ❌ Commented `alias cd="z"` removed (now properly implemented)
- ❌ fasd references removed (replaced by zoxide)

**Fixed Bugs:**
- ✅ enc() function now correctly encodes files
- ✅ dec() function now correctly decodes (was encoding before)
- ✅ svg2css() function fixed encoding command
- ✅ All functions now properly quote file paths with spaces

---

## Rollback Procedures

### Rollback from Current to Version 2.0

**If documentation changes cause issues:**

```bash
cd ~/dotfiles

# Remove new documentation
rm docs/QUICK-START.md
rm docs/TROUBLESHOOTING.md
rm docs/MIGRATION-GUIDE.md
rm -rf docs/dev/

# Restore old structure
git checkout HEAD~1 docs/
```

**Note:** Rollback not recommended - documentation changes don't affect functionality.

### Rollback from Version 2.0 to Version 1.0

**If modular refactoring causes issues:**

1. **Restore backup files:**
   ```bash
   cd ~/dotfiles/shell

   # Restore monolithic files
   mv aliases.sh.backup aliases.sh
   mv functions.sh.backup functions.sh
   ```

2. **Update zshrc:**
   ```bash
   # Edit ~/.zshrc
   nvim ~/dotfiles/shell/zshrc

   # Change FROM:
   for alias_file in $DOTFILES/shell/aliases/*.sh; do
     source "$alias_file"
   done
   for func_file in $DOTFILES/shell/functions/*.sh; do
     source "$func_file"
   done

   # TO:
   source $DOTFILES/shell/aliases.sh
   source $DOTFILES/shell/functions.sh
   ```

3. **Remove modular directories:**
   ```bash
   rm -rf ~/dotfiles/shell/aliases/
   rm -rf ~/dotfiles/shell/functions/
   ```

4. **Reload shell:**
   ```bash
   source ~/.zshrc
   ```

---

## Version-Specific Notes

### macOS Version Compatibility

| macOS Version | Dotfiles Version | Notes |
|---------------|------------------|-------|
| macOS 15 Sequoia | 2.0+ | ✅ Fully supported |
| macOS 14 Sonoma | 2.0+ | ✅ Fully supported |
| macOS 13 Ventura | 2.0+ | ✅ Fully supported |
| macOS 12 Monterey | 2.0+ | ⚠️ Mostly supported (some features may vary) |
| macOS 11 Big Sur | 2.0+ | ⚠️ Mostly supported (older Homebrew formulas) |
| macOS 10.15 Catalina | 1.0 | ⚠️ Old version only (upgrade recommended) |

### Tool Version Requirements

**Minimum versions for Version 2.0:**

| Tool | Minimum Version | Check Command |
|------|----------------|---------------|
| Homebrew | 4.0.0+ | `brew --version` |
| ZSH | 5.8+ | `zsh --version` |
| Git | 2.30+ | `git --version` |
| Neovim | 0.9.0+ | `nvim --version` |
| Tmux | 3.2+ | `tmux -V` |

**Install latest:**
```bash
brew upgrade
```

---

## FAQs

### Q: Will upgrading affect my custom aliases?

**A:** No, if you store custom aliases in:
- `~/.zshrc.local` (machine-specific)
- Custom files in `shell/aliases/` (tracked)

Both are preserved during upgrades.

### Q: What happens to my .local files?

**A:** Machine-specific `.local` files are never tracked in git:
- `~/.zshrc.local`
- `~/.gitconfig.local`
- `~/.tmux.conf.local`

These are safe during all upgrades.

### Q: Can I upgrade gradually?

**A:** Yes, pull changes but don't run install script:
```bash
git pull origin master
# Review changes
# Test in new shell: zsh -l
# Apply when ready: ./scripts/install.sh
```

### Q: How do I know what version I'm on?

**A:** Check git log:
```bash
cd ~/dotfiles
git log --oneline -10
```

Look for version markers in commit messages.

---

## Getting Help

**Migration issues?**

1. **Check troubleshooting:** [Troubleshooting Guide](TROUBLESHOOTING.md)
2. **Run health check:** `./scripts/health-check.sh`
3. **Review logs:** `cat ~/.dotfiles-install.log`
4. **Restore backup:** `./scripts/restore.sh --latest`
5. **Open an issue:** [GitHub Issues](https://github.com/jeromefaria/dotfiles/issues)

---

**Status:** ✅ Complete
**Last Updated:** 2025-12-20
