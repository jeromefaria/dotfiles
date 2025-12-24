# macOS Configuration Scripts

This directory contains modular scripts for configuring macOS settings.

## Quick Reference

### Main Scripts

| Script | Purpose |
|--------|---------|
| `backup-settings.sh` | Backup current macOS settings |
| `restore-settings.sh` | Restore settings from backup |
| `export-settings.sh` | Export settings in readable format |
| `helpers.sh` | Shared utility functions |

### Configuration Modules

| Module | Description |
|--------|-------------|
| `base.sh` | Core OS settings (Finder, Dock, keyboard, etc.) |
| `developer.sh` | Developer tools and workflows |
| `personal.sh` | Personal preferences (**customize this!**) |
| `apps.sh` | Third-party application settings |

## Usage

Don't run these scripts directly. Use the main orchestrator:

```bash
# From the dotfiles root directory
./scripts/macos-setup.sh --help
```

## Quick Start

```bash
# Interactive mode
cd ~/dotfiles
./scripts/macos-setup.sh

# Apply all settings
./scripts/macos-setup.sh --all

# Apply specific categories
./scripts/macos-setup.sh --base --dev
```

## Customization

Edit `personal.sh` to add your own preferences:

- Timezone
- Computer name
- Dark/light mode
- Hot corners
- Menu bar settings
- And more...

## Safety Features

- Automatic backups before changes
- Restore capability
- Graceful error handling
- Clear logging output

## Documentation

See [docs/macos-configuration.md](../../docs/macos-configuration.md) for complete documentation.

## File Descriptions

### backup-settings.sh
Creates a complete backup of your current macOS settings including:
- User defaults for all domains
- System-level settings
- NVRAM configuration
- Power management settings

Backups are stored in `~/.macos-backups/`

### restore-settings.sh
Restores macOS settings from a previous backup. Includes safeguards and confirmation prompts.

### export-settings.sh
Exports your current settings to a human-readable text file for documentation or comparison.

### helpers.sh
Shared functions used by all scripts:
- Logging functions (log_info, log_success, etc.)
- Safe defaults operations
- Version checking
- Sudo management

### base.sh
Core macOS settings that improve the default experience:
- Faster animations
- Better Finder defaults
- Optimized Dock
- Improved keyboard/trackpad
- Enhanced screenshot handling

### developer.sh
Developer-focused settings:
- Safari/browser dev tools
- Debug menus enabled
- Git configuration
- Homebrew setup
- Better defaults for development

### personal.sh
User-specific preferences - **This is where you customize**:
- Regional settings (timezone, units)
- Appearance (dark mode, colors)
- Computer identification
- Hot corners
- Security settings

### apps.sh
Third-party application configuration:
- Only configures installed apps
- Smart detection
- Sensible defaults for common apps

## Best Practices

1. **Always backup first** - The main script does this automatically
2. **Customize personal.sh** - Don't modify base.sh or developer.sh directly
3. **Test incrementally** - Try base settings first
4. **Document your setup** - Use the export feature
5. **Keep in version control** - Track your customizations

## Examples

```bash
# Create a backup before upgrading macOS
./scripts/macos-setup.sh --backup before-macos-15

# Export current settings for documentation
./scripts/macos-setup.sh --export current-setup.txt

# Apply only base settings
./scripts/macos-setup.sh --base

# Apply everything
./scripts/macos-setup.sh --all

# Restore from backup
./scripts/macos-setup.sh --restore before-macos-15
```

## Troubleshooting

**Settings not applied?**
- Log out and log back in
- Some settings require a restart

**Want to revert?**
```bash
./scripts/macos-setup.sh --restore <backup-name>
```

**Need to see what changed?**
```bash
# Export before and after, then compare
./scripts/macos-setup.sh --export before.txt
# ... apply settings ...
./scripts/macos-setup.sh --export after.txt
diff before.txt after.txt
```

## Script Output

All scripts use colored output for clarity:
- 🔵 Blue = Info
- ✅ Green = Success
- ⚠️ Yellow = Warning
- ❌ Red = Error
- ⊘ Cyan = Skipped

## Dependencies

- macOS 11 (Big Sur) or later recommended
- Bash 3.2+
- Standard macOS utilities (defaults, sudo, etc.)

## Safety

All scripts include:
- Error checking
- Sudo management
- Graceful failure handling
- Clear feedback
- Restoration capability

---

For complete documentation, see: [docs/macos-configuration.md](../../docs/macos-configuration.md)
