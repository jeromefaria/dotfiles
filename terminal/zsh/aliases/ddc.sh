# ============================================================================
# DDC/CI Display Input Switching for Dell U2515H Monitors (via DisplayLink)
# ============================================================================
# ⚠️  IMPORTANT: DisplayLink does NOT support DDC/CI on macOS!
# These aliases will NOT work with the UGREEN Revodok Pro 209 dock.
#
# SOLUTION FOR PS5 (Left Monitor):
#   Use an auto-switching HDMI switch since your Elgato 4K S passthrough
#   stops outputting when PS5 is off. Recommended:
#   - OREI 8K 2x1 HDMI Switch (~$35) - supports 4K@120Hz
#   - Fosmon 3-Port HDMI Switch (~$20) - supports 4K@60Hz
#
#   Setup: Mac (DP) + PS5 (via Elgato) → HDMI Switch → Monitor HDMI 2
#   When PS5 turns on, switch auto-detects and switches input!
#
# FUTURE SOLUTION (All Monitors):
#   Upgrade to a Thunderbolt dock (CalDigit TS4, OWC, etc.) to enable
#   native DisplayPort Alt Mode. Then these aliases will work!
#
# Physical Setup (DisplayLink has them flipped!):
#   LEFT Physical Monitor (PS5 via Elgato 4K S) → Display 1 (ID #14)
#   RIGHT Physical Monitor (Windows) → Display 2 (ID #13)
#   Both monitors → DisplayPort: M1 MacBook Pro via UGREEN Revodok Pro 209
#
# Network Monitoring (Available Now):
#   ps5-status    - Check if PS5 is on (IP: 192.168.1.249)
#   ps5-watch     - Monitor PS5 and get notifications
#
# Input source codes for Dell U2515H:
#   15 = DisplayPort (Mac via DisplayLink)
#   17 = HDMI 1 (MHL)
#   18 = HDMI 2 (may vary - try 16 or 19 if it doesn't work)
#
# Usage:
#   mac / windows / ps5  - Switch both/specific monitors to Mac/Windows/PS5
#   left-mac / right-mac - Switch left/right monitor to Mac
#   left-hdmi / right-hdmi - Switch left/right monitor to HDMI (PS5/Windows)
#   dp / hdmi            - Switch both monitors to DisplayPort/HDMI
#   dp1 / hdmi1          - Switch display 1 (left physical) to DP/HDMI
#   dp2 / hdmi2          - Switch display 2 (right physical) to DP/HDMI
#   test-hdmi2 <display#> - Test which HDMI 2 code works (16, 18, or 19)
#   ddc-enable-permissions - Open Screen Recording permissions settings
# ============================================================================

# ============================================================================
# Intuitive Aliases (Recommended)
# ============================================================================

# Switch to Mac on both monitors (DisplayPort via DisplayLink)
alias mac='ddcctl -d 1 -i 15 && ddcctl -d 2 -i 15 && echo "Both monitors → Mac"'

# Switch to Windows laptop (right monitor only)
alias windows='ddcctl -d 2 -i 18 && echo "Right monitor → Windows"'

# Switch to PlayStation 5 (left monitor only)
alias ps5='ddcctl -d 1 -i 18 && echo "Left monitor → PlayStation 5"'

# Left monitor (Display 1 - PS5)
alias left-mac='ddcctl -d 1 -i 15 && echo "Left monitor → Mac"'
alias left-hdmi='ddcctl -d 1 -i 18 && echo "Left monitor → PlayStation 5"'

# Right monitor (Display 2 - Windows)
alias right-mac='ddcctl -d 2 -i 15 && echo "Right monitor → Mac"'
alias right-hdmi='ddcctl -d 2 -i 18 && echo "Right monitor → Windows"'

# ============================================================================
# Generic Aliases (both monitors)
# ============================================================================

# Switch both monitors to DisplayPort (Mac)
alias dp='ddcctl -d 1 -i 15 && ddcctl -d 2 -i 15 && echo "Both monitors → DisplayPort (Mac)"'

# Switch both monitors to HDMI 2
alias hdmi='ddcctl -d 1 -i 18 && ddcctl -d 2 -i 18 && echo "Both monitors → HDMI 2 (Left:PS5 + Right:Windows)"'

# ============================================================================
# Display Number Aliases (for reference)
# ============================================================================

# Display 1 (LEFT physical monitor - PS5)
alias dp1='ddcctl -d 1 -i 15 && echo "Display 1 (left physical) → DisplayPort"'
alias hdmi1='ddcctl -d 1 -i 18 && echo "Display 1 (left physical) → HDMI 2 (PS5)"'

# Display 2 (RIGHT physical monitor - Windows)
alias dp2='ddcctl -d 2 -i 15 && echo "Display 2 (right physical) → DisplayPort"'
alias hdmi2='ddcctl -d 2 -i 18 && echo "Display 2 (right physical) → HDMI 2 (Windows)"'

# Helper function to open Screen Recording permissions
ddc-enable-permissions() {
  echo "Opening Screen Recording permissions..."
  echo "Enable your terminal app in the list, then restart your terminal."
  open "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"
}

# Test function to find the correct HDMI 2 input code
# Usage: test-hdmi2 1  (tests display 1)
test-hdmi2() {
  if [[ -z "$1" ]]; then
    echo "Usage: test-hdmi2 <display-number>"
    echo "Example: test-hdmi2 1"
    return 1
  fi

  local display="$1"
  echo "Testing HDMI 2 input codes on display $display..."
  echo "Watch your monitor to see which one switches to HDMI 2"
  echo ""

  for code in 16 18 19; do
    echo "Testing code $code..."
    ddcctl -d "$display" -i "$code" 2>/dev/null
    sleep 3
    echo "Did it switch to HDMI 2? (Press Enter to continue)"
    read
  done

  echo ""
  echo "Done! Update the aliases in ddc.sh with the working code."
}

# Verify permissions before running DDC commands
_check_ddc_permissions() {
  if ! ddcctl -d 1 2>&1 | grep -q "Failed to acquire framebuffer"; then
    return 0
  else
    echo "ERROR: Screen Recording permission required!"
    echo "Run: ddc-enable-permissions"
    return 1
  fi
}
