# Musikcube Configuration

Terminal-based music player with vim-style keybindings, Last.fm scrobbling, and streaming server capabilities.

## Overview

[musikcube](https://musikcube.com/) is a fully functional terminal-based music player, library, and streaming audio server written in C++. Features include:

- Vim-style navigation and keybindings
- Last.fm scrobbling integration
- Remote streaming server (HTTP/WebSocket)
- Crossfade and gapless playback
- 10-band equalizer
- macOS media keys support
- Library indexing with metadata parsing

**Configuration Files:**
- `settings.json` - Main configuration (theme, library, playback)
- `hotkeys.json` - Vim-style keybindings
- `plugins.json` - Enabled/disabled plugins
- `themes/oceanic-next.json` - OceanicNext color theme

---

## Table of Contents

- [Installation](#installation)
- [Keybindings](#keybindings)
- [Theme](#theme)
- [Plugins](#plugins)
- [Last.fm Scrobbling](#lastfm-scrobbling)
- [Remote Streaming](#remote-streaming)
- [Troubleshooting](#troubleshooting)

---

## Installation

### Prerequisites

```bash
# Install musikcube
brew install musikcube
```

### Configuration

Symlinked automatically via dotfiles:

```bash
# Via dotfiles installation
cd ~/dotfiles
./scripts/install.sh

# Manual symlink
ln -s ~/dotfiles/config/musikcube ~/.config/musikcube
```

### First Run

1. Launch: `musikcube`
2. Press `s` to open settings
3. Add your music library path
4. Press `R` to rescan/index library

---

## Keybindings

### Navigation (Vim-style)

| Key | Action | Description |
|-----|--------|-------------|
| `j` / `k` | Move down/up | Navigate lists |
| `h` / `l` | Left/Right | Move between panes |
| `J` / `K` | Page down/up | Fast navigation |
| `g` | Home | Jump to first item |
| `G` | End | Jump to last item |

### Views

| Key | Action | Description |
|-----|--------|-------------|
| `a` | Library | Main library view |
| `b` | Browse | Browse view |
| `n` | Now Playing | Play queue |
| `t` | Tracks | All tracks view |
| `1` | Artists | Browse by artist |
| `2` | Albums | Browse by album |
| `3` | Genres | Browse by genre |
| `4` | Album Artists | Browse by album artist |
| `5` | Playlists | View playlists |
| `6` | Categories | Choose category |
| `d` | Directories | Browse by folder |
| `s` | Settings | Open settings |
| `?` | Hotkeys | View/edit keybindings |

### Playback

| Key | Action | Description |
|-----|--------|-------------|
| `Space` / `Ctrl+P` | Play/Pause | Toggle playback |
| `H` | Previous | Previous track |
| `L` | Next | Next track |
| `u` | Seek back | Seek backward 10s |
| `o` | Seek forward | Seek forward 10s |
| `y` | Seek back (%) | Seek backward proportional |
| `p` | Seek forward (%) | Seek forward proportional |
| `Ctrl+X` | Stop | Stop playback |
| `m` | Mute | Toggle mute |
| `9` / `0` | Volume | Volume down/up |
| `.` | Repeat | Toggle repeat mode |
| `,` | Shuffle | Toggle shuffle |

### Queue Management

| Key | Action | Description |
|-----|--------|-------------|
| `x` | Jump to playing | Jump to currently playing |
| `X` | Clear queue | Clear play queue |
| `Backspace` | Delete | Remove from queue |
| `Ctrl+Up/Down` | Move | Reorder queue items |

### Search & Filter

| Key | Action | Description |
|-----|--------|-------------|
| `/` | Filter | Filter current list |
| `Ctrl+F` | Category filter | Filter by category |
| `Alt+M` | Match type | Toggle search match type |

### Playlists

| Key | Action | Description |
|-----|--------|-------------|
| `Alt+N` | New playlist | Create new playlist |
| `Alt+S` | Save playlist | Save current queue as playlist |
| `Alt+L` | Load playlist | Load playlist to queue |
| `Alt+R` | Rename | Rename playlist |
| `F2` | Rename | Rename playlist (alternate) |

### Other

| Key | Action | Description |
|-----|--------|-------------|
| `v` | Visualizer | Toggle visualizer |
| `Ctrl+E` | Equalizer | Open equalizer |
| `Ctrl+L` | Lyrics | Show lyrics |
| `r` | Rate track | Rate current track |
| `R` | Rescan | Rescan metadata |
| `S` | Sort | Change sort order |
| `+` | Context menu | Open context menu |
| `'` | Console | Open console |
| `F5` | Refresh | Refresh view |
| `q` | Quit | Exit musikcube |

### List Navigation

| Key | Action | Description |
|-----|--------|-------------|
| `[` / `]` | Group nav | Previous/next group |
| `Alt+P` | Play from top | Play queue from beginning |
| `Alt+A` | Hot swap | Hot swap queue |

---

## Theme

### OceanicNext

This configuration includes a custom **OceanicNext** theme matching the vim/tmux/yazi setup.

**Location:** `themes/oceanic-next.json`

### Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Background | `#1B2B34` | Main background |
| Foreground | `#D8DEE9` | Primary text |
| Blue | `#6699CC` | Focused elements, borders, headers |
| Green | `#99C794` | Active/playing items |
| Cyan | `#62B3B2` | Active highlighted items |
| Yellow | `#FAC863` | Warnings |
| Red | `#EC5F67` | Errors, banners |
| Grey | `#65737E` | Disabled text, secondary elements |
| Dark Grey | `#343D46` | Overlays, secondary backgrounds |

### Theme Elements

```
┌─────────────────────────────────────────────────────────────┐
│  Header (Blue #6699CC on Dark Grey #343D46)                 │
├─────────────────────────────────────────────────────────────┤
│  List items (Foreground #D8DEE9)                            │
│  ▶ Active item (Green #99C794 background)                   │
│    Highlighted (Light Grey #4F5B66 background)              │
│    Disabled (Grey #65737E)                                  │
├─────────────────────────────────────────────────────────────┤
│  Shortcuts bar (Dark Grey #343D46)                          │
│  [Focused shortcut] (Blue #6699CC background)               │
└─────────────────────────────────────────────────────────────┘
```

### Settings for Theme

In `settings.json`:

```json
{
  "ColorTheme": "oceanic-next",
  "UsePaletteColors": false,
  "DisableCustomColors": false,
  "InheritBackgroundColor": true
}
```

| Setting | Description |
|---------|-------------|
| `UsePaletteColors` | Must be `false` for true RGB colors |
| `InheritBackgroundColor` | Uses terminal background for seamless blending |

---

## Plugins

### Enabled Plugins

| Plugin | Description |
|--------|-------------|
| `libcoreaudioout.dylib` | Core Audio output (macOS) |
| `libffmpegdecoder.dylib` | FFmpeg decoder (MP3, AAC, etc.) |
| `libgmedecoder.dylib` | Game music decoder (NSF, SPC, etc.) |
| `libhttpdatastream.dylib` | HTTP streaming support |
| `libmacosmediakeys.dylib` | macOS media keys (play/pause/next) |
| `libopenmptdecoder.dylib` | OpenMPT decoder (MOD, S3M, XM, IT) |
| `libserver.dylib` | Remote streaming server |
| `libstockencoders.dylib` | Stock audio encoders |
| `libsupereqdsp.dylib` | 10-band equalizer |
| `libtaglibreader.dylib` | TagLib metadata reader |

### Plugin Configuration

Individual plugins store settings in `plugin_*.json` files:

- `plugin_supereqidsp.json` - Equalizer presets and settings
- `plugin_musikcubeserver(wss,http).json` - Server configuration
- `plugin_httpidatastream.json` - HTTP streaming settings

---

## Last.fm Scrobbling

### Setup

1. Create a Last.fm account at [last.fm](https://www.last.fm/)
2. In musikcube, go to Settings (`s`)
3. Navigate to Last.fm section
4. Authenticate with your username

### Configuration

In `settings.json`:

```json
{
  "LastFmUsername": "your_username",
  "LastFmSessionId": "...",
  "LastFmToken": "..."
}
```

**Note:** Session credentials are stored automatically after authentication.

---

## Remote Streaming

### Server Configuration

musikcube can act as a streaming server, allowing remote playback via the musikcube mobile app or web interface.

**Default Ports:**
- WebSocket: `7905`
- HTTP: `7906`

### Settings

In `settings.json`:

```json
{
  "RemoteLibraryHostname": "127.0.0.1",
  "RemoteLibraryWssPort": 7905,
  "RemoteLibraryHttpPort": 7906,
  "RemoteLibraryTranscoderEnabled": false,
  "RemoteLibraryTranscoderBitrate": 192,
  "RemoteLibraryTranscoderFormat": "ogg"
}
```

### Connecting Remotely

1. Enable server in musikcube settings
2. Note the server IP and ports
3. Connect using musikcube mobile app or web client

---

## Library Management

### Settings

```json
{
  "LibraryType": 1,
  "IndexerThreadCount": 4,
  "IndexerTransactionInterval": 300,
  "RemoveMissingFiles": true,
  "SyncOnStartup": true
}
```

| Setting | Description |
|---------|-------------|
| `LibraryType` | 1 = local, 2 = remote |
| `IndexerThreadCount` | Parallel indexing threads |
| `RemoveMissingFiles` | Auto-remove missing tracks |
| `SyncOnStartup` | Rescan library on startup |

### Indexing Commands

- `R` - Rescan/rebuild metadata
- Settings > Library > Rescan

---

## Playback Settings

```json
{
  "ResumePlaybackOnStartup": false,
  "SaveSessionOnExit": true,
  "PlaybackTrackQueryTimeoutMs": 5000
}
```

| Setting | Description |
|---------|-------------|
| `ResumePlaybackOnStartup` | Auto-resume on launch |
| `SaveSessionOnExit` | Remember queue/position |
| `PlaybackTrackQueryTimeoutMs` | Track query timeout |

---

## Troubleshooting

### Theme Not Loading

**Problem:** Colors look wrong or theme not applied

**Solution:**
```json
// In settings.json
{
  "ColorTheme": "oceanic-next",
  "UsePaletteColors": false,
  "DisableCustomColors": false
}
```

Ensure your terminal supports true color (24-bit). Test with:
```bash
printf "\x1b[38;2;255;100;0mTrueColor\x1b[0m\n"
```

### Media Keys Not Working

**Problem:** macOS media keys don't control musikcube

**Solution:**
1. Check `plugins.json` has `"libmacosmediakeys.dylib": true`
2. Ensure musikcube is the focused application
3. Check System Preferences > Security > Privacy > Accessibility

### No Audio Output

**Problem:** No sound from musikcube

**Solution:**
1. Check volume: press `0` to increase
2. Check mute status: press `m` to toggle
3. Verify Core Audio plugin: `"libcoreaudioout.dylib": true` in `plugins.json`
4. Check system audio output device

### Library Not Scanning

**Problem:** Music files not appearing

**Solution:**
1. Press `s` for settings
2. Navigate to Library section
3. Verify music directory path is correct
4. Press `R` to force rescan
5. Check supported formats (MP3, FLAC, AAC, OGG, etc.)

### Last.fm Not Scrobbling

**Problem:** Tracks not scrobbling to Last.fm

**Solution:**
1. Re-authenticate in Settings > Last.fm
2. Check network connectivity
3. Verify username in `settings.json`
4. Play tracks for >30 seconds before scrobbling

---

## File Locations

| File | Purpose |
|------|---------|
| `settings.json` | Main configuration |
| `hotkeys.json` | Keybindings |
| `plugins.json` | Plugin enable/disable |
| `libraries.json` | Library paths |
| `playback.json` | Playback state |
| `session.json` | Session data |
| `themes/*.json` | Color themes |
| `plugin_*.json` | Per-plugin settings |

---

## Related Documentation

- [musikcube Official Site](https://musikcube.com/)
- [musikcube GitHub](https://github.com/clangen/musikcube)
- [Theme Creator Tool](https://antoineturmel.github.io/musikbox-theme-creator/)
- [Community Themes](https://github.com/clangen/musikcube/issues/145)

---

**Configuration Location:** `~/dotfiles/config/musikcube/`
**Symlinked To:** `~/.config/musikcube/`
