# Yabai - Tiling Window Manager Configuration

Yabai is a tiling window manager for macOS that automatically arranges windows in non-overlapping layouts. This configuration provides a productive, keyboard-driven window management experience.

## About Yabai

- **Purpose**: Automatic window tiling and management for macOS
- **Config File**: `~/.config/yabai/yabairc`
- **Layout**: BSP (Binary Space Partitioning) - splits space recursively
- **Control**: Via SKHD keyboard shortcuts (see [SKHD documentation](../skhd/README.md))
- **Official Repo**: [koekeishiya/yabai](https://github.com/koekeishiya/yabai)

## Installation

### Basic Installation

```bash
# Install via Homebrew
brew install yabai

# Start yabai service
brew services start yabai
```

### Scripting Addition (Optional)

For advanced features like window opacity and borders, you need to install the scripting addition:

1. **Disable System Integrity Protection (SIP):**
   - Reboot into Recovery Mode (hold Cmd+R during startup)
   - Open Terminal from Utilities menu
   - Run: `csrutil disable`
   - Reboot normally

2. **Configure sudo without password for yabai:**
   ```bash
   sudo visudo -f /private/etc/sudoers.d/yabai
   ```

   Add this line (replace `<user>` with your username):
   ```
   <user> ALL=(root) NOPASSWD: sha256:<hash> <path> --load-sa
   ```

   Get the hash by running:
   ```bash
   shasum -a 256 $(which yabai)
   ```

3. **Restart yabai:**
   ```bash
   brew services restart yabai
   ```

See the [official guide](https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)#configure-scripting-addition) for detailed instructions.

## Configuration Overview

### Layout Settings

| Setting | Value | Description |
|---------|-------|-------------|
| **Layout** | `bsp` | Binary space partitioning (automatic tiling) |
| **Split Ratio** | `0.50` | New windows take 50% of space |
| **Split Type** | `auto` | Automatically choose horizontal/vertical |
| **Auto Balance** | `off` | Don't resize all windows when adding/removing |
| **Window Gap** | `6px` | Space between windows |
| **Padding** | `0px` | Space at screen edges |

### Mouse Settings

| Setting | Value | Description |
|---------|-------|-------------|
| **Mouse Modifier** | `fn` | Hold Fn key to drag/resize with mouse |
| **Mouse Action 1** | `move` | Fn + Left-click = move window |
| **Mouse Action 2** | `resize` | Fn + Right-click = resize window |
| **Drop Action** | `swap` | Drag window onto another to swap positions |

### Focus & Behavior

| Setting | Value | Description |
|---------|-------|-------------|
| **Mouse Follows Focus** | `off` | Cursor doesn't move when changing focus |
| **Focus Follows Mouse** | `off` | Focus doesn't change on mouse hover |
| **Window Placement** | `second_child` | New windows split from focused window |
| **Window Zoom Persist** | `on` | Remember fullscreen state |

### Visual Settings

| Setting | Value | Description |
|---------|-------|-------------|
| **Window Border** | `off` | No colored borders (can enable) |
| **Border Width** | `4px` | Border thickness (if enabled) |
| **Border Radius** | `12px` | Rounded corners (if enabled) |
| **Window Opacity** | `off` | Solid windows (can enable for transparency) |
| **Normal Opacity** | `0.90` | Unfocused window opacity (if enabled) |
| **Active Opacity** | `1.0` | Focused window is fully opaque |
| **Animation Duration** | `0.0` | Instant window movements (no animation) |

## Application Rules

Some applications work better as floating windows instead of tiled. This configuration excludes specific apps from tiling:

### System & Utility Apps (Float + Stay on Top)
- **1Password** - Password manager
- **Activity Monitor** - System monitor
- **Alfred Preferences** - Launcher settings
- **Archive Utility** - Compression tool
- **Disk Utility** - Disk management
- **Finder** - File browser
- **Installer** - macOS installer windows
- **System Preferences** - Settings app

### Media & Creative Apps
- **DaVinci Resolve** - Video editor (disabled tiling)
- **GIMP** - Image editor (float + on top)
- **Live** - Ableton Live (float + on top)
- **OBS** - Streaming software (float + on top)
- **mpv** - Media player (float + on top)
- **Spotify** - Music player (disabled tiling)

### Productivity Apps
- **Fantastical** - Calendar (disabled tiling)
- **Microsoft Teams** - Communication (disabled tiling)

### Music Production Apps
- **Komplete Kontrol** - NI controller (float + on top)
- **Native Access** - NI software manager (disabled tiling)
- **iZotope Product Portal** - Audio plugins (float + on top)
- **iZotope RX 10** - Audio repair (float + on top)
- **VCV Rack 2 Pro** - Modular synth (disabled tiling)

### Other Apps
- **Karabiner-Elements** - Keyboard customization (float + on top)
- **CleanMyMac X** - System cleaner (disabled tiling)

## Usage with SKHD

Yabai is controlled via keyboard shortcuts defined in SKHD. See the [SKHD README](../skhd/README.md) for keybindings.

### Quick Reference

| Action | Keybinding |
|--------|------------|
| Resize window | `Ctrl + Alt + H/J/K/L` |
| Swap windows | `Ctrl + Shift + H/J/K/L` |
| Rotate layout 90° | `Ctrl + Shift + R` |
| Toggle fullscreen | `Ctrl + Shift + F` |
| Balance all windows | `Ctrl + Alt + 0` |

## How Tiling Works

### BSP (Binary Space Partitioning)

Yabai uses a BSP layout, which means:

1. **First window:** Takes full screen
2. **Second window:** Splits screen in half (50/50)
3. **Third window:** Splits the focused window's space again
4. **Nth window:** Continues splitting recursively

**Example:**

```
┌─────────────────────┐    ┌──────────┬──────────┐    ┌──────────┬──────────┐
│                     │    │          │          │    │    1     │     2    │
│         1           │ →  │    1     │    2     │ →  ├──────────┼──────────┤
│                     │    │          │          │    │          │          │
└─────────────────────┘    └──────────┴──────────┘    │    3     │          │
                                                       └──────────┴──────────┘
   1 window                  2 windows                  3 windows
```

### Window Placement

- **Second Child Mode**: New windows split from the currently focused window
- **Split Direction**: Automatically chooses horizontal or vertical based on aspect ratio
- **Manual Control**: Use keyboard shortcuts to swap, resize, or rotate layout

## Common Yabai Commands

### Window Management

```bash
# Focus window in direction
yabai -m window --focus <north|south|east|west>

# Swap window with another
yabai -m window --swap <direction>

# Move window to space
yabai -m window --space <number>

# Toggle fullscreen
yabai -m window --toggle zoom-fullscreen

# Float/unfloat window
yabai -m window --toggle float
```

### Space Management

```bash
# Focus space (desktop)
yabai -m space --focus <number>

# Rotate windows 90 degrees
yabai -m space --rotate 90

# Flip windows horizontally/vertically
yabai -m space --mirror x-axis
yabai -m space --mirror y-axis

# Balance all windows
yabai -m space --balance

# Change layout
yabai -m space --layout <bsp|float|stack>
```

### Display Management

```bash
# Focus display
yabai -m display --focus <number>

# Move window to display
yabai -m window --display <number>
```

## Typical Workflows

### Development Workflow

1. **Terminal + Editor + Browser:**
   ```
   ┌──────────┬──────────┐
   │          │          │
   │  Editor  │  Browser │
   │          │          │
   ├──────────┴──────────┤
   │     Terminal        │
   └─────────────────────┘
   ```
   - Open Neovim, Chrome, and Terminal
   - Yabai automatically tiles them
   - Use `Ctrl + Shift + H/J/K/L` to rearrange

2. **Focus Mode:**
   - Use `Ctrl + Shift + F` to fullscreen your editor
   - Work distraction-free
   - Toggle back when needed

### Music Production Workflow

- DAWs (Ableton, etc.) float by default and stay on top
- Other windows tile normally beneath
- Focus DAW when needed, it appears above tiled windows

### Communication Workflow

- Teams, Messages, WhatsApp can be disabled from tiling
- They float and can be positioned manually
- Tiled windows for work remain organized

## Customization

### Adding App Rules

To exclude an app from tiling:

```bash
# Edit yabairc
nvim ~/.config/yabai/yabairc

# Add a rule
yabai -m rule --add app="^AppName$" manage=off

# Reload yabai
brew services restart yabai
```

Rule options:
- `manage=off` - Don't tile this app
- `sticky=on` - Show on all spaces
- `layer=above` - Always on top
- `opacity=0.9` - Set transparency (requires scripting addition)

### Changing Gap Size

```bash
# In yabairc, modify:
yabai -m config window_gap 12  # Change from 6 to 12 pixels
```

### Enabling Window Borders

```bash
# In yabairc, change:
yabai -m config window_border on

# Customize colors:
yabai -m config active_window_border_color 0xff775759
yabai -m config normal_window_border_color 0xff555555
```

## Troubleshooting

### Yabai Not Tiling Windows

1. **Check if yabai is running:**
   ```bash
   brew services list | grep yabai
   ```

2. **Restart yabai:**
   ```bash
   brew services restart yabai
   ```

3. **Check logs:**
   ```bash
   tail -f /tmp/yabai_$USER.out.log
   tail -f /tmp/yabai_$USER.err.log
   ```

4. **Verify accessibility permissions:**
   - System Preferences → Security & Privacy → Privacy → Accessibility
   - Ensure yabai is listed and enabled

### Window Not Being Tiled

The app might be in the exclusion list:

```bash
# Check rules
yabai -m rule --list

# Remove rule for app
yabai -m rule --remove <app name>
```

### Scripting Addition Not Working

1. **Verify SIP is disabled:**
   ```bash
   csrutil status
   # Should show: disabled
   ```

2. **Check sudo configuration:**
   ```bash
   sudo -l
   # Should show yabai with NOPASSWD
   ```

3. **Reinstall scripting addition:**
   ```bash
   sudo yabai --uninstall-sa
   sudo yabai --install-sa
   brew services restart yabai
   ```

### Windows Overlapping

If windows start overlapping:

```bash
# Restart yabai
brew services restart yabai

# Or force reload spaces
yabai -m space --balance
```

## Performance Tips

1. **Disable animations** (already set to 0.0)
2. **Limit rules** - Only add rules for apps that truly need them
3. **Use signals** - Automate actions based on events
4. **Monitor logs** - Check for errors that might slow things down

## Advanced Features

### Signals

Execute commands when events occur:

```bash
# Example: Auto-balance when window is closed
yabai -m signal --add \
  event=window_destroyed \
  action="yabai -m space --balance"
```

### Spaces (Desktops)

```bash
# Create new space
yabai -m space --create

# Destroy space
yabai -m space --destroy

# Move window to new space
yabai -m window --space recent
```

## Additional Resources

- [Yabai GitHub](https://github.com/koekeishiya/yabai) - Official documentation
- [Yabai Wiki](https://github.com/koekeishiya/yabai/wiki) - Installation guides
- [SKHD Configuration](../skhd/README.md) - Keyboard shortcuts
- [r/yabai](https://reddit.com/r/yabai) - Community support

---

**Note:** Yabai works best with SKHD for keyboard control. See the [SKHD README](../skhd/README.md) for configured keybindings.
