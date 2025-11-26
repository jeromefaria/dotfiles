# Package Management

A profile-based package management system for macOS using categorized Brewfiles.

## Overview

This system organizes packages into logical categories, allowing you to install only what you need for different types of systems. Instead of installing 200+ packages on every machine, you can select specific profiles or categories.

## Structure

```
packages/
├── Brewfile.base           # Essential tools (git, zsh, core utilities)
├── Brewfile.dev            # Software development
├── Brewfile.music          # Music production & audio
├── Brewfile.browsers       # Web browsers for testing
├── Brewfile.security       # Security & network tools
├── Brewfile.communication  # Chat, email, video conferencing
├── Brewfile.productivity   # Personal productivity apps
├── Brewfile.media          # Media tools & players
├── Brewfile.utilities      # System utilities
├── profiles/               # Predefined combinations
│   ├── minimal.txt         # Just essentials
│   ├── dev.txt            # Development machine
│   ├── music.txt          # Music production
│   ├── full.txt           # Everything
│   └── custom-example.txt # Create your own!
├── install-packages.sh     # Install packages
└── sync-packages.sh        # Sync installed packages
```

## Quick Start

### New Machine Setup

```bash
# Install the dev profile (base + dev + browsers + utilities)
./packages/install-packages.sh --profile dev

# Or install specific categories
./packages/install-packages.sh --categories base,dev,browsers

# See what would be installed first (dry run)
./packages/install-packages.sh --profile dev --dry-run
```

### List Available Options

```bash
./packages/install-packages.sh --list
```

## Categories

### base
Essential tools for any macOS system:
- Version control: git, gh
- Shell: zsh, bash-completion
- Core utilities: coreutils, curl, wget, tree
- Modern CLI tools: bat, eza, fd, ripgrep, fzf, zoxide, atuin, duf
- Compression: sevenzip, unar
- GNU utilities: gnu-sed, gnu-getopt

### dev
Software development environment:
- Languages: Python 3.11/3.12, Ruby, Node, Go, Rust, PHP, Erlang, Deno
- Version managers: fnm, nvm, rbenv
- Package managers: pnpm, npm, yarn, pipx
- Editors: Neovim, Vim, Emacs, VS Code, Cursor, Zed, Claude Code, Ghostty
- File managers: Yazi, Ranger, Vifm
- Tools: Docker, tmux, httpie, jq, lazygit
- Databases: MySQL, Cassandra

### music
Music production and audio tools:
- DAWs: Ableton Live, Cycling74 Max, Audacity, MuseScore
- Audio routing: BlackHole
- Music players: Spotify, Tidal, musikcube, mpd, cmus
- Plugin managers: Native Access, Arturia, iZotope, Spitfire, Soundtoys
- Music libraries: Beets, MusicBrainz Picard, cuetools, shntool
- P2P: Nicotine Plus

### browsers
Web browsers for testing and development:
- Modern: Arc, SigmaOS
- Chrome, Firefox, Safari, Edge, Opera
- Developer editions and technology previews
- Privacy browsers: DuckDuckGo, Tor

### security
Security and network analysis:
- VPN: NordVPN
- Tools: nmap, aircrack-ng, tor, adns
- Password management: pass, 1Password

### communication
Messaging and collaboration:
- Team: Slack, Discord, Zoom, Microsoft Teams, Beeper
- Personal: Signal, WhatsApp, Telegram
- AI: ChatGPT, Perplexity
- Email: mutt, neomutt, notmuch

### productivity
Personal productivity applications:
- Task management: Things, Fantastical
- Notes: Craft, Obsidian, Raindrop.io, TagSpaces, iA Writer
- Cloud storage: Dropbox, Google Drive
- Writing: Grammarly Desktop
- Tools: RAR, Marta, Numi
- iWork suite: Keynote, Numbers, Pages

### media
Media tools and players:
- Players: IINA, VLC, Plex Media Server
- Processing: ffmpeg, ffmpeg@4, handbrake, imagemagick
- Recording: OBS Studio
- Creative: Blender, TouchDesigner
- Photo: Adobe DNG Converter, Darkroom, Pixelmator Pro
- Utilities: jDownloader, Raspberry Pi Imager, Wacom, DisplayLink
- Gaming: Steam, PS Remote Play
- Editors: GIMP

### utilities
macOS system utilities:
- Window management: Aerospace, Rectangle Pro, KindaVim, SKHD, Alt-Tab
- Input: Karabiner Elements
- System tools: htop, Bartender, cleanmymac, macos-term-size

