# Config Directory

This directory contains XDG-compliant application configurations. These files are designed to be symlinked or copied to `~/.config/` for use by various applications.

## Structure

Each subdirectory represents a different application or tool:

- **aria2/** - Aria2 download manager configuration
- **bat/** - Bat (cat replacement) syntax highlighting theme
- **beets/** - Beets music library manager configuration
- **gh/** - GitHub CLI configuration
- **musikcube/** - Musikcube terminal music player settings
- **ncmpcpp/** - NCurses Music Player Client (Plus Plus) configuration
- **neofetch/** - Neofetch system information tool config
- **nvim/** - Neovim editor configuration (symlinks to ../neovim/)
- **ranger/** - Ranger file manager configuration
- **skhd/** - Simple Hotkey Daemon for macOS window management
- **starship.toml** - Starship cross-shell prompt configuration
- **tmuxinator/** - Tmuxinator session management templates
- **yabai/** - Yabai tiling window manager for macOS
- **yarn/** - Yarn package manager global configuration

## Installation

The main `install.sh` script in the repository root handles symlinking these configurations to the appropriate locations in your home directory.

## XDG Base Directory Specification

This directory follows the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html), which standardizes configuration file locations across Unix-like systems.

Most modern applications respect the `$XDG_CONFIG_HOME` environment variable (defaults to `~/.config/`), making configuration management cleaner and more organized.

## Note on Sensitive Files

Several sensitive files are excluded from version control via `.gitignore`:
- Credentials and tokens
- Session data and history
- Cache files
- Application databases

If a tool requires sensitive configuration, you'll find a `.template` file or documentation in the tool's subdirectory.
