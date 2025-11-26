# Shell Quick Reference

## Most Useful Aliases

### Navigation
```bash
..          # cd ..
...         # cd ../..
cd <query>  # Smart directory jump with zoxide (alias for 'z')
zi          # Interactive directory picker
-           # cd to previous directory
```

### File Listing
```bash
ls          # eza (modern ls)
ll          # eza -lh --git (long format with git status)
la          # eza -lah --git (all files with git status)
lt          # eza -lahs=date --git (sorted by date)
lls         # eza -ls=size --git (sorted by size)
```

### File Operations
```bash
cat <file>  # bat (syntax highlighting)
find <name> # fd (faster find)
trash <file> # Safe delete to trash
o <file>    # open (macOS open command)
```

### Clipboard
```bash
pbc         # pbcopy
pbp         # pbpaste
copy        # Remove newlines and copy
cdir        # Copy current directory path
```

### Git
```bash
gcan        # git commit --amend --no-edit
gds         # git diff --staged
gcob        # git checkout branch (with fzf picker)
gdc         # Show conflicted files
```

### Docker
```bash
dcu         # docker compose up
dcud        # docker compose up -d
dcd         # docker compose down
dcs         # docker compose stop
dcb         # docker compose build
```

### Tmux
```bash
tmx <name>  # tmux new session
tmxa        # tmux attach
tmxl        # tmux list sessions
mux         # tmuxinator
```

### Development
```bash
vim         # nvim
top         # htop
reload      # Reload shell
```

## Most Useful Functions

### File & Directory Operations
```bash
mkd <dir>           # Create directory and cd into it
fs [path]           # Show file/directory size
enc <file>          # Base64 encode file → clipboard
dec <file>          # Base64 decode clipboard → file
dataurl <file>      # Create data URL from file
rl <file> <line>    # Read specific line from file
sync <src> <dst>    # rsync and remove source
```

### Development
```bash
server [port]       # Start HTTP server (default: 8000)
phpserver [port]    # Start PHP server (default: 4000)
links <url>         # Extract all href links from webpage
```

### Git Utilities
```bash
gdb                 # Delete local branches removed from remote
ggd                 # Get date of latest commit
oj                  # Open Jira ticket for current branch
```

### Media Conversion
```bash
flac2mp3           # Convert all FLAC files to MP3
flac2alac          # Convert all FLAC files to ALAC
```

### macOS Utilities
```bash
cdf                # cd to frontmost Finder window
resetfontcache     # Reset font cache (fixes Chrome issues)
periodic           # Run system maintenance scripts
digga <domain>     # Better dig output
tre [path]         # Tree with sensible defaults
clearFinderHistory # Clear Finder Go To history
restartTouchBar    # Restart MacBook Touch Bar
```

### System Info
```bash
ip                 # Get external IP
localip            # Get local network IP
ips                # List all IPs
ifactive           # Show active network interfaces
```

### Maintenance
```bash
cleanup            # Remove .DS_Store files recursively
flush              # Flush DNS cache
update             # Update all: Homebrew, npm, gems, tldr
emptytrash         # Empty all trash + system logs
```

## Quick Tips

### zoxide (Smart cd)
```bash
# After using directories a few times, zoxide learns them
cd ~/Work/project/deep/nested/folder

# Later, just type:
z folder           # Jumps directly there

# Multiple matches? Use interactive:
zi                 # Shows picker with fzf
```

### FZF Integration
```bash
gcob               # Git checkout with interactive branch picker
preview            # Preview files with syntax highlighting
```

### Directory Shortcuts
```bash
dotfiles           # cd to dotfiles
work               # cd to work directory
docs               # cd to Documents
down               # cd to Downloads
desk               # cd to Desktop
```

### Chrome Development
```bash
chrome             # Open Chrome executable
chromekill         # Kill Chrome tabs to free memory
chromedev          # Chrome with dev flags
cdv                # Chrome Canary dev mode
```

### Encoding
```bash
rot13              # ROT13 encoding
rot5               # ROT5 encoding (numbers)
rotten             # ROT13 + ROT5 combined
urlencode          # URL encode string
json               # Pretty print JSON
```

## Function Usage Examples

### Create and Enter Directory
```bash
mkd ~/Work/new-project
```

### Encode File to Clipboard
```bash
enc ~/Documents/secret.txt
# Paste anywhere with Cmd+V
```

### Decode Clipboard to File
```bash
# Copy base64 string first
dec ~/Documents/decoded.txt
```

### Start Local Web Server
```bash
cd ~/my-website
server 3000
# Opens http://localhost:3000
```

### Extract Links from Webpage
```bash
links https://example.com > links.txt
```

### Convert Audio Files
```bash
cd ~/Music/album
flac2mp3
# Converts all .flac files to .mp3
```

### Clean Up Git Branches
```bash
gdb
# Removes local branches that were deleted from remote
```

## Category Files

- **aliases/core.sh** - Basic system aliases
- **aliases/tools.sh** - Modern CLI tool replacements
- **aliases/folders.sh** - Directory shortcuts
- **aliases/git.sh** - Git commands
- **aliases/dev.sh** - Development tools
- **aliases/macos.sh** - macOS-specific commands
- **aliases/chrome.sh** - Chrome development
- **functions/core.sh** - Essential utilities
- **functions/dev.sh** - Development functions
- **functions/media.sh** - Media conversion
- **functions/macos.sh** - macOS utilities

## Disabling Categories

Temporarily disable a category:
```bash
mv ~/dotfiles/shell/aliases/chrome.sh ~/dotfiles/shell/aliases/chrome.sh.disabled
reload
```

Re-enable:
```bash
mv ~/dotfiles/shell/aliases/chrome.sh.disabled ~/dotfiles/shell/aliases/chrome.sh
reload
```
