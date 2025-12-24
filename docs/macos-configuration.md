# macOS Configuration System

A modular, safe, and comprehensive system for configuring macOS settings via the command line.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Features](#features)
- [Directory Structure](#directory-structure)
- [Usage](#usage)
- [Configuration Modules](#configuration-modules)
- [Backup & Restore](#backup--restore)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Migration from Old Script](#migration-from-old-script)

## Overview

This configuration system provides a modular approach to setting up macOS with sensible defaults and developer-friendly settings. It includes:

- **Automatic backups** before making changes
- **Modular configuration** for different use cases
- **Safe restoration** from backups
- **Export functionality** to document current settings
- **Interactive and non-interactive modes**

## Quick Start

### First Time Setup

```bash
# Navigate to your dotfiles directory
cd ~/dotfiles

# Run the setup script interactively
./scripts/macos-setup.sh
```

The script will:
1. Show your system information
2. Ask which categories to apply
3. Create a backup of your current settings
4. Apply the selected configurations
5. Restart affected applications

### Apply All Settings

```bash
# Apply all settings non-interactively
./scripts/macos-setup.sh --all
```

### Apply Specific Categories

```bash
# Base settings only
./scripts/macos-setup.sh --base

# Base + Developer settings
./scripts/macos-setup.sh --dev

# Personal settings only
./scripts/macos-setup.sh --personal

# Third-party apps only
./scripts/macos-setup.sh --apps
```

## Features

### ✅ Safety Features

- **Automatic Backups**: Creates backups before applying changes
- **Restore Capability**: Revert to previous settings anytime
- **Error Handling**: Graceful handling of failures
- **Sudo Management**: Keeps sudo alive during long operations

### 🎯 Modular Design

- **Base Settings**: Core macOS improvements everyone benefits from
- **Developer Settings**: Tools and configurations for developers
- **Personal Settings**: User-specific preferences and regional settings
- **App Settings**: Third-party application configurations

### 📊 Documentation

- **Export Settings**: Document current configuration
- **Verbose Logging**: Clear output of all changes
- **Manifest Files**: Detailed backup contents

## Directory Structure

```
dotfiles/
├── scripts/
│   ├── macos-setup.sh           # Main orchestrator script
│   ├── macos-setup.sh.old       # Backup of original script
│   └── macos/                   # Modular configuration scripts
│       ├── backup-settings.sh   # Backup current settings
│       ├── restore-settings.sh  # Restore from backup
│       ├── export-settings.sh   # Export settings to file
│       ├── helpers.sh           # Shared utility functions
│       ├── base.sh              # Core OS settings
│       ├── developer.sh         # Developer tools & settings
│       ├── personal.sh          # Personal preferences
│       └── apps.sh              # Third-party app settings
└── docs/
    └── macos-configuration.md   # This file
```

## Usage

### Main Setup Script

```bash
./scripts/macos-setup.sh [OPTIONS]
```

**Options:**

| Option | Description |
|--------|-------------|
| `--all` | Apply all settings (base, developer, personal, apps) |
| `--base` | Apply only base settings |
| `--dev` | Apply base + developer settings |
| `--personal` | Apply only personal settings |
| `--apps` | Apply only third-party app settings |
| `--backup [name]` | Create a backup of current settings |
| `--restore <name>` | Restore settings from backup |
| `--export [file]` | Export current settings to file |
| `--no-backup` | Skip automatic backup before applying settings |
| `--help` | Show help message |

### Examples

```bash
# Interactive mode (recommended for first time)
./scripts/macos-setup.sh

# Apply all settings with auto-backup
./scripts/macos-setup.sh --all

# Apply only developer settings, no backup
./scripts/macos-setup.sh --dev --no-backup

# Create a named backup
./scripts/macos-setup.sh --backup before-upgrade

# Restore from a specific backup
./scripts/macos-setup.sh --restore before-upgrade

# Export current settings for documentation
./scripts/macos-setup.sh --export my-settings.txt

# Apply base and apps, skip personal
./scripts/macos-setup.sh --base --apps
```

## Configuration Modules

### Base Settings (`scripts/macos/base.sh`)

Core macOS improvements that benefit all users:

- **UI/UX Enhancements**
  - Faster window resize animations
  - Expanded save/print dialogs by default
  - Disabled smart quotes and dashes
  - Disabled automatic capitalization and period substitution

- **Finder Improvements**
  - Show all file extensions
  - Show path bar and status bar
  - Search current folder by default
  - Disable .DS_Store on network volumes
  - Show hidden Library folder

- **Dock Optimizations**
  - Auto-hide with no delay
  - Fast Mission Control animations
  - Don't rearrange Spaces automatically
  - Hide recent applications

- **Keyboard & Trackpad**
  - Fast key repeat rate
  - Tap to click enabled
  - Full keyboard access

- **Security**
  - Require password immediately after sleep
  - Disable quarantine warnings (for trusted sources)

- **Screenshots**
  - Save to ~/Pictures/Screenshots
  - PNG format
  - No thumbnail preview

### Developer Settings (`scripts/macos/developer.sh`)

Settings optimized for software development:

- **Safari Developer Tools**
  - Web Inspector enabled
  - Debug menus visible
  - Disable search suggestions

- **Debug Menus**
  - Address Book debug menu
  - Disk Utility advanced options
  - App Store WebKit tools

- **Development Tools**
  - Xcode build times shown
  - Git configuration helpers
  - Homebrew analytics disabled
  - npm recommended settings

- **Finder**
  - Show hidden files by default
  - QuickLook text selection

- **Performance**
  - Disabled sudden motion sensor

### Personal Settings (`scripts/macos/personal.sh`)

User-specific preferences (customize this file!):

- **Regional Settings**
  - Timezone (Europe/Lisbon by default)
  - Metric units
  - Language preferences

- **Appearance**
  - Dark/Light mode
  - Accent colors
  - Highlight colors

- **Computer Name**
  - Set custom computer name
  - Hostname configuration

- **Menu Bar**
  - Battery percentage
  - Clock format
  - Auto-hide option

- **Hot Corners**
  - Customizable corner actions
  - Mission Control
  - Lock screen

- **Security**
  - Firewall enabled
  - Stealth mode enabled
  - Guest account disabled
  - Remote services disabled

### App Settings (`scripts/macos/apps.sh`)

Third-party application configurations:

- **Browsers**
  - Google Chrome (navigation, print settings)
  - Opera
  - Safari (in developer.sh)

- **Utilities**
  - Transmission (torrent client)
  - Spectacle/Rectangle (window management)
  - Alfred (launcher)

- **Development**
  - iTerm2
  - Visual Studio Code
  - Sublime Text

- **Other**
  - Dropbox (icon removal)
  - Karabiner-Elements
  - Hammerspoon

## Backup & Restore

### Creating Backups

Backups are automatically created when running the setup script. You can also create manual backups:

```bash
# Create backup with timestamp
./scripts/macos/backup-settings.sh

# Create named backup
./scripts/macos/backup-settings.sh my-backup-name

# Via main script
./scripts/macos-setup.sh --backup my-backup-name
```

Backups are stored in `~/.macos-backups/` and include:

- NSGlobalDomain settings
- All application domain settings
- System-level settings
- NVRAM configuration
- Power management settings
- System setup details

### Listing Backups

```bash
ls -lh ~/.macos-backups/
```

### Restoring from Backup

```bash
# Restore from specific backup
./scripts/macos/restore-settings.sh backup-name

# Via main script
./scripts/macos-setup.sh --restore backup-name
```

**Note**: Some settings (NVRAM, systemsetup) require manual restoration for safety.

### Exporting Settings

Export your current settings to a human-readable file:

```bash
# Export to default file
./scripts/macos/export-settings.sh

# Export to custom file
./scripts/macos/export-settings.sh my-config.txt

# Via main script
./scripts/macos-setup.sh --export
```

The export includes all current settings in an organized, readable format.

## Customization

### Customizing Personal Settings

Edit `scripts/macos/personal.sh` to add your own preferences:

```bash
# Open in your preferred editor
vim scripts/macos/personal.sh

# Common customizations:
# - Set your timezone
# - Configure computer name
# - Set up hot corners
# - Choose dark/light mode
# - Configure menu bar
```

Many settings in `personal.sh` are commented out by default. Uncomment and customize them to your liking.

### Adding New Settings

To add new settings:

1. **For personal preferences**: Add to `scripts/macos/personal.sh`
2. **For developer tools**: Add to `scripts/macos/developer.sh`
3. **For new apps**: Add to `scripts/macos/apps.sh`
4. **For everyone**: Add to `scripts/macos/base.sh`

Example:

```bash
# In personal.sh
log_info "Setting custom wallpaper"
osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/path/to/wallpaper.jpg"'
```

### Creating Custom Modules

You can create additional modules:

```bash
# Create new module
touch scripts/macos/custom.sh
chmod +x scripts/macos/custom.sh

# Add to main script
# Edit scripts/macos-setup.sh and add calls to your custom module
```

## Troubleshooting

### Settings Not Applied

1. **Log out and log back in** - Some settings require a new session
2. **Restart your computer** - System-level changes may need a reboot
3. **Check permissions** - Ensure scripts have execute permissions
4. **Run with sudo** - Some settings require administrator privileges

### Reverting Changes

If something goes wrong:

```bash
# List available backups
ls ~/.macos-backups/

# Restore from the most recent backup
./scripts/macos-setup.sh --restore <backup-name>

# Restart your computer
sudo shutdown -r now
```

### Specific App Not Configured

The apps script only configures installed applications. If an app isn't configured:

1. Check if the app is installed in `/Applications/`
2. Verify the app name matches the script's check
3. Add custom configuration in `scripts/macos/apps.sh`

### Compatibility Issues

If you're on an older macOS version:

- Check the script output for warnings
- Some settings may not be available on older systems
- The script will gracefully skip unsupported settings

### Getting Help

1. Check the export file to see current settings:
   ```bash
   ./scripts/macos-setup.sh --export
   cat macos-settings-export.txt
   ```

2. Review backup manifests:
   ```bash
   cat ~/.macos-backups/<backup-name>/MANIFEST.txt
   ```

3. Check individual module scripts for specific settings

## Migration from Old Script

The original `macos-setup.sh` has been backed up to `macos-setup.sh.old`.

### Key Differences

| Old System | New System |
|------------|------------|
| Single 750+ line script | Modular scripts by category |
| No backups | Automatic backups |
| All-or-nothing | Selective application |
| No restoration | Full restore capability |
| Hard to customize | Easy to customize per module |
| Deprecated settings | Modern macOS settings |
| No documentation | Comprehensive docs |

### Migration Steps

1. **Export your current settings** before migration:
   ```bash
   ./scripts/macos-setup.sh --export before-migration.txt
   ```

2. **Review the modules** to see what will change:
   ```bash
   cat scripts/macos/base.sh
   cat scripts/macos/developer.sh
   cat scripts/macos/personal.sh
   ```

3. **Customize personal.sh** with your preferences:
   ```bash
   vim scripts/macos/personal.sh
   ```

4. **Create a backup** of current state:
   ```bash
   ./scripts/macos-setup.sh --backup pre-migration
   ```

5. **Apply new settings**:
   ```bash
   ./scripts/macos-setup.sh --all
   ```

6. **Compare results**:
   ```bash
   ./scripts/macos-setup.sh --export after-migration.txt
   diff before-migration.txt after-migration.txt
   ```

### Settings Removed from Old Script

The following deprecated settings were removed:

- MacBook Air SuperDrive NVRAM setting
- iOS Simulator path (Xcode changed this)
- Local Time Machine snapshot disabling (deprecated)
- Some Yosemite/Lion-specific settings
- Conflicting NVRAM boot-args

These either don't work on modern macOS or have been superseded.

### New Settings Added

- Dark mode support
- Dock recents control
- Stage Manager configuration
- Modern screenshot options
- Folders-first sorting in Finder
- Control Center configuration
- Better security defaults (firewall, stealth mode)
- .DS_Store prevention on USB drives
- Modern keyboard settings
- Better error handling throughout

## Best Practices

1. **Always backup first**: The script does this automatically, but you can create manual backups too

2. **Customize personal.sh**: This is where your unique preferences go

3. **Test incrementally**: Apply base settings first, then add more modules

4. **Document changes**: Use the export feature to document your setup

5. **Version control**: Keep your customized scripts in git

6. **Review before applying**: Read through the scripts to understand what changes will be made

7. **Restart after major changes**: Some settings need a restart to fully apply

## Additional Resources

- [macOS defaults commands](https://macos-defaults.com/)
- [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles)
- [macOS Security Guide](https://github.com/drduh/macOS-Security-and-Privacy-Guide)

## Contributing

To contribute improvements:

1. Test your changes thoroughly
2. Follow the existing code style
3. Add appropriate logging
4. Update documentation
5. Consider backwards compatibility

## License

Part of your personal dotfiles configuration system.

---

Last updated: 2025-12-24
