# Shell Configuration

This directory contains a modular shell configuration for Zsh.

## Structure

```
shell/
├── aliases/           # Organized alias files by category
│   ├── chrome.sh     # Chrome development aliases
│   ├── core.sh       # Core system aliases (navigation, clipboard, etc.)
│   ├── dev.sh        # Development tools (Docker, Tmux, Jekyll, etc.)
│   ├── folders.sh    # Directory shortcuts
│   ├── git.sh        # Git aliases
│   ├── macos.sh      # macOS-specific aliases
│   └── tools.sh      # Modern CLI tool remappings
├── functions/         # Shell functions organized by purpose
│   ├── core.sh       # Essential utility functions
│   ├── dev.sh        # Development utilities
│   ├── macos.sh      # macOS-specific functions
│   └── media.sh      # Audio/video conversion functions
├── zshrc             # Main Zsh configuration
├── aliases.sh.backup # Backup of original aliases (safe to delete)
└── functions.sh.backup # Backup of original functions (safe to delete)
```

## Key Features

### Modular Organization
- Aliases and functions are split into logical categories
- Easy to enable/disable specific categories
- Better maintainability and readability

### Smart Directory Navigation
- **zoxide integration**: `cd` is aliased to `z` for smart directory jumping
- zoxide learns your most-used directories and provides smart completion
- Use `zi` for interactive directory selection

### Improvements Over Previous Config

1. **Fixed bugs**:
   - `enc()` and `dec()` functions now work correctly with proper I/O redirection
   - Added error handling to all functions
   - Improved safety checks for file operations

2. **Removed duplicates**:
   - Consolidated `copy` and `c` aliases
   - Removed obsolete/commented-out aliases

3. **Enhanced functions**:
   - Added usage documentation to all functions
   - Improved error messages with helpful hints
   - Better command existence checks

4. **Safety improvements**:
   - Functions verify files exist before operations
   - Better error handling in git-related functions
   - Clear error messages guide users to correct usage

## Usage

### Loading Configuration

The zshrc automatically loads all aliases and functions:

```zsh
# Load modular aliases
for alias_file in $DOTFILES/shell/aliases/*.sh; do
  source "$alias_file"
done

# Load modular functions
for func_file in $DOTFILES/shell/functions/*.sh; do
  source "$func_file"
done
```

### Disabling Specific Categories

To disable a category, simply rename or remove the file:

```bash
# Disable Chrome aliases
mv aliases/chrome.sh aliases/chrome.sh.disabled

# Or delete it entirely
rm aliases/chrome.sh
```

### Adding New Aliases/Functions

Add new aliases or functions to the appropriate category file, or create a new category:

```bash
# Create a new category
echo '#!/usr/bin/env zsh' > aliases/mycategory.sh
echo 'alias myalias="mycommand"' >> aliases/mycategory.sh
```

## Notable Aliases

### Navigation with zoxide
- `cd <query>` or `z <query>` - Smart directory jumping
- `zi` - Interactive directory picker

### Modern Tool Replacements
- `ls` → `eza` (with git integration)
- `cat` → `bat` (syntax highlighting)
- `find` → `fd` (faster, simpler)
- `top` → `htop` (better interface)
- `du` → `ncdu` (interactive disk usage)

### Git Shortcuts
- `gcan` - Amend commit without editing message
- `gds` - Diff staged changes
- `gcob` - Checkout branch with fzf picker

### Docker Compose
- `dcu` - docker compose up
- `dcud` - docker compose up -d
- `dcd` - docker compose down

## Notable Functions

### File Operations
- `mkd <dir>` - Create directory and cd into it
- `fs [path]` - Show file/directory size
- `enc <file>` - Base64 encode file to clipboard
- `dec <file>` - Base64 decode clipboard to file

### Development
- `server [port]` - Start HTTP server (default: 8000)
- `phpserver [port]` - Start PHP server (default: 4000)
- `gdb` - Remove git branches deleted from remote

### Media Conversion
- `flac2mp3` - Convert all FLAC files to MP3
- `flac2alac` - Convert all FLAC files to ALAC

### macOS Utilities
- `resetfontcache` - Fix Chrome font rendering issues
- `periodic` - Run maintenance scripts and purge memory
- `cdf` - cd to frontmost Finder window

## Dependencies

Some aliases and functions require specific tools:

- **eza** - Modern ls replacement (`brew install eza`)
- **bat** - Cat with syntax highlighting (`brew install bat`)
- **fd** - Modern find replacement (`brew install fd`)
- **zoxide** - Smart cd command (`brew install zoxide`)
- **fzf** - Fuzzy finder (`brew install fzf`)
- **htop** - Interactive process viewer (`brew install htop`)
- **ncdu** - Disk usage analyzer (`brew install ncdu`)
- **ffmpeg** - Media conversion (`brew install ffmpeg`)

## Testing Your Configuration

After updating, test your configuration:

```bash
# Reload shell
reload

# Test zoxide integration
z dotfiles  # Should jump to your dotfiles directory

# Test an alias
ll  # Should use eza with git integration

# Test a function
mkd test_dir  # Should create and enter directory
```

## Troubleshooting

If you encounter issues:

1. **Shell doesn't start**: Restore backup files
   ```bash
   mv aliases.sh.backup aliases.sh
   mv functions.sh.backup functions.sh
   ```

2. **Missing commands**: Install dependencies listed above

3. **zoxide not working**: Ensure it's initialized after oh-my-zsh:
   ```bash
   grep "zoxide init" ~/dotfiles/shell/zshrc
   ```

## Migration Notes

The old files are preserved as:
- `aliases.sh.backup`
- `functions.sh.backup`

These can be safely deleted once you've verified the new configuration works.
