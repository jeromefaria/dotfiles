# About Brewfile.old

## Purpose

`Brewfile.old` is an **archived snapshot** of the previous package configuration before the current categorized system was implemented.

## Contents

- **291 packages** from a previous dotfiles configuration
- Mix of brews, casks, taps, and App Store apps
- Represents the "legacy" package list before reorganization

## Why Keep It?

This file is retained for:

1. **Historical reference** - See what was installed previously
2. **Migration verification** - Check if packages were moved to new categories
3. **Recovery** - Restore old packages if needed

## Current Package System

The dotfiles now use a **categorized package system**:

- `Brewfile.base` - Essential tools
- `Brewfile.dev` - Development packages
- `Brewfile.music` - Music production
- `Brewfile.browsers` - Web browsers
- `Brewfile.media` - Media tools
- `Brewfile.communication` - Chat, email, etc.
- `Brewfile.productivity` - Personal productivity apps
- `Brewfile.security` - Security tools
- `Brewfile.utilities` - System utilities

See the main [packages/README.md](README.md) for details on the new system.

## Comparison with Current Setup

To see what's changed:

```bash
# Find packages in old file but not in current categories
comm -23 \
  <(grep '^brew\|^cask\|^tap' Brewfile.old | sort) \
  <(cat Brewfile.* | grep '^brew\|^cask\|^tap' | sort -u)
```

## Should You Use This?

**No** - This file is for archival purposes only.

- ✅ Use the categorized `Brewfile.*` files
- ✅ Use `packages/profiles/` for installation profiles
- ❌ Don't install from `Brewfile.old` directly

## Can It Be Deleted?

**Yes**, if you're confident the migration is complete:

1. Run package sync to verify current packages:
   ```bash
   ./packages/sync-packages.sh
   ```

2. Review the discrepancies and ensure everything needed is categorized

3. Delete the file:
   ```bash
   rm packages/Brewfile.old
   ```

4. Commit the change:
   ```bash
   git rm packages/Brewfile.old
   git commit -m "chore: remove archived Brewfile.old after migration"
   ```

## Notable Differences

Some packages from `Brewfile.old` may no longer be needed:

- **Deprecated tools** - Replaced by modern alternatives
- **Unused apps** - No longer part of workflow
- **Old versions** - Superseded by newer tools

Examples:
- `python@3.7`, `python@3.8`, `python@3.9` → Now using Python 3.11+
- `macvim` → Replaced by Neovim
- `fasd` → Replaced by zoxide

---

**Last Updated:** November 26, 2024
**Status:** Archived, safe to delete after verification
