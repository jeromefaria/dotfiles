# Developer Documentation

Documentation for contributing to and maintaining this dotfiles repository.

## Table of Contents

- [Overview](#overview)
- [Development Setup](#development-setup)
- [Repository Structure](#repository-structure)
- [Workflows](#workflows)
- [Documentation Standards](#documentation-standards)
- [Maintenance Tasks](#maintenance-tasks)
- [Architecture Overview](#architecture-overview)

---

## Overview

This directory contains development-related documentation:

- **[ROADMAP.md](ROADMAP.md)** - Planned improvements and infrastructure roadmap
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute to this repository
- **session-notes/** - Archived development session logs (for reference)

**Target Audience:** Contributors, maintainers, and anyone modifying the dotfiles system.

---

## Development Setup

### Prerequisites

**Required:**
- macOS 11+ (for testing)
- Git 2.30+
- Xcode Command Line Tools
- Homebrew

**Recommended:**
- Multiple macOS versions for testing (VM or separate machines)
- GitHub account for pull requests
- Familiarity with shell scripting, Lua (for Neovim), and dotfiles concepts

### Local Development Workflow

**1. Fork and Clone:**

```bash
# Fork on GitHub first
git clone https://github.com/YOUR-USERNAME/dotfiles.git ~/dotfiles-dev
cd ~/dotfiles-dev
```

**2. Create Feature Branch:**

```bash
git checkout -b feature/my-improvement
```

**3. Make Changes:**

Edit configuration files, scripts, or documentation.

**4. Test Without Affecting Live System:**

```bash
# Option 1: Test in subshell
zsh -c "source ~/dotfiles-dev/terminal/zsh/zshrc"

# Option 2: Test specific files
source ~/dotfiles-dev/terminal/zsh/aliases/dev.sh

# Option 3: Use separate install location
./scripts/install.sh --target ~/.dotfiles-test
```

**5. Commit and Push:**

```bash
git add .
git commit -m "feat(component): description of change"
git push origin feature/my-improvement
```

**6. Open Pull Request:**

Open PR on GitHub with description of changes.

### Testing Changes

**Manual Testing Checklist:**

- [ ] Shell loads without errors: `zsh -n ~/dotfiles/terminal/zsh/zshrc`
- [ ] Aliases work as expected: `source ~/.zshrc && type alias-name`
- [ ] Functions execute correctly: `function-name test-args`
- [ ] Symlinks created properly: `./scripts/health-check.sh`
- [ ] Neovim config valid: `nvim --headless -c "quit"`
- [ ] Tmux config valid: `tmux source ~/.tmux.conf`
- [ ] Git config valid: `git config --list`
- [ ] No broken links in docs: Manually check markdown files

**Automated Tests:**

Currently manual testing. Future: Add automated tests for:
- Shell script linting (shellcheck)
- Lua linting (luacheck)
- Link checking (markdown-link-check)

---

## Repository Structure

### Directory Layout

```
dotfiles/
├── README.md                    # Main entry point
├── .gitignore                   # Ignored files
│
├── shell/                       # Shell configuration
│   ├── zshrc                    # Main ZSH config
│   ├── aliases/                 # Modular aliases (7 files)
│   ├── functions/               # Modular functions (4 files)
│   ├── README.md                # Shell documentation
│   ├── QUICK_REFERENCE.md       # Daily use cheat sheet
│   ├── CHANGELOG.md             # Shell change history
│   └── PORTABLE.md              # Portable bash config
│
├── editors/                     # Editor configurations
│   ├── neovim/                  # Neovim (primary)
│   │   ├── init.lua             # Entry point
│   │   ├── lua/                 # Lua configuration
│   │   │   ├── config/          # Core settings
│   │   │   └── plugins/         # Plugin configs
│   │   └── README.md            # Neovim documentation
│   └── vim/                     # Vim (fallback)
│       ├── vimrc                # Vim config
│       └── README.md            # Vim documentation
│
├── terminal/                    # Terminal multiplexer
│   ├── tmux.conf                # Tmux configuration
│   ├── tmuxinator/              # Session templates
│   └── README.md                # Tmux documentation
│
├── git/                         # Version control
│   ├── gitconfig                # Git configuration
│   ├── gitconfig.local.example  # Machine-specific template
│   └── README.md                # Git documentation
│
├── config/                      # XDG-compliant configs
│   ├── README.md                # Config directory overview
│   ├── aria2/                   # Download manager
│   ├── beets/                   # Music library
│   ├── karabiner/               # Keyboard remapping
│   ├── musikcube/               # Music player
│   ├── skhd/                    # Hotkey daemon
│   ├── starship/                # Shell prompt
│   ├── vifm/                    # File manager
│   ├── yabai/                   # Window manager
│   ├── yazi/                    # File manager
│   └── [20+ other tools]/
│
├── mail/                        # Email configuration
│   ├── README.md                # Mail overview
│   ├── FEATURES.md              # Feature documentation
│   ├── QUICK-REFERENCE.md       # Keybinding reference
│   ├── GMAIL-SYNC-SETUP.md      # Gmail setup guide
│   ├── AUTO-SYNC-SETUP.md       # Background sync
│   ├── TESTING-GUIDE.md         # Testing guide
│   └── mutt/                    # Neomutt configs
│
├── packages/                    # Package management
│   ├── README.md                # Package system docs
│   ├── Brewfile.*               # Categorized packages
│   ├── profiles/                # Installation profiles
│   ├── install-profile.sh       # Profile installer
│   └── sync-packages.sh         # Package sync tool
│
├── scripts/                     # Automation scripts
│   ├── bootstrap.sh             # One-line installer
│   ├── install.sh               # Main installer
│   ├── uninstall.sh             # Uninstaller
│   ├── health-check.sh          # System verification
│   ├── restore.sh               # Backup restore
│   └── macos-setup.sh           # macOS preferences
│
└── docs/                        # Documentation
    ├── QUICK-START.md           # 5-minute setup
    ├── TROUBLESHOOTING.md       # Common issues
    ├── MIGRATION-GUIDE.md       # Version upgrades
    ├── ARCHITECTURE.md          # System design
    ├── MACHINE-SPECIFIC-OVERRIDES.md  # Per-machine setup
    └── dev/                     # Developer docs
        ├── README.md            # This file
        ├── CONTRIBUTING.md      # Contribution guide
        ├── ROADMAP.md           # Future plans
        └── session-notes/       # Archived notes
```

### Key Integration Points

**Shell → Everything:**
- Loads environment variables for all tools
- Provides aliases and functions
- Sources machine-specific overrides

**Install Script → All Configs:**
- Creates symlinks from `dotfiles/` to `~/`
- Manages backup/restore
- Verifies dependencies

**Package Profiles → Installation:**
- Defines sets of tools to install
- Enables selective installation (minimal, dev, full)

---

## Workflows

### Adding a New Configuration

**Example:** Adding a new tool configuration

1. **Create configuration file(s):**
   ```bash
   mkdir -p config/newtool
   cp /path/to/newtool/config config/newtool/config-file
   ```

2. **Add to install.sh symlink section:**
   ```bash
   # Edit scripts/install.sh
   # Add symlink creation:
   create_symlink "$DOTFILES/config/newtool" "$HOME/.config/newtool"
   ```

3. **Create README.md documentation:**
   ```bash
   # Use standard template (see Documentation Standards below)
   nvim config/newtool/README.md
   ```

4. **Add to appropriate package Brewfile:**
   ```bash
   # Edit packages/Brewfile.utilities (or appropriate category)
   brew "newtool"
   ```

5. **Test installation:**
   ```bash
   ./scripts/install.sh
   brew install newtool
   ```

6. **Commit changes:**
   ```bash
   git add config/newtool/ scripts/install.sh packages/Brewfile.utilities
   git commit -m "feat(config): add newtool configuration"
   ```

### Adding Documentation

**When to create new file vs. update existing:**
- **New file:** New component, new major topic, or distinct audience
- **Update existing:** Related to existing component, clarification, or enhancement

**Process:**

1. **Determine documentation type:**
   - Component README: `component/README.md`
   - User guide: `docs/TOPIC.md`
   - Developer doc: `docs/dev/TOPIC.md`

2. **Follow documentation standards** (see below)

3. **Update cross-references:**
   - Add to main README.md navigation
   - Link from related documentation

4. **Add to main README.md:**
   ```markdown
   ### Component Documentation
   - [NewTool](config/newtool/README.md) - Description
   ```

### Making Breaking Changes

**Definition:** Breaking change affects existing users' workflow or requires manual intervention.

**Process:**

1. **Document in MIGRATION-GUIDE.md:**
   ```markdown
   ### Version X.Y (Date)

   #### Breaking Changes
   - **Change description**
     - Old behavior: ...
     - New behavior: ...
     - Migration: ...
   ```

2. **Update version number:** (if versioning implemented)

3. **Provide migration script if possible:**
   ```bash
   # Create scripts/migrate-vX.Y.sh
   ```

4. **Test migration path:**
   - Test on clean install
   - Test upgrade from previous version
   - Verify rollback works

5. **Update CHANGELOG:**
   ```markdown
   ## Version X.Y - YYYY-MM-DD

   ### Breaking Changes
   - **Component**: Description
   ```

---

## Documentation Standards

### File Naming

- **kebab-case:** `my-document.md`
- **README.md:** Main documentation for directories
- **UPPERCASE.md:** Top-level/important docs (ARCHITECTURE.md, QUICK-START.md)

### Standard Template for Component READMEs

```markdown
# [Component Name]

[2-3 sentence overview]

## Quick Links

- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Usage](#usage)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)

## Overview

[Detailed description]
[Key features - bullet points]

## Installation

[How this component is installed]
[Dependencies]

## Configuration

[Configuration files explained]
[Key settings breakdown]

## Usage

[Basic operations]
[Common workflows]

## Customization

[How to modify]

## Integration

[How this integrates with other components]

## Troubleshooting

[Common issues]

## Related Documentation

- [Main README](../../README.md)
- [Other relevant docs]

## Resources

- [Official docs]
- [GitHub repo]

---

**Status:** ✅ Complete / ⚠️ Partial / ❌ Draft
**Last Updated:** YYYY-MM-DD
```

### Code Blocks

Always specify language:

````markdown
```bash
command here
```

```lua
-- Lua code
```

```yaml
key: value
```
````

### Cross-References

- **Use relative paths:** `[link](../path/to/file.md)`
- **Descriptive link text:** `[Neovim Configuration](../editors/neovim/README.md)` not `[click here](../editors/neovim/README.md)`
- **Verify links work:** Test links after adding

### Table of Contents

**Required for:** Docs > 100 lines

**Format:**
```markdown
## Table of Contents

- [Section 1](#section-1)
- [Section 2](#section-2)
```

---

## Maintenance Tasks

### Monthly

- [ ] Review "Last Updated" dates in docs
- [ ] Check for broken links (manual or use tool)
- [ ] Test health-check.sh
- [ ] Review open GitHub issues

### Quarterly

- [ ] Review session notes in `docs/dev/session-notes/`
- [ ] Update ROADMAP.md with completed items
- [ ] Consolidate CHANGELOG entries
- [ ] Update dependency versions in docs
- [ ] Check for deprecated Homebrew formulas

### Per New Feature

- [ ] Create README if new component
- [ ] Update relevant cross-references
- [ ] Add to troubleshooting if applicable
- [ ] Update package Brewfile
- [ ] Test installation from scratch

---

## Architecture Overview

See [ARCHITECTURE.md](../ARCHITECTURE.md) for complete system architecture.

**Key Components:**

1. **Shell (ZSH)**
   - Entry point for environment
   - Loads all environment variables
   - Sources modular aliases/functions
   - Integrates with Git, Neovim, Tmux

2. **Install Script**
   - Central orchestrator
   - Creates all symlinks
   - Manages backups
   - Verifies dependencies

3. **Package Profiles**
   - Define sets of tools
   - Enable selective installation
   - Categories: base, dev, music, media, etc.

4. **Machine-Specific Overrides**
   - `.local` files for per-machine customization
   - Not tracked in git
   - Loaded after main configs

**Data Flow:**

```
User Runs Bootstrap/Install
         ↓
Install Script Executes
         ↓
Creates Symlinks (dotfiles/ → ~/)
         ↓
Installs Package Managers (Homebrew, Oh My Zsh, TPM)
         ↓
Optionally Installs Packages (Brewfile)
         ↓
Sets ZSH as Default Shell
         ↓
User Reloads Shell
         ↓
Shell Loads Configs (zshrc → aliases → functions → .local)
         ↓
User Has Configured Environment
```

---

## Getting Help

**Development questions?**

1. **Review existing documentation:**
   - [Architecture](../ARCHITECTURE.md)
   - [Troubleshooting](../TROUBLESHOOTING.md)
   - Component READMEs

2. **Check git history:**
   ```bash
   git log --oneline -- path/to/file
   git blame path/to/file
   ```

3. **Open an issue:**
   - [GitHub Issues](https://github.com/jeromefaria/dotfiles/issues)
   - Tag as "question" or "discussion"

---

**Status:** ✅ Complete
**Last Updated:** 2025-12-20
