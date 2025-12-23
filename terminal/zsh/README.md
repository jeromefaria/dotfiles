# Shell Configuration

Modular Zsh configuration with aliases and functions organized by category.

## Structure

```
shell/
├── aliases/           # Alias files by category
│   ├── chrome.sh     # Chrome development
│   ├── core.sh       # Navigation, clipboard, etc.
│   ├── dev.sh        # Docker, Tmux, Jekyll
│   ├── folders.sh    # Directory shortcuts
│   ├── git.sh        # Git aliases
│   ├── macos.sh      # macOS-specific
│   └── tools.sh      # Modern CLI remappings
├── functions/         # Functions by purpose
│   ├── core.sh       # Utility functions
│   ├── dev.sh        # Development utilities
│   ├── macos.sh      # macOS functions
│   └── media.sh      # Audio/video conversion
├── zshrc             # Main configuration
├── bashrc.portable   # Portable bash config for restricted environments
└── PORTABLE.md       # Portable config documentation
```

## Aliases

### Navigation (zoxide)
- `cd <query>` / `z <query>` - Smart directory jumping
- `zi` - Interactive directory picker

### Modern Tool Replacements
- `ls` → `eza` (with git integration)
- `cat` → `bat` (syntax highlighting)
- `find` → `fd` (faster, simpler)
- `top` → `htop`
- `du` → `ncdu`

### Git
- `gcan` - Amend commit without editing message
- `gds` - Diff staged changes
- `gcob` - Checkout branch with fzf

### Docker Compose
- `dcu` - docker compose up
- `dcud` - docker compose up -d
- `dcd` - docker compose down

## Functions

### File Operations
- `mkd <dir>` - Create directory and cd into it
- `fs [path]` - Show file/directory size
- `enc <file>` - Base64 encode file to clipboard
- `dec <file>` - Base64 decode clipboard to file

### Development
- `server [port]` - Start HTTP server (default: 8000)
- `phpserver [port]` - Start PHP server (default: 4000)
- `gdb` - Remove git branches deleted from remote
- `update [options]` - Update system packages and tools
  - `--skip-brew`, `--skip-npm`, `--skip-gems`, `--skip-mas`, `--skip-omz`, `--skip-tldr`

### Media
- `flac2mp3` - Convert FLAC files to MP3
- `flac2alac` - Convert FLAC files to ALAC
- `update-music-plugins [options]` - Update plugin managers
  - `--all`, `--native`, `--izotope`, `--output`, `--list`

### macOS
- `resetfontcache` - Fix Chrome font rendering
- `periodic` - Run maintenance scripts
- `cdf` - cd to Finder window

## Customization

### Disable a category
```bash
mv aliases/chrome.sh aliases/chrome.sh.disabled
```

### Add new aliases
```bash
echo 'alias myalias="mycommand"' >> aliases/dev.sh
```

### Machine-specific config
Create `~/.zshrc.local` for settings not tracked in git.

## Dependencies

Install via Homebrew:
```bash
brew install eza bat fd zoxide fzf htop ncdu ffmpeg
```
