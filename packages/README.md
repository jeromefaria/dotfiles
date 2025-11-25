# Packages Directory

This directory contains package management files and tools for tracking and reproducing your development environment.

## Files

### Brewfile
The `Brewfile` is a declarative package list for [Homebrew](https://brew.sh/), macOS's package manager. It includes:
- Homebrew packages (CLI tools)
- Cask applications (GUI apps)
- Mac App Store applications (via `mas`)
- Homebrew taps (third-party repositories)

**Install all packages from Brewfile:**
```bash
brew bundle install --file=packages/Brewfile
```

**Update Brewfile with currently installed packages:**
```bash
brew bundle dump --file=packages/Brewfile --force
```

### get-packages.sh
An automated script that exports currently installed packages from various package managers to log files.

**Exports to:**
- `brew.log` - Homebrew CLI packages
- `cask.log` - Homebrew Cask GUI applications
- `gem.log` - Ruby gems
- `mas.log` - Mac App Store applications
- `npm.log` - Global npm packages
- `pip.log` - Python pip packages

**Usage:**
```bash
./packages/get-packages.sh
```

This script validates that each package manager is installed before attempting to export, ensuring it runs safely on any system.

### Package Log Files (*.log)
Timestamped snapshots of installed packages from different package managers. These files serve as:
- Backup documentation of your environment
- Reference for manual package installation
- Comparison point for tracking changes over time

**Note:** These log files are tracked in git to maintain a history of your package environment. The Brewfile is the preferred method for reproducible installations, but the logs provide additional detail for other package managers.

## Workflow

1. **Initial Setup** - Use the Brewfile to install packages:
   ```bash
   brew bundle install --file=packages/Brewfile
   ```

2. **Add New Packages** - After installing new software:
   ```bash
   # Update the Brewfile
   brew bundle dump --file=packages/Brewfile --force

   # Update all package logs
   ./packages/get-packages.sh

   # Commit the changes
   git add packages/
   git commit -m "Update package lists"
   ```

3. **Sync to New Machine** - Clone the dotfiles repo and run:
   ```bash
   ./install.sh
   # When prompted, choose to install packages from Brewfile
   ```

## Package Managers Supported

- **Homebrew** (`brew`) - macOS package manager
- **Homebrew Cask** (`cask`) - macOS applications
- **Mac App Store** (`mas`) - macOS App Store apps
- **Ruby Gems** (`gem`) - Ruby packages
- **npm** - Node.js packages (global)
- **pip** - Python packages

## Tips

- Keep the Brewfile as your source of truth for reproducible environments
- Run `get-packages.sh` periodically to keep logs up to date
- Review changes to the Brewfile before committing to understand what was added/removed
- The `.log` files are useful for tracking what's installed but aren't executable - use the Brewfile for installations
