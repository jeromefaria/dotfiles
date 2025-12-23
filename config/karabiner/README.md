# Karabiner-Elements Configuration

## Overview

This directory contains configuration for [Karabiner-Elements](https://karabiner-elements.pqrs.org/), a powerful keyboard customizer for macOS.

## Files

### `karabiner.json` (259KB)

**Status:** ✅ Intentionally tracked in git

This is the main configuration file for Karabiner-Elements. While large (5,111 lines), this is **expected and normal** due to the complex keyboard modifications implemented.

**Why is it so large?**
- Contains 13 complex modification rules
- Implements full Vim mode emulation (11 rules)
- Tmux prefix mode integration (2 rules)
- Each Vim action requires detailed manipulator definitions

**File Structure:**
```json
{
  "profiles": [{
    "complex_modifications": {
      "rules": [
        "Tmux Prefix Mode [caps_lock]",
        "Tmux Prefix Mode [ctrl+B]",
        "Vim mode (11 rules total)"
      ]
    }
  }]
}
```

### Modification Rules Included

1. **Tmux Integration**
   - caps_lock as Tmux prefix key
   - ctrl+B as alternative prefix

2. **Vim Mode (11-part implementation)**
   - Activation: caps_lock or j+k
   - Navigation: h,j,k,l,e,b,0,^,$,gg,G,{,}
   - Visual mode, delete, yank, change operations
   - Insert modes, undo/redo, paste

## Management

### Editing Configuration

**Via Karabiner-Elements UI (Recommended):**
1. Open Karabiner-Elements  
2. Go to "Complex Modifications" tab
3. Modify rules through the UI
4. Changes auto-save to karabiner.json

## Git Management

**Why track this large file?**
- ✅ Preserves custom keyboard configuration
- ✅ Version control for complex rules
- ✅ Easy restore on new machines
- ✅ User configuration, not auto-generated

**File size is expected** - 259KB for complex Vim mode rules is normal.
