# Karabiner-Elements Configuration

System-wide keyboard remapping with vim-like modal editing and tmux integration.

## Overview

This [Karabiner-Elements](https://karabiner-elements.pqrs.org/) configuration provides:
- **System-wide Vim mode** - Modal editing in any application
- **Tmux prefix mode** - Caps Lock as ergonomic tmux prefix
- **Hammerspoon integration** - Custom system automation triggers
- **Smart application filtering** - Excludes IDEs and terminals where appropriate

**Configuration File:** `karabiner.json` (4,964 lines, 249KB)

---

## Table of Contents

- [Installation](#installation)
- [Core Concepts](#core-concepts)
- [Caps Lock Remapping](#caps-lock-remapping)
- [Tmux Prefix Mode](#tmux-prefix-mode)
- [Vim Mode](#vim-mode)
- [Hammerspoon Integration](#hammerspoon-integration)
- [Application Filtering](#application-filtering)
- [Troubleshooting](#troubleshooting)

---

## Installation

### Prerequisites

```bash
# Install Karabiner-Elements
brew install --cask karabiner-elements

# Grant necessary permissions in System Settings:
# Privacy & Security → Input Monitoring → Karabiner-Elements
# Privacy & Security → Accessibility → Karabiner-Elements
```

### Configuration

Symlinked automatically via dotfiles:

```bash
# Via dotfiles installation
cd ~/dotfiles
./scripts/install.sh

# Manual symlink
ln -s ~/dotfiles/config/karabiner ~/.config/karabiner
```

### First Launch

1. Open Karabiner-Elements
2. Grant required permissions when prompted
3. Configuration loads automatically
4. Test Caps Lock remapping

---

## Core Concepts

### Modal Editing

The configuration implements **vim-like modes** with visual feedback:

| Mode | Indicator | Purpose |
|------|-----------|---------|
| **Insert** | (none) | Normal typing |
| **Normal** | "NORMAL - Vim Mode Enabled" | Vim navigation |
| **Visual** | "VISUAL - Visual Mode Enabled" | Text selection |
| **Tmux Prefix** | (transient) | Tmux commands |

### Mode Switching

```text
[Insert Mode]
     ↓ Caps Lock
[Normal Mode]  ←→  [Visual Mode]
     ↓ v              ↓ v
     ↓ Escape         ↓ Escape
[Insert Mode]  ←  [Insert Mode]
```

### State Variables

The configuration uses internal variables to track state:
- `vim_mode` - Normal mode active
- `visual_mode` - Visual selection active
- `d_pressed`, `y_pressed`, `c_pressed` - Operator pending
- `g_pressed` - Go-to prefix pending
- `tmux_prefix_mode` - Tmux command mode active

---

## Caps Lock Remapping

### Base Mapping

**Caps Lock** → **F12** (simple modification)

Then F12 → Volume Increment (function key mapping)

### Why F12?

- **Ergonomic**: Thumb position, no pinky strain
- **Compatible**: Doesn't conflict with common shortcuts
- **Flexible**: Can be remapped contextually (tmux, vim modes)

### Usage Contexts

| Context | Caps Lock Behavior |
|---------|-------------------|
| Terminal apps | Activates tmux prefix mode |
| Other apps | Activates vim normal mode |
| Vim mode active | Returns to insert mode |
| Pressed alone >500ms | Sends actual Caps Lock |

---

## Tmux Prefix Mode

### Activation

**In terminal applications only:**
- Press and hold `Caps Lock`
- `tmux_prefix_mode` variable set
- All subsequent keys prefixed with `Ctrl+B`

### Supported Terminal Applications

```text
✓ Terminal.app (com.apple.Terminal)
✓ iTerm2 (com.googlecode.iterm2)
✓ Hyper (co.zeit.hyperterm, co.zeit.hyper)
✓ Alacritty (io.alacritty, org.alacritty)
✓ Kitty (net.kovidgoyal.kitty)
```

### Key Mappings

When `Caps Lock` is held in a terminal:

**Letters (a-z):**
```text
Caps Lock + c → Ctrl+B, c  (new window)
Caps Lock + d → Ctrl+B, d  (detach)
Caps Lock + w → Ctrl+B, w  (window list)
Caps Lock + [ → Ctrl+B, [  (copy mode)
Caps Lock + ] → Ctrl+B, ]  (paste)
```

**Numbers (0-9):**
```text
Caps Lock + 1 → Ctrl+B, 1  (window 1)
Caps Lock + 2 → Ctrl+B, 2  (window 2)
... etc
```

**Symbols:**
```text
Caps Lock + , → Ctrl+B, ,  (rename window)
Caps Lock + / → Ctrl+B, /  (find)
Caps Lock + . → Ctrl+B, .  (move window)
Caps Lock + ; → Ctrl+B, ;  (last pane)
Caps Lock + ' → Ctrl+B, '  (select window)
```

### Workflow Example

```text
# Create new tmux window
Caps Lock + c

# Navigate to window 3
Caps Lock + 3

# Rename window
Caps Lock + ,
(type new name)

# Detach from session
Caps Lock + d
```

---

## Vim Mode

### Activation

**System-wide** (except in terminals and IDEs):

**Enter Normal Mode:**
- Tap `Caps Lock` (or hold >100ms)
- Notification: "NORMAL - Vim Mode Enabled"

**Exit Normal Mode:**
- Tap `Caps Lock` again
- Press `Escape`
- Press `Ctrl+[`
- Click mouse/trackpad
- Touch trackpad + any key

### Normal Mode Navigation

#### Basic Movement

| Key | Action | Implementation |
|-----|--------|----------------|
| `h` | Left | ← |
| `j` | Down | ↓ |
| `k` | Up | ↑ |
| `l` | Right | → |

**Supports modifiers:** Hold Shift/Cmd/Option/Ctrl for extended selection/navigation

#### Word Movement

| Key | Action | Implementation |
|-----|--------|----------------|
| `e` | End of word | Option+→ |
| `b` | Beginning of word | Option+← |

#### Line Movement

| Key | Action | Implementation |
|-----|--------|----------------|
| `0` | Line start | Cmd+← (×2) |
| `^` | First non-blank | Cmd+← (×2) |
| `$` | Line end | Cmd+→ |

#### Document Movement

| Key | Action | Implementation |
|-----|--------|----------------|
| `gg` | Document start | Cmd+↑ |
| `G` | Document end | Cmd+↓ |
| `{` | Previous paragraph | Ctrl+A |
| `}` | Next paragraph | Ctrl+E |

### Visual Mode

#### Enter Visual Mode

```text
[Normal Mode]
    ↓ v
[Visual Mode]
```

**Notification:** "VISUAL - Visual Mode Enabled"

#### Visual Selection

All navigation keys work but add Shift for selection:

```text
h, j, k, l  →  Selection extends in that direction
e, b        →  Select to word boundary
0, ^, $     →  Select to line boundaries
gg, G       →  Select to document boundaries
{, }        →  Select paragraphs
```

#### Visual Operations

| Key | Action | Result |
|-----|--------|--------|
| `d` | Delete | Cut selection (Cmd+X) |
| `y` | Yank | Copy selection (Cmd+C) |
| `c` | Change | Cut + exit to insert mode |
| `x` | Delete | Delete selection |
| `v` | Exit | Return to normal mode |

### Operators

#### Delete Operator (`d`)

Press `d` to activate delete mode (500ms window):

```text
dd   →  Delete entire line
de   →  Delete to end of word
db   →  Delete to beginning of word
d0   →  Delete to line start
d^   →  Delete to first non-blank
d$   →  Delete to line end
dgg  →  Delete to document start
dG   →  Delete to document end
d{   →  Delete to previous paragraph
d}   →  Delete to next paragraph
```

**Implementation:** Navigates + selects + Cmd+X

#### Yank (Copy) Operator (`y`)

Press `y` to activate yank mode (500ms window):

```text
yy   →  Copy entire line
ye   →  Copy to end of word
yb   →  Copy to beginning of word
y0   →  Copy to line start
y^   →  Copy to first non-blank
y$   →  Copy to line end
ygg  →  Copy to document start
yG   →  Copy to document end
y{   →  Copy to previous paragraph
y}   →  Copy to next paragraph
```

**Implementation:** Navigates + selects + Cmd+C + deselect

#### Change Operator (`c`)

Press `c` to activate change mode (500ms window):

```text
cc   →  Change entire line
ce   →  Change to end of word
cb   →  Change to beginning of word
c0   →  Change to line start
c^   →  Change to first non-blank
c$   →  Change to line end
cgg  →  Change to document start
cG   →  Change to document end
c{   →  Change to previous paragraph
c}   →  Change to next paragraph
```

**Implementation:** Deletes text + exits vim mode (insert mode)

### Insert Mode

#### Enter Insert Mode

All commands exit vim mode:

| Key | Action | Cursor Position |
|-----|--------|----------------|
| `i` | Insert | At cursor |
| `I` | Insert | At line start |
| `a` | Append | After cursor |
| `A` | Append | At line end |
| `o` | Open below | New line below |
| `O` | Open above | New line above |

### Simple Operations

| Key | Action | Implementation |
|-----|--------|----------------|
| `x` | Delete char | Delete forward |
| `X` | Delete before | Backspace |
| `p` | Paste after | Cmd+V |
| `P` | Paste before | Cmd+V |
| `u` | Undo | Cmd+Z |
| `Ctrl+r` | Redo | Cmd+Shift+Z |

---

## Hammerspoon Integration

### Modal Triggers

When in vim normal mode, these keys exit vim and trigger Hammerspoon:

| Key | F-Key Sent | Likely Purpose |
|-----|------------|----------------|
| `s` | F20 | Window management modal |
| `m` | F19 | Application/mode modal |
| `Space` | F18 | Command palette/launcher |

**Usage:**
```text
[Normal Mode]
    ↓ s
[Hammerspoon Window Modal]
    (manage windows with hjkl, etc.)
```

### Hammerspoon Configuration

You'll need matching Hammerspoon configuration to handle F18-F20:

```lua
-- Example: ~/.hammerspoon/init.lua
hs.hotkey.bind({}, 'F18', function()
  -- Launch command palette
end)

hs.hotkey.bind({}, 'F19', function()
  -- Application switcher
end)

hs.hotkey.bind({}, 'F20', function()
  -- Window management modal
end)
```

---

## Application Filtering

### Vim Mode Excluded Applications

Vim mode is **disabled** in these applications (they have native vim support):

```text
✗ iTerm2 (com.googlecode.iterm2)
✗ Atom (com.github.atom)
✗ PyCharm (com.jetbrains.pycharm)
✗ VS Code OSS (com.visualstudio.code.oss)
```

**Reason:** These applications have their own vim modes that would conflict.

### Tmux Mode Active Applications

Tmux prefix mode **only works** in terminal applications:

```text
✓ Terminal.app
✓ iTerm2
✓ Hyper
✓ Alacritty
✓ Kitty
```

**Reason:** Tmux only runs in terminal emulators.

---

## Common Workflows

### Text Editing in Browser

```text
1. Click in text field (insert mode)
2. Caps Lock (enter normal mode)
3. Navigate with hjkl
4. v (visual mode)
5. Select text with hjkl
6. y (yank/copy)
7. Navigate to destination
8. p (paste)
9. Caps Lock (back to insert mode)
```

### Tmux Window Management

```text
1. Open iTerm2
2. Start tmux
3. Caps Lock + c (new window)
4. Caps Lock + , (rename window)
5. Type name, Enter
6. Caps Lock + n (next window)
7. Caps Lock + 1 (jump to window 1)
```

### Quick Editing

```text
1. Normal mode (Caps Lock)
2. Navigate to word (w or b)
3. dw (delete word)
4. Type new word
5. Escape or Caps Lock
```

### System-Wide Copy

```text
1. Caps Lock (normal mode)
2. gg (document start)
3. v (visual mode)
4. G (select to end)
5. y (yank all)
6. Caps Lock (exit modes)
```

---

## Technical Details

### Variable Timeout Pattern

Operators use delayed actions:

```text
Press d
 ↓
d_pressed = 1
 ↓
Wait for second key (500ms)
 ├─ Key pressed → Execute operation, d_pressed = 0
 └─ Timeout → d_pressed = 0, no operation
```

### Modifier Preservation

Most vim keys preserve macOS modifiers:

```text
h     → ←
Cmd+h → Cmd+← (word left in some apps)
Shift+h → Shift+← (select left)
```

### Complex Sequences

Some operations require multiple synthesized keys:

**Delete line (dd):**
```text
1. Cmd+← (×2)     # Go to line start
2. Cmd+Shift+→    # Select entire line
3. Cmd+X          # Cut
4. Exit d_pressed
```

**Go to start (gg):**
```text
1. First g → Set g_pressed (500ms timeout)
2. Second g → Send Cmd+↑, reset g_pressed
```

---

## Troubleshooting

### Vim Mode Not Working

**Problem:** Caps Lock doesn't activate vim mode

**Solutions:**
```bash
# Check Karabiner-Elements permissions
System Settings → Privacy & Security → Input Monitoring

# Verify Karabiner is running
ps aux | grep karabiner

# Reload configuration
# In Karabiner-Elements.app: Misc → Reload

# Check excluded applications
# Make sure you're not in iTerm2/Atom/PyCharm/VS Code OSS
```

### Stuck in Vim Mode

**Problem:** Can't exit vim mode

**Solutions:**
```text
# Try these in order:
1. Tap Caps Lock again
2. Press Escape
3. Press Ctrl+[
4. Click mouse anywhere
5. Touch trackpad + any key
6. Restart Karabiner-Elements
```

### Tmux Prefix Not Working

**Problem:** Caps Lock doesn't trigger tmux commands in terminal

**Solutions:**
```bash
# Verify you're in a supported terminal
# Supported: Terminal.app, iTerm2, Hyper, Alacritty, Kitty

# Check tmux prefix in tmux.conf
grep prefix ~/.tmux.conf
# Should be: set-option -g prefix C-b

# Test manually
# In terminal, press: Ctrl+B, c
# Should create new tmux window
```

### Keys Not Responding

**Problem:** Some keys don't work in vim mode

**Solutions:**
```bash
# Some apps don't respond to synthesized keyboard events
# Known issues:
# - Certain web apps
# - Some Electron applications
# - Protected system dialogs

# Workaround: Use native text editing in those apps
# Or exit vim mode (Caps Lock) temporarily
```

### Caps Lock Still Types

**Problem:** Caps Lock activates actual caps lock

**Solution:**
```bash
# Happens if you hold Caps Lock >500ms without another key

# This is intentional - allows actual caps lock if needed
# For vim mode: tap quickly (<500ms)
# For caps lock: hold >500ms
```

### Function Keys Not Working

**Problem:** F1-F12 don't do media controls

**Solution:**
```bash
# Check macOS keyboard settings
System Settings → Keyboard → Keyboard Shortcuts → Function Keys

# Verify Karabiner function key mappings
# In Karabiner-Elements.app: Function Keys tab
# All F1-F12 should map to their media functions
```

---

## Customization

### Adding Custom Vim Bindings

Edit `karabiner.json` complex modifications section:

```json
{
  "description": "Custom vim binding",
  "manipulators": [
    {
      "type": "basic",
      "from": {
        "key_code": "n",
        "modifiers": {"optional": ["any"]}
      },
      "to": [
        {"key_code": "down_arrow", "repeat": false}
      ],
      "conditions": [
        {
          "type": "variable_if",
          "name": "vim_mode",
          "value": 1
        }
      ]
    }
  ]
}
```

### Changing Caps Lock Behavior

Edit simple modifications:

```json
{
  "from": {"key_code": "caps_lock"},
  "to": [{"key_code": "f19"}]  // Change to different key
}
```

### Excluding More Applications

Add to excluded app list:

```json
{
  "type": "frontmost_application_unless",
  "bundle_identifiers": [
    "com.example.app"  // Add your app's bundle ID
  ]
}
```

**Find bundle ID:**
```bash
osascript -e 'id of app "Application Name"'
```

---

## Performance Considerations

### Event Processing

- **Complex modifications:** ~13 major rule groups
- **State variables:** 8+ tracked simultaneously
- **Performance:** Negligible impact on modern Macs

### Memory Usage

- **Configuration size:** 249KB
- **Karabiner overhead:** ~50-100MB RAM
- **CPU usage:** <1% during normal use

---

## Comparison with Alternatives

| Feature | Karabiner | Hammerspoon | BetterTouchTool |
|---------|-----------|-------------|-----------------|
| Vim mode | ✅ Built-in | ⚠️ Lua scripting | ❌ Limited |
| Tmux integration | ✅ Native | ⚠️ Via scripting | ❌ No |
| App filtering | ✅ Excellent | ✅ Good | ✅ Good |
| Complexity | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Free | ✅ Yes | ✅ Yes | ❌ Paid |

---

## Quick Reference

### Mode Indicators

```text
(no notification) → Insert Mode (normal typing)
"NORMAL - Vim Mode Enabled" → Normal Mode (navigation)
"VISUAL - Visual Mode Enabled" → Visual Mode (selection)
```

### Essential Commands

**Mode Switching:**
```text
Caps Lock → Normal mode
v → Visual mode
i/a → Insert mode
Escape → Exit mode
```

**Navigation:**
```text
hjkl → Basic movement
e/b → Word boundaries
0/$ → Line boundaries
gg/G → Document boundaries
```

**Operators:**
```text
dd → Delete line
yy → Copy line
cc → Change line
p → Paste
u → Undo
```

**Tmux (in terminals):**
```text
Caps Lock + c → New window
Caps Lock + d → Detach
Caps Lock + [0-9] → Switch window
Caps Lock + , → Rename window
```

---

## Related Documentation

- [Karabiner-Elements Official Site](https://karabiner-elements.pqrs.org/)
- [Karabiner Documentation](https://karabiner-elements.pqrs.org/docs/)
- [Complex Modifications Database](https://ke-complex-modifications.pqrs.org/)
- [Hammerspoon](https://www.hammerspoon.org/)

---

**Configuration Location:** `~/dotfiles/config/karabiner/`
**File:** `karabiner.json` (4,964 lines)
**Symlinked To:** `~/.config/karabiner/`
**Backup Directory:** `automatic_backups/` (auto-created by Karabiner)
