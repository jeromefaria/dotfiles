# Configuration Index

Complete reference for all dotfiles configurations, organized by category with documentation status and key features.

## Quick Navigation

- [Shell](#shell-configuration)
- [Editors](#editors)
- [Terminal](#terminal)
- [Version Control](#version-control)
- [Window Management](#window-management-macos)
- [Email](#email)
- [File Managers](#file-managers)
- [Music & Media](#music--media)
- [Development Tools](#development-tools)
- [System Utilities](#system-utilities)

---

## Shell Configuration

### ZSH (`shell/`)

**Documentation:** ✅ Comprehensive - [shell/README.md](shell/README.md)

**Main Config:** `shell/zshrc` (171 lines)
- Leader: Oh My Zsh with 22 plugins
- Vi mode with `jk` and `jj` escape
- zoxide for smart directory jumping
- FNF for Node version management
- Starship prompt

**Modular Aliases:** 7 categories
| File | Purpose | Key Aliases |
|------|---------|-------------|
| `aliases/core.sh` | Basic operations | `..`, `...`, `pbcopy`, `encode`, `decode`, `json` |
| `aliases/git.sh` | Git shortcuts | `gcan`, `gdc`, `gds`, `gfl`, `gcob` (with fzf) |
| `aliases/dev.sh` | Development | `dc`, `dce`, `dcr`, `mysql`, `ta`, `sj`, `update` |
| `aliases/folders.sh` | Directory shortcuts | Quick access to common directories |
| `aliases/macos.sh` | macOS specific | `show`, `hide`, `cleanup`, `emptytrash` |
| `aliases/chrome.sh` | Chrome dev | Browser testing flags |
| `aliases/tools.sh` | CLI replacements | `ls`→`eza`, `cat`→`bat`, `find`→`fd` |

**Functions:** 4 categories
| File | Functions | Purpose |
|------|-----------|---------|
| `functions/core.sh` | `mkd`, `cdf`, `fs`, `enc`, `dec` | File operations, encoding |
| `functions/dev.sh` | `server`, `phpserver`, `upgradenode` | Dev servers |
| `functions/macos.sh` | macOS utilities | System operations |
| `functions/media.sh` | `flac2mp3`, `flac2alac` | Audio conversion |

**Machine-Specific:** `~/.zshrc.local` (optional, not tracked)

---

## Editors

### Neovim (`editors/neovim/`)

**Documentation:** ✅ Complete - [editors/neovim/README.md](editors/neovim/README.md)

**Features:**
- LSP support (lua_ls, ts_ls, pyright + more)
- Autocompletion (nvim-cmp)
- Fuzzy finding (Telescope)
- Syntax highlighting (Treesitter)
- Git integration (Fugitive, gitsigns)
- Formatting & linting

**Leader Key:** `<Space>`

**Essential Keybindings:**
| Key | Action |
|-----|--------|
| `<Space>ff` | Find files |
| `<Space>fg` | Live grep |
| `<Space>e` | File explorer |
| `gd` | Go to definition |
| `<Space>ca` | Code actions |
| `<Space>f` | Format |
| `jk` | Exit insert mode |

**Config Structure:**
- `lua/config/` - Core settings (options, keymaps, autocmds)
- `lua/plugins/` - Plugin configurations (lsp, telescope, treesitter, ui, git)

### Vim (`editors/vim/`)

**Documentation:** ⚠️ Basic inline comments

Legacy Vim config for systems without Neovim.

**Leader Key:** `,` (comma)

---

## Terminal

### Tmux (`terminal/tmux.conf`)

**Documentation:** ⚠️ Inline comments only - [Needs README]

**Prefix:** `F12` (via PCKeyboardHack mapping Caps Lock → F12)

**Key Features:**
- Vi mode enabled
- 16 splits max for performance
- Mouse support
- TPM (Tmux Plugin Manager)
- Vim-Tmux navigation integration

**Plugins:**
- tmux-resurrect - Save/restore sessions
- tmux-continuum - Auto-save sessions
- tmux-urlview - Extract URLs
- tmux-battery - Battery status
- tmux-copycat - Search enhancement
- tmux-open - Open files/URLs
- vim-tmux-navigator - Seamless Vim/Tmux navigation

**Essential Bindings:**
| Key | Action |
|-----|--------|
| `F12` | Prefix |
| `F12 + |` | Split vertical |
| `F12 + -` | Split horizontal |
| `F12 + hjkl` | Navigate panes |
| `F12 + HJKL` | Resize panes |
| `F12 + Shift-Arrow` | Swap windows |

### Tmuxinator (`terminal/tmuxinator/`)

**Documentation:** ❌ No documentation

Session templates for projects:
- `b.yml`
- `d.yml`
- `p.yml`

**Action:** Document what each template does and available variables.

---

## Version Control

### Git (`git/gitconfig`)

**Documentation:** ✅ Complete - [git/README.md](git/README.md)

**Aliases:**
| Alias | Command | Usage |
|-------|---------|-------|
| `co` | checkout | `git co branch-name` |
| `ci` | commit | `git ci -m "message"` |
| `st` | status | `git st` |
| `br` | branch | `git br -a` |
| `hist` | Pretty log | `git hist --all` |

**Features:**
- diff-so-fancy for beautiful diffs
- Git LFS support
- Rebase-first pull strategy
- Machine-specific overrides (`~/.gitconfig.local`)

**Pager:** diff-so-fancy with custom less options

---

## Window Management (macOS)

### SKHD (`config/skhd/`)

**Documentation:** ✅ Complete - [config/skhd/README.md](config/skhd/README.md)

Hotkey daemon for window management with Yabai.

**Key Bindings:**
| Action | Keybinding |
|--------|------------|
| Resize left | `Ctrl + Alt + H` |
| Resize right | `Ctrl + Alt + L` |
| Resize up | `Ctrl + Alt + K` |
| Resize down | `Ctrl + Alt + J` |
| Swap windows | `Ctrl + Shift + H/J/K/L` |
| Rotate layout | `Ctrl + Shift + R` |
| Toggle fullscreen | `Ctrl + Shift + F` |
| Balance windows | `Ctrl + Alt + 0` |

### Yabai (`config/yabai/`)

**Documentation:** ✅ Complete - [config/yabai/README.md](config/yabai/README.md)

Tiling window manager for macOS.

**Layout:** BSP (Binary Space Partitioning)
**Gap Size:** 6px
**Mouse Modifier:** `fn` key

**Features:**
- Automatic window tiling
- Space management
- App-specific rules (float certain apps)
- Mouse controls with fn key

**Excluded Apps:** System Preferences, Finder, 1Password, DAWs, media players

---

## Email

### Neomutt (`mail/mutt/`)

**Documentation:** ✅ Excellent - [mail/mutt/README.md](mail/mutt/README.md)

Terminal email client with Vim-style navigation.

**Config Files:**
- `muttrc` - Main config
- `settings` - General options
- `bindings` - Custom keybindings
- `macros` - Quick actions
- `colours` - Color scheme
- `mailcap` - MIME handlers
- `accounts/` - Account configs

**Key Features:**
- IMAP IDLE support
- Vim-style keybindings
- Sidebar for folders
- HTML email viewing
- GPG encryption support

---

## File Managers

### Yazi (`config/yazi/`)

**Documentation:** ❌ Minimal - [Needs README]

Modern terminal file manager with:
- Vim-style keybindings
- File preview
- Opener definitions for different file types
- MIME type-based file handling

**Files:**
- `yazi.toml` - Main configuration
- `keymap.toml` - Keybindings (254 lines with descriptions)
- `theme.toml` - Color scheme

**Action:** Create README documenting:
- Opener definitions and usage
- MIME type rules
- Custom keybindings
- Layout configuration

### Vifm (`config/vifm/vifmrc`)

**Documentation:** ⚠️ Sample comments (11KB file)

Vi-like file manager with extensive customization.

**Action:** Document active customizations vs. example settings.

### Ranger (`config/ranger/`)

**Documentation:** ❌ No documentation

Vim-inspired file manager.

---

## Music & Media

### Beets (`config/beets/config.yaml`)

**Documentation:** ❌ None - [HIGH PRIORITY]

Music library manager with 170 lines of YAML configuration.

**Features:**
- Library path management
- Import settings (copy/move/link options)
- Metadata handling with replace rules
- Multiple plugins (discogs, lastgenre, fetchart, embedart, lyrics, mbsync)
- MusicBrainz integration

**Plugins Configured:**
| Plugin | Purpose |
|--------|---------|
| discogs | Discogs metadata fetching |
| lastgenre | Genre tagging from Last.fm |
| fetchart | Album art downloading |
| embedart | Embed art in files |
| lyrics | Fetch lyrics |
| albumtypes | Album type management |
| mbsync | MusicBrainz sync |

**Action:** Create comprehensive README explaining:
- Plugin setup and usage
- Path format variables
- Import workflow
- Metadata matching
- Distance weights

### Musikcube (`config/musikcube/`)

**Documentation:** ❌ None - [NEEDS DOCUMENTATION]

Terminal music player with 11 JSON config files.

**Files:**
- `settings.json` - Main settings
- `hotkeys.json` - Keybindings
- `plugin_*.json` - Plugin configurations

**Action:** Document plugin configurations and output settings.

### MPV (`config/mpv/mpv.conf`)

**Documentation:** ✅ Minimal but adequate (5 lines)

Media player with minimal configuration using sensible defaults.

### NCMPCPP (`config/ncmpcpp/`)

**Documentation:** ❌ No documentation

MPD client configuration.

---

## Development Tools

### Node.js

**FNM:** Node version manager configured in zshrc
```bash
eval "$(fnm env)"
```

### Language Servers

See [Neovim LSP Documentation](editors/neovim/README.md#lsp-servers)

Auto-installed via Mason:
- lua_ls (Lua)
- ts_ls (TypeScript/JavaScript)
- pyright (Python)

---

## System Utilities

### Aria2 (`config/aria2/aria2.conf`)

**Documentation:** ⚠️ Minimal inline comments

Download manager configuration with:
- BitTorrent settings
- Connection limits
- Seed ratio: 0.0
- Multiple tracker lists

**Parameters:**
| Setting | Value | Purpose |
|---------|-------|---------|
| `enable-dht` | true | Distributed hash table |
| `bt-enable-lpd` | true | Local peer discovery |
| `max-connection-per-server` | 16 | Connections per file |
| `min-split-size` | 10M | Chunk size |
| `bt-max-peers` | 50 | Max peers |
| `seed-ratio` | 0.0 | Don't seed after download |

### Bat (`config/bat/config`)

**Documentation:** ✅ Good inline examples

`cat` replacement with syntax highlighting.

**Theme:** Dracula
**Features:**
- Syntax mapping
- Paging configuration
- Git integration

### Starship (`config/starship.toml`)

**Documentation:** ⚠️ Minimal (14 lines)

Shell prompt configuration.

**Disabled Modules:**
- nodejs
- php
- aws

**Action:** Expand configuration with more visible git/path info.

### Atuin (`config/atuin/config.toml`)

**Documentation:** ✅ Excellent inline examples (273 lines)

Shell history manager with:
- Database and sync settings
- Search modes (prefix, fulltext, fuzzy, skim)
- Filter modes (global, host, session, directory)
- Stats configuration
- Key bindings
- Theme support

**Most settings are commented examples**

### Karabiner (`config/karabiner/karabiner.json`)

**Documentation:** ❌ None - [HIGH PRIORITY]

Keyboard remapping with 249KB of JSON configuration.

**Action:** Create README documenting:
- Active key remappings
- How to add new rules
- Conditional logic for different apps

---

## Configuration Documentation Status

### ✅ Excellent (100+ lines or comprehensive inline)
1. Shell configuration - `shell/README.md` (200 lines)
2. Neomutt - `mail/mutt/README.md` (142 lines)
3. Neovim - `editors/neovim/README.md` (NEW, 600+ lines)
4. Git - `git/README.md` (NEW, 400+ lines)
5. Yabai - `config/yabai/README.md` (418 lines)
6. SKHD - `config/skhd/README.md` (244 lines)

### ✅ Good (Inline comments or basic README)
7. Tmux configuration (inline, 89 lines)
8. Bat configuration (inline examples)
9. Atuin configuration (inline examples, 273 lines)
10. Config directory - `config/README.md` (43 lines)

### ✅ Excellent (100+ lines or comprehensive inline)
11. Beets - `config/beets/README.md` (880+ lines)
12. Yazi - `config/yazi/README.md` (770+ lines)
13. Tmux/Tmuxinator - `terminal/README.md` (700+ lines)
14. Karabiner - `config/karabiner/README.md` (650+ lines) - **NEW**

### ⚠️ Needs Improvement
15. Musikcube - 11 JSON files, auto-generated [MEDIUM]
16. Vifm - 11KB config, unclear settings [MEDIUM]
17. Starship - Minimal config [LOW]
18. Aria2 - Minimal inline comments [LOW]

---

## Priority Documentation Tasks

### Completed ✅
- [x] Neovim comprehensive README
- [x] Git comprehensive README
- [x] Configuration index (this file)
- [x] Beets music library README
- [x] Yazi file manager README
- [x] Tmux/Tmuxinator README
- [x] Karabiner keyboard remapping README - **NEW**

### High Priority
(All high-priority documentation complete!)

### Medium Priority
- [ ] Musikcube README
- [ ] Vifm configuration clarification
- [ ] Inline comments for Beets config.yaml

### Low Priority
- [ ] Expand Starship configuration
- [ ] Aria2 configuration details
- [ ] Additional tool configs

---

## File Locations

### Dotfiles Repository
```
~/dotfiles/
├── config/              # XDG configs
├── editors/             # Vim/Neovim
├── git/                 # Git config
├── mail/                # Email (Neomutt)
├── packages/            # Homebrew packages
├── scripts/             # Installation scripts
├── shell/               # ZSH configuration
└── terminal/            # Tmux/Tmuxinator
```

### Symlinked Locations
```
~/.zshrc              → ~/dotfiles/shell/zshrc
~/.vimrc              → ~/dotfiles/editors/vim/vimrc
~/.tmux.conf          → ~/dotfiles/terminal/tmux.conf
~/.gitconfig          → ~/dotfiles/git/gitconfig
~/.config/nvim/       → ~/dotfiles/editors/neovim/
~/.config/neomutt/    → ~/dotfiles/mail/mutt/
~/.config/skhd/       → ~/dotfiles/config/skhd/
~/.config/yabai/      → ~/dotfiles/config/yabai/
# ... and more XDG configs
```

---

## Quick Reference

### Most Common Configs

| Tool | Config File | Documentation |
|------|-------------|---------------|
| ZSH | `shell/zshrc` | [README](shell/README.md) |
| Neovim | `editors/neovim/` | [README](editors/neovim/README.md) |
| Tmux | `terminal/tmux.conf` | Inline only |
| Git | `git/gitconfig` | [README](git/README.md) |
| Neomutt | `mail/mutt/` | [README](mail/mutt/README.md) |

### Documentation Locations

- Main README: `README.md`
- Architecture: `docs/ARCHITECTURE.md`
- Installation: `docs/INSTALLATION-IMPROVEMENTS.md`
- Machine Overrides: `docs/MACHINE-SPECIFIC-OVERRIDES.md`
- This Index: `CONFIGURATION-INDEX.md`

---

## Getting Help

### For Specific Configurations

1. Check if README exists in that directory
2. Look for inline comments in config file
3. Refer to this index for overview
4. Check `docs/ARCHITECTURE.md` for integration info

### For Installation Issues

1. Run health check: `./scripts/health-check.sh`
2. Check `docs/INSTALLATION-IMPROVEMENTS.md`
3. Review `README.md` installation section

### For Keybindings

- Shell: `shell/README.md`
- Neovim: `editors/neovim/README.md`
- Tmux: Check `terminal/tmux.conf` inline comments
- SKHD: `config/skhd/README.md`
- Neomutt: `mail/mutt/README.md`

---

**Last Updated:** November 26, 2024
**Total Configurations:** 50+ files
**Documented:** ~65% (was 40% → 60% → 65%)
**Target:** 90%+

**Recent additions:**
- Session 1: Beets (880 lines), Yazi (770 lines), Tmux (700 lines) - +2,350 lines
- Session 2: Karabiner (650 lines) - +650 lines
- **Total documentation added:** +3,000 lines
