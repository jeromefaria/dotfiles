# Beets Music Library Manager Configuration

Comprehensive music library organization and metadata management using [Beets](https://beets.io/).

## Overview

Beets is a command-line music library manager that:
- Automatically tags and organizes music files
- Fetches metadata from MusicBrainz and Discogs
- Downloads album artwork
- Manages duplicate detection
- Supports multiple library configurations (FLAC and MP3)

**Configuration Files:**
- `config.yaml` - FLAC library (primary, lossless)
- `config-mp3.yaml` - MP3 library (lossy, portable)

---

## Table of Contents

- [Installation](#installation)
- [Configuration Files](#configuration-files)
- [Library Setup](#library-setup)
- [Import Settings](#import-settings)
- [Path Formats](#path-formats)
- [Plugins](#plugins)
- [Matching & Metadata](#matching--metadata)
- [Common Commands](#common-commands)
- [Troubleshooting](#troubleshooting)

---

## Installation

### Prerequisites

```bash
# Install beets
brew install beets

# Optional: Install additional dependencies for plugins
brew install chromaprint  # For acoustid fingerprinting
pip3 install pylast       # For lastgenre plugin
pip3 install discogs-client  # For discogs plugin
```

### Configuration

The configuration is symlinked automatically:

```bash
# Via dotfiles installation
cd ~/dotfiles
./scripts/install.sh

# Manual symlink
ln -s ~/dotfiles/config/beets ~/.config/beets
```

### Discogs Authentication (Optional)

For Discogs plugin functionality:

1. Get a Discogs token from https://www.discogs.com/settings/developers
2. Copy the template:
   ```bash
   cp ~/.config/beets/discogs_token.json.template ~/.config/beets/discogs_token.json
   ```
3. Add your token to `discogs_token.json`

---

## Configuration Files

### config.yaml (FLAC Library)

**Purpose:** Primary library for lossless FLAC files

**Location:**
- Database: `/Volumes/Media/Music/FLAC.db`
- Music files: `/Volumes/Media/Music/FLAC/`

**Key Differences from MP3 config:**
- Stores lossless FLAC files
- Larger storage requirements
- Used for archival and high-quality playback

### config-mp3.yaml (MP3 Library)

**Purpose:** Secondary library for lossy MP3 files

**Location:**
- Database: `/Users/jeromefaria/Documents/Beets/MP3.db`
- Music files: `/Volumes/Music/Music/MP3/`

**Key Differences from FLAC config:**
- Stores lossy MP3 files
- Smaller storage requirements
- Used for portable devices and streaming

**Usage:**
```bash
# Use MP3 configuration
beet -c ~/.config/beets/config-mp3.yaml import /path/to/music
```

---

## Library Setup

### Library Location

```yaml
library: /Volumes/Media/Music/FLAC.db  # SQLite database
directory: /Volumes/Media/Music/FLAC   # Music files directory
```

The `library` is the SQLite database storing metadata. The `directory` is where music files are stored.

### Machine-Specific Paths

If using external drives with different mount points, update these paths:

```bash
# Edit config for your system
nvim ~/.config/beets/config.yaml
```

---

## Import Settings

### Import Behavior

```yaml
import:
  write: yes          # Write tags to files
  copy: yes           # Copy files to library (vs. move)
  move: no            # Don't move original files
  link: no            # Don't create symlinks
  hardlink: no        # Don't create hardlinks
  reflink: no         # Don't use copy-on-write
  delete: no          # Keep original files after import
  resume: ask         # Ask before resuming interrupted import
  incremental: yes    # Skip already-imported directories
  autotag: yes        # Enable automatic tagging
  quiet: no           # Show detailed output
  default_action: apply  # Default: accept match and import
  duplicate_action: ask  # Ask when duplicate found
```

### Key Options Explained

| Option | Value | Explanation |
|--------|-------|-------------|
| `write: yes` | Write tags | Save metadata to file tags |
| `copy: yes` | Copy files | Keep originals, copy to library |
| `incremental: yes` | Skip imported | Don't re-import existing albums |
| `autotag: yes` | Auto-tag | Search MusicBrainz for metadata |
| `default_action: apply` | Auto-apply | Accept best match automatically |

### Import Actions

During import, you can choose:
- `a` - Apply (accept match)
- `s` - Skip (don't import)
- `u` - Use as-is (import without tagging)
- `t` - Enter tags manually
- `e` - Edit candidates
- `m` - Enter MusicBrainz ID manually

---

## Path Formats

### Directory Structure

```yaml
paths:
  default: $albumartist - $album%aunique{}/$track $title
  singleton: Non-Album/$artist/$title
  comp: Compilations/$album%aunique{}/$track $title
```

### Path Templates Explained

**Default Albums:**
```
Artist - Album [Disambiguation]/01 Track Title.flac
```

Example: `Pink Floyd - The Dark Side of the Moon/01 Speak to Me.flac`

**Singleton Tracks:**
```
Non-Album/Artist/Track Title.flac
```

Example: `Non-Album/Radiohead/Spectre.flac`

**Compilations:**
```
Compilations/Album [Disambiguation]/01 Track Title.flac
```

Example: `Compilations/Now That's What I Call Music 50/01 Hit Song.flac`

### Available Path Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `$albumartist` | Album artist | `Pink Floyd` |
| `$artist` | Track artist | `David Gilmour` |
| `$album` | Album title | `The Dark Side of the Moon` |
| `$title` | Track title | `Time` |
| `$track` | Track number | `01` |
| `$year` | Release year | `1973` |
| `$genre` | Genre | `Progressive Rock` |
| `$label` | Record label | `Harvest Records` |
| `%aunique{}` | Disambiguation | `[2011 Remaster]` |

### Filename Sanitization

```yaml
replace:
  '[\\/]': _           # Replace slashes with underscores
  ^\.: _               # Replace leading dots
  '[\x00-\x1f]': _     # Replace control characters
  '[<>:"\?\*\|]': _    # Replace invalid filename chars
  \.$: _               # Replace trailing dots
  \s+$: ''             # Remove trailing whitespace
  ^\s+: ''             # Remove leading whitespace
  ^-: _                # Replace leading hyphens
```

These rules prevent filesystem issues and ensure cross-platform compatibility.

---

## Plugins

### Enabled Plugins

```yaml
plugins: discogs lastgenre fetchart embedart lyrics albumtypes mbsync
```

| Plugin | Purpose | Configuration |
|--------|---------|---------------|
| **discogs** | Fetch metadata from Discogs | Requires auth token |
| **lastgenre** | Genre tagging via Last.fm | Automatic |
| **fetchart** | Download album artwork | Automatic |
| **embedart** | Embed artwork in files | Automatic |
| **lyrics** | Fetch song lyrics | Automatic |
| **albumtypes** | Album type classification | See below |
| **mbsync** | Sync with MusicBrainz | Manual command |

### Plugin: discogs

Fetches metadata from Discogs when MusicBrainz doesn't have results.

**Setup:**
```bash
# Get token: https://www.discogs.com/settings/developers
echo '{"user_token": "YOUR_TOKEN_HERE"}' > ~/.config/beets/discogs_token.json
```

**Usage:**
```bash
# Import will automatically try Discogs if MusicBrainz fails
beet import /path/to/music
```

### Plugin: lastgenre

Automatically tags genre information from Last.fm.

**No configuration needed** - works automatically during import.

### Plugin: fetchart & embedart

**fetchart** downloads album artwork from various sources.
**embedart** embeds the artwork directly into music files.

```yaml
art_filename: cover  # Save artwork as "cover.jpg"
```

**Manual commands:**
```bash
# Fetch missing artwork
beet fetchart

# Fetch for specific album
beet fetchart artist:radiohead album:ok_computer

# Embed artwork in files
beet embedart
```

### Plugin: lyrics

Fetches lyrics from LyricWiki and other sources.

**Commands:**
```bash
# Fetch lyrics for all tracks
beet lyrics

# Fetch for specific artist
beet lyrics artist:radiohead

# Show lyrics
beet lyrics -p artist:radiohead title:creep
```

### Plugin: albumtypes

Adds album type to album disambiguation.

```yaml
albumtypes:
  types:
    - ep: 'EP'              # Extended Play
    - single: 'Single'      # Single releases
    - soundtrack: 'OST'     # Original Soundtrack
    - live: 'Live'          # Live recordings
    - compilation: 'Anthology'  # Compilations
    - remix: 'Remix'        # Remix albums
  ignore_va: compilation    # Don't add type for VA compilations
  bracket: '[]'             # Use square brackets
```

**Result:** Albums named like `Artist - Album [EP]` or `Artist - Album [Live]`

### Plugin: mbsync

Syncs library with MusicBrainz to update metadata.

**Usage:**
```bash
# Update all albums
beet mbsync

# Update specific album
beet mbsync artist:radiohead album:ok_computer
```

---

## Matching & Metadata

### Match Quality Thresholds

```yaml
match:
  strong_rec_thresh: 0.04    # Confident match threshold
  medium_rec_thresh: 0.25    # Medium confidence threshold
  rec_gap_thresh: 0.25       # Gap between 1st and 2nd match
```

**Lower values = stricter matching**

- **Strong match** (< 0.04): Automatically applied with confidence
- **Medium match** (0.04-0.25): Requires user confirmation
- **Weak match** (> 0.25): Likely incorrect, skip or manual entry

### Distance Weights

These control how much each attribute affects match scoring:

```yaml
distance_weights:
  source: 2.0              # Source preference
  artist: 3.0              # Artist name (high importance)
  album: 3.0               # Album name (high importance)
  media: 1.0               # Media type (CD, vinyl, etc.)
  year: 1.0                # Release year
  country: 0.5             # Release country
  label: 0.5               # Record label
  album_id: 5.0            # MusicBrainz album ID (very high)
  tracks: 2.0              # Track list matching
  missing_tracks: 0.9      # Penalty for missing tracks
  unmatched_tracks: 0.6    # Penalty for extra tracks
  track_title: 3.0         # Track title (high importance)
  track_artist: 2.0        # Track artist
  track_length: 2.0        # Track duration
  track_id: 5.0            # MusicBrainz track ID (very high)
```

**Higher values = more important** for matching.

### MusicBrainz Settings

```yaml
musicbrainz:
  host: musicbrainz.org
  https: no                 # Use HTTP (faster)
  ratelimit: 1              # Max 1 request per second
  ratelimit_interval: 1.0   # 1 second between requests
  searchlimit: 5            # Return top 5 matches
```

### Track Length Tolerance

```yaml
match:
  track_length_grace: 10    # Allow ±10 seconds difference
  track_length_max: 30      # Max 30 seconds difference for strong match
```

---

## Common Commands

### Import Music

```bash
# Import directory
beet import /path/to/music

# Import and copy files
beet import -c /path/to/music

# Import without auto-tagging
beet import --noautotag /path/to/music

# Import as singletons (no album grouping)
beet import -s /path/to/music

# Resume interrupted import
beet import -p /path/to/music

# Use MP3 configuration
beet -c ~/.config/beets/config-mp3.yaml import /path/to/music
```

### Query Library

```bash
# List all albums
beet ls -a

# List all tracks
beet ls

# Search by artist
beet ls artist:radiohead

# Search by album
beet ls album:"ok computer"

# Search by year
beet ls year:1997

# Search by genre
beet ls genre:rock

# Complex query
beet ls artist:radiohead year:1990..2000
```

### Modify Metadata

```bash
# Edit album metadata
beet modify -a artist:radiohead album:pablo genre="Alternative Rock"

# Edit track metadata
beet modify artist:radiohead title:creep year=1992

# Interactive editing
beet modify -a artist:radiohead

# Write changes to files
beet write
```

### Update Library

```bash
# Re-tag albums
beet import -L /path/to/library

# Update from MusicBrainz
beet mbsync

# Fetch missing artwork
beet fetchart

# Embed artwork
beet embedart

# Fetch lyrics
beet lyrics
```

### Maintenance

```bash
# Check library consistency
beet stats

# List duplicate tracks
beet dup

# Remove missing files from database
beet update -M

# Move files to match path format
beet move

# Show configuration
beet config

# Validate configuration
beet config -e
```

---

## File Organization

### Clutter Files

Files that will be ignored/deleted:

```yaml
clutter: [Thumbs.DB, .DS_Store]
```

### Ignore Patterns

Directories/files to skip during import:

```yaml
ignore:
  - .*                        # Hidden files
  - '*~'                      # Backup files
  - System Volume Information # Windows system
  - lost+found                # Linux system
ignore_hidden: yes            # Skip all hidden files
```

---

## UI & Display

### Output Formats

```yaml
format_item: $artist - $album - $title
format_album: $albumartist - $album
```

**Track display:** `Artist - Album - Title`
**Album display:** `Album Artist - Album`

### Sorting

```yaml
sort_album: albumartist+ album+     # Sort albums by artist, then title
sort_item: artist+ album+ disc+ track+  # Sort tracks by artist, album, disc, track
sort_case_insensitive: yes           # Ignore case when sorting
```

### Color Scheme

```yaml
ui:
  color: yes
  colors:
    text_success: green
    text_warning: yellow
    text_error: red
    text_highlight: red
    text_highlight_minor: lightgray
    action_default: turquoise
    action: blue
```

---

## Workflows

### Importing a New Album

```bash
# 1. Import with auto-tagging
beet import ~/Downloads/new-album/

# 2. Beets will search MusicBrainz
# 3. Choose action:
#    - [A]pply: Accept match
#    - [S]kip: Don't import
#    - [U]se as-is: Import without tagging
#    - [E]dit: Modify metadata
#    - [M]anual: Enter MusicBrainz ID

# 4. Files are copied to library and organized
# 5. Artwork is downloaded and embedded
# 6. Lyrics are fetched (if available)
```

### Re-tagging Existing Music

```bash
# 1. Import existing library (dry-run first)
beet import -L /path/to/existing/library

# 2. Update metadata from MusicBrainz
beet mbsync

# 3. Fetch missing artwork
beet fetchart

# 4. Embed artwork
beet embedart

# 5. Reorganize files to match path format
beet move
```

### Converting Between Libraries

```bash
# Convert FLAC to MP3 (requires convert plugin)
# 1. Export from FLAC library
beet ls -a -f '$path' > albums.txt

# 2. Use external tool for conversion
# 3. Import to MP3 library
beet -c ~/.config/beets/config-mp3.yaml import /path/to/mp3s
```

---

## Troubleshooting

### Import Issues

**Problem:** "No matching release found"

**Solutions:**
```bash
# Try manual MusicBrainz ID
beet import -s /path  # Import as singletons
beet import --noautotag /path  # Import without tagging
```

**Problem:** "Files not being copied"

**Solution:** Check `import.copy: yes` in config

### Database Issues

**Problem:** "Database is locked"

**Solution:**
```bash
# Close all beets processes
killall beet

# If still locked, remove lock file
rm /path/to/library.db.lock
```

**Problem:** "Missing files in database"

**Solution:**
```bash
# Update database to remove missing files
beet update -M

# Verify
beet stats
```

### Path Issues

**Problem:** "Invalid characters in filenames"

**Solution:** The `replace` configuration handles this automatically. If issues persist:

```bash
# Move files to fix paths
beet move

# Check for problematic characters
beet ls -f '$path' | grep -E '[<>:"\?\*\|]'
```

### Plugin Issues

**Problem:** Discogs plugin not working

**Solution:**
```bash
# Check token file
cat ~/.config/beets/discogs_token.json

# Test token at https://www.discogs.com/settings/developers
```

**Problem:** Artwork not downloading

**Solution:**
```bash
# Force re-fetch
beet fetchart -f

# Check for specific album
beet fetchart -f artist:radiohead album:"ok computer"
```

### Performance

**Problem:** Slow imports

**Solutions:**
```bash
# Use threading (already enabled)
threaded: yes

# Reduce search results
musicbrainz:
  searchlimit: 3  # Reduce from 5 to 3

# Import in batches
beet import /path/album1
beet import /path/album2
```

---

## Advanced Configuration

### Album Uniqueness

```yaml
aunique:
  keys: albumartist album           # Group by artist and album
  disambiguators: albumtype year label catalognum  # Add these if needed
  bracket: '[]'                     # Use square brackets
```

**Result:** `Artist - Album [EP] [1997]` when disambiguation needed.

### State Management

```yaml
statefile: state.pickle  # Stores import progress
```

Allows resuming interrupted imports with `beet import -p`.

### Performance Tuning

```yaml
threaded: yes      # Use multiple threads
timeout: 5.0       # Network timeout (seconds)
verbose: 0         # Verbosity level (0-2)
```

---

## Quick Reference

### Essential Commands

```bash
beet import /path          # Import music
beet ls artist:X           # Search library
beet modify -a X           # Edit metadata
beet move                  # Organize files
beet update                # Update library
beet stats                 # Show statistics
```

### Query Syntax

```bash
artist:X                   # Match artist
album:X                    # Match album
title:X                    # Match title
year:2000                  # Exact year
year:1990..2000           # Year range
genre:rock                # Match genre
albumartist:X             # Match album artist
^X                        # Starts with X
X$                        # Ends with X
```

### Common Flags

```bash
-a                # Apply to albums (not tracks)
-f FORMAT         # Custom output format
-p                # Display paths
-c CONFIG         # Use alternate config
```

---

## Related Documentation

- [Beets Official Docs](https://beets.readthedocs.io/)
- [MusicBrainz](https://musicbrainz.org/)
- [Discogs](https://www.discogs.com/)
- [Plugin Documentation](https://beets.readthedocs.io/en/stable/plugins/)

---

**Configuration Location:** `~/dotfiles/config/beets/`
**Symlinked To:** `~/.config/beets/`
**FLAC Library:** `/Volumes/Media/Music/FLAC.db`
**MP3 Library:** `/Users/jeromefaria/Documents/Beets/MP3.db`
