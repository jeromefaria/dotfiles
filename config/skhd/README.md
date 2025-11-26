# SKHD (Simple Hotkey Daemon) Configuration

SKHD is a simple hotkey daemon for macOS that allows you to bind keyboard shortcuts to execute commands. This configuration file defines keybindings for window management using Yabai.

## About SKHD

- **Purpose**: System-wide keyboard shortcut manager for macOS
- **Config File**: `~/.config/skhd/skhdrc`
- **Restart**: `brew services restart skhd`
- **Official Repo**: [koekeishiya/skhd](https://github.com/koekeishiya/skhd)

## Installation

SKHD should be installed via Homebrew and running as a service:

```bash
brew install skhd
brew services start skhd
```

## Active Keybindings

This configuration provides Vim-style window management keybindings. All shortcuts use modifiers with `h`, `j`, `k`, `l` for directional control.

### Window Resizing

Resize windows by expanding or contracting edges:

| Keybinding | Action |
|------------|--------|
| `Ctrl + Alt + H` | Resize window left edge (contract) |
| `Ctrl + Alt + L` | Resize window left edge (expand) |
| `Ctrl + Alt + K` | Resize window top edge (contract) |
| `Ctrl + Alt + J` | Resize window top edge (expand) |
| `Ctrl + Alt + 0` | Balance all windows to equal size |

**Usage Example:**
- Press `Ctrl + Alt + H` repeatedly to make window narrower (move left edge right)
- Press `Ctrl + Alt + L` repeatedly to make window wider (move left edge left)
- Press `Ctrl + Alt + 0` to reset all windows to equal sizes

### Window Swapping

Swap the current window with adjacent windows in different directions:

| Keybinding | Action |
|------------|--------|
| `Ctrl + Shift + K` | Swap window with window above (north) |
| `Ctrl + Shift + J` | Swap window with window below (south) |
| `Ctrl + Shift + H` | Swap window with window to the left (west) |
| `Ctrl + Shift + L` | Swap window with window to the right (east) |

**Usage Example:**
- Have two windows side-by-side
- Focus on the left window
- Press `Ctrl + Shift + L` to swap it with the right window

### Layout Management

| Keybinding | Action |
|------------|--------|
| `Ctrl + Shift + R` | Rotate windows 90 degrees clockwise |
| `Ctrl + Shift + F` | Toggle fullscreen zoom for current window |

**Usage Example:**
- `Ctrl + Shift + R`: Rotate layout (horizontal split becomes vertical)
- `Ctrl + Shift + F`: Make window take full space (not native macOS fullscreen)

## Modifier Key Reference

| Modifier | Symbol | Key |
|----------|--------|-----|
| `ctrl` | ⌃ | Control |
| `alt` | ⌥ | Option/Alt |
| `shift` | ⇧ | Shift |
| `cmd` | ⌘ | Command |

## Integration with Yabai

These keybindings control **Yabai**, a tiling window manager for macOS. Yabai must be installed and running for these shortcuts to work:

```bash
brew install yabai
brew services start yabai
```

See the [Yabai documentation](../yabai/README.md) for more information about the window manager configuration.

## Customization

To add your own keybindings:

1. Edit the config file:
   ```bash
   nvim ~/.config/skhd/skhdrc
   ```

2. Follow the syntax format:
   ```bash
   # modifier - key : command
   ctrl + alt - space : open -a "Terminal"
   ```

3. Reload SKHD:
   ```bash
   brew services restart skhd
   ```

## Common Commands

### Yabai Window Management

```bash
# Focus window
yabai -m window --focus <direction>

# Swap windows
yabai -m window --swap <direction>

# Resize window
yabai -m window --resize <side>:<x>:<y>

# Toggle fullscreen
yabai -m window --toggle zoom-fullscreen

# Balance windows
yabai -m space --balance

# Rotate layout
yabai -m space --rotate 90
```

Where:
- `<direction>` = north, south, east, west
- `<side>` = left, right, top, bottom
- `<x>:<y>` = pixel amounts (can be negative)

### Application Launching

You can add shortcuts to launch applications:

```bash
# Example: Launch applications (commented out by default)
# cmd + alt - t : open -a "Terminal"
# cmd + alt - b : open -a "Safari"
# cmd + alt - c : open -a "Visual Studio Code"
```

## Troubleshooting

### Shortcuts Not Working

1. **Check if SKHD is running:**
   ```bash
   brew services list | grep skhd
   ```

2. **Restart SKHD:**
   ```bash
   brew services restart skhd
   ```

3. **Check for syntax errors:**
   ```bash
   skhd --verbose
   ```

4. **Verify Accessibility permissions:**
   - Go to System Preferences → Security & Privacy → Privacy → Accessibility
   - Ensure SKHD is listed and enabled

### Conflicts with System Shortcuts

macOS has many built-in keyboard shortcuts that may conflict. You can:

1. Disable conflicting macOS shortcuts:
   - System Preferences → Keyboard → Shortcuts
   - Uncheck or modify conflicting shortcuts

2. Choose different modifier combinations:
   - Prefer `Ctrl + Alt` combinations (less conflicts)
   - Avoid `Cmd` combinations (heavily used by macOS)

### Yabai Not Responding

If Yabai isn't responding to SKHD commands:

```bash
# Check Yabai is running
brew services list | grep yabai

# Restart Yabai
brew services restart yabai

# Check Yabai logs
tail -f /tmp/yabai_$USER.out.log
```

## Advanced: Modes

SKHD supports modes for complex workflows. Example:

```bash
# Declare a mode
:: resize @ : echo "resize mode activated"

# Enter resize mode
ctrl + alt - r ; resize

# Exit mode (return to default)
resize < escape ; default
resize < return ; default

# Mode-specific bindings
resize < h : yabai -m window --resize left:-20:0
resize < l : yabai -m window --resize left:20:0
```

This allows you to:
1. Press `Ctrl + Alt + R` to enter "resize mode"
2. Use `H`, `J`, `K`, `L` without modifiers to resize
3. Press `Escape` or `Return` to exit mode

## Example Workflow

### Typical Window Management Session

1. **Open 3 terminal windows**
2. **Yabai automatically tiles them**
3. **Resize the focused window:** `Ctrl + Alt + L` (make it wider)
4. **Swap with window above:** `Ctrl + Shift + K`
5. **Rotate layout:** `Ctrl + Shift + R` (vertical → horizontal)
6. **Balance all windows:** `Ctrl + Alt + 0` (equal sizes)
7. **Focus one window:** `Ctrl + Shift + F` (toggle fullscreen)

## Additional Resources

- [SKHD GitHub](https://github.com/koekeishiya/skhd) - Official documentation
- [Yabai Configuration](../yabai/README.md) - Window manager docs
- [SKHD Wiki](https://github.com/koekeishiya/skhd/wiki) - Community examples

---

**Note:** This configuration is designed to work seamlessly with Yabai. If you're not using Yabai, you can modify the commands to work with other tools or applications.