## Profiles

Profiles are predefined combinations of categories:

### minimal
Just the essentials - core tools only

### dev
For software development:
- base + dev + browsers + utilities
- Perfect for a development-focused machine

### music
For music production:
- base + music + media + utilities

### full
Everything - complete system setup

### Custom Profiles

Create your own profile by adding a text file to `profiles/`:

```bash
# profiles/my-profile.txt
base
dev
communication
productivity
```

Then install it:

```bash
./packages/install-packages.sh --profile my-profile
```

## Workflow

### Initial Setup

1. On a new machine, choose a profile or categories:
   ```bash
   ./packages/install-packages.sh --profile dev
   ```

2. Wait for installation to complete

### Adding New Software

1. Install software normally:
   ```bash
   brew install new-tool
   # or
   brew install --cask new-app
   ```

2. Sync to see what's new:
   ```bash
   ./packages/sync-packages.sh
   ```

3. The script will show new packages not in any category

4. Manually add them to the appropriate `Brewfile.<category>`

5. Commit the changes:
   ```bash
   git add packages/
   git commit -m "Add new-tool to dev category"
   ```

### Keeping in Sync

Run sync periodically to check for changes:
```bash
./packages/sync-packages.sh
```

This shows:
- New packages you've installed
- Packages in Brewfiles but not installed
- Summary of what's out of sync

### Updating Packages

```bash
# Update Homebrew and upgrade all packages
brew update && brew upgrade

# Then sync to check if any were added/removed
./packages/sync-packages.sh
```

## Advanced Usage

### Installing Multiple Categories

```bash
./packages/install-packages.sh --categories base,dev,security,communication
```

### Dry Run Mode

See what would be installed without installing:
```bash
./packages/install-packages.sh --profile full --dry-run
```

### Cleanup Unused Packages

Remove packages not in your Brewfiles:
```bash
# For a specific category
brew bundle cleanup --file=packages/Brewfile.dev

# Force cleanup without confirmation
brew bundle cleanup --file=packages/Brewfile.dev --force
```

### Language-Specific Packages

For language-specific dependencies, use their native tools:

**Node/npm:**
```bash
# Project dependencies (tracked in package.json)
npm install

# Global tools (minimal, only CLI tools)
npm install -g <package>
```

**Python/pip:**
```bash
# Use virtual environments
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Or use pipenv/poetry
pipenv install
```

**Ruby/gem:**
```bash
# Use Bundler
bundle install
```

## Migration from Old System

The old system used:
- Single monolithic `Brewfile`
- Log files (`.log`) for tracking
- `get-packages.sh` for exporting

The new system:
- Uses categorized Brewfiles
- No log files needed
- Smart sync script shows diffs
- Profile support for different machines

Old files have been removed:
- `brew.log`, `cask.log`, `mas.log`, `npm.log`, `pip.log`, `gem.log`
- `get-packages.sh`
- Original monolithic `Brewfile`

## Tips

1. **Start minimal**: Install only what you need, add more later

2. **Use profiles**: They're faster than picking categories manually

3. **Keep categories clean**: When adding packages, think about which category makes sense

4. **Review before committing**: Check diffs to understand what changed

5. **Document custom profiles**: Add comments explaining your choices

6. **Platform-specific**: This system is macOS-specific (Homebrew)

## Troubleshooting

### Brew bundle fails

```bash
# Update Homebrew first
brew update

# Try again
./packages/install-packages.sh --profile dev
```

### Package conflicts

Some packages may conflict or have linking issues. Check the error message and:
```bash
# Unlink conflicting package
brew unlink <package>

# Install again
brew link <package>
```

### Can't find a category

```bash
# List all available categories
./packages/install-packages.sh --list
```

### Sync shows packages I removed

If you intentionally removed packages, update the Brewfiles:
```bash
# Remove the line from the appropriate Brewfile.* file
vim packages/Brewfile.<category>
```

## Contributing

When adding new packages:

1. Install the package normally with brew
2. Run `sync-packages.sh` to find it
3. Add it to the appropriate category Brewfile
4. Add a comment if the purpose isn't obvious
5. Commit with a clear message

## Resources

- [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle)
- [Homebrew Documentation](https://docs.brew.sh)
- [Brewfile Syntax](https://github.com/Homebrew/homebrew-bundle#usage)
