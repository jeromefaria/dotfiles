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
├── PERFORMANCE.md               # Shell-startup performance notes
├── .gitignore
│
├── terminal/                    # Shell + terminal multiplexer
│   ├── zsh/                     # Zsh (primary)
│   │   ├── zshrc                # Main config
│   │   ├── aliases/             # Modular aliases (8 files)
│   │   ├── functions/           # Modular functions (10 files)
│   │   └── README.md
│   ├── bash/                    # Portable bash (Git Bash / restricted envs)
│   │   ├── bashrc.portable
│   │   └── PORTABLE.md
│   └── tmux/                    # Tmux + tmuxinator templates
│       ├── tmux.conf
│       └── README.md
│
├── editors/                     # Editor configs
│   ├── neovim/                  # Neovim (primary, lua + lazy.nvim)
│   │   ├── init.lua
│   │   ├── lua/{config,plugins}/
│   │   └── README.md
│   └── vim/                     # Vim (fallback)
│       ├── vimrc
│       └── README.md
│
├── git/                         # Git (gitconfig + portable + local-overrides example)
│   ├── gitconfig                # Symlinked to ~/.gitconfig
│   ├── gitconfig.portable
│   ├── gitconfig.local.example
│   └── README.md
│
├── ssh/                         # SSH client config (split portable / local)
│   ├── config                   # Symlinked to ~/.ssh/config
│   ├── config.local.example
│   └── README.md
│
├── claude/                      # Claude Code config
│   ├── CLAUDE.md                # Global instructions
│   └── README.md
│
├── config/                      # XDG-compliant tool configs (~/.config/*)
│   ├── README.md                # Overview
│   └── <34 subdirs>             # 10 have their own README (aria2, beets,
│                                # jerome-tooling, karabiner, musikcube, skhd,
│                                # starship, vifm, yabai, yazi)
│
├── mail/                        # Mbsync + notmuch + neomutt offline mail
│   ├── README.md
│   ├── FEATURES.md
│   ├── QUICK-REFERENCE.md
│   ├── GMAIL-SYNC-SETUP.md
│   ├── AUTO-SYNC-SETUP.md
│   ├── TESTING-GUIDE.md
│   ├── mutt/                    # Neomutt config
│   └── scripts/                 # sync-mail.sh + manage-sync.sh
│
├── packages/                    # Homebrew Brewfiles + install profiles
│   ├── README.md
│   ├── Brewfile.*               # Categorised package lists
│   ├── profiles/                # Installation profiles (minimal, full, etc.)
│   └── install-profile.sh
│
├── scripts/                     # Automation
│   ├── README.md
│   ├── install.sh               # Main installer (BASH_SOURCE-guarded for tests)
│   ├── bootstrap.sh             # `curl | bash` one-liner — self-contained
│   ├── uninstall.sh
│   ├── health-check.sh
│   ├── restore.sh / config.sh
│   ├── macos-setup.sh + macos/  # Modular macOS defaults setup
│   ├── audio-backup-*.sh, *.conf, *.md  # Drive → rclone backup w/ launchd
│   ├── test-*.sh                # Integration tests (mocked launchctl + drives)
│   └── lib/                     # Shared bash libs (io.sh, launchd-svc.sh)
│
├── bootstrap/                   # Git Bash-only setup helper
│   └── gitbash-setup.sh
│
└── docs/                        # Cross-cutting documentation
    ├── QUICK-START.md
    ├── ARCHITECTURE.md
    ├── TROUBLESHOOTING.md
    ├── macos-configuration.md
    ├── MACHINE-SPECIFIC-OVERRIDES.md
    └── dev/                     # Contributor docs
        ├── README.md            # This file
        ├── CONTRIBUTING.md
        └── session-notes/
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

**Definition:** Breaking change affects the live setup and requires a manual step on the next pull.

**Process:**

1. **Write a clear conventional commit:** Use the `!` marker (e.g. `refactor(zsh)!: …`) and put the migration step in the commit body — `git log` is the canonical change record for this repo, not a separate guide.

2. **Provide a migration script if the step is non-trivial:**
   ```bash
   # Create scripts/migrate-<topic>.sh
   ```

3. **Test the migration path:**
   - Test on a clean install
   - Test the upgrade from the pre-change state
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
