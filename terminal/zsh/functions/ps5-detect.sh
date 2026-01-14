#!/bin/zsh
# ============================================================================
# PS5 Network Detection Helper
# ============================================================================
# Detects when PS5 is turned on/off by monitoring network connectivity
# Can be used to trigger notifications or other actions
#
# Usage:
#   ps5-watch          - Monitor PS5 status (runs in foreground)
#   ps5-status         - Check if PS5 is currently on
#   ps5-ip             - Get PS5 IP address
#
# Setup:
#   1. Set your PS5's IP address below (find it in PS5 Settings > Network)
#   2. Optionally set up static IP for PS5 in your router
# ============================================================================

# CONFIGURATION - Update this with your PS5's IP address
PS5_IP="${PS5_IP:-192.168.1.249}"  # PS5 IP address

# Check if PS5 is currently reachable
ps5-status() {
  if ping -c 1 -W 1 "$PS5_IP" &>/dev/null; then
    echo "✅ PS5 is ON (reachable at $PS5_IP)"
    return 0
  else
    echo "❌ PS5 is OFF (not reachable at $PS5_IP)"
    return 1
  fi
}

# Display PS5 IP
ps5-ip() {
  echo "$PS5_IP"
}

# Monitor PS5 status and show notifications when state changes
ps5-watch() {
  local was_on=false
  echo "👀 Monitoring PS5 at $PS5_IP (Ctrl+C to stop)..."
  echo ""

  while true; do
    if ping -c 1 -W 1 "$PS5_IP" &>/dev/null; then
      if [[ "$was_on" == "false" ]]; then
        local timestamp=$(date "+%H:%M:%S")
        echo "[$timestamp] 🎮 PS5 turned ON!"

        # macOS notification
        osascript -e 'display notification "PS5 is now on" with title "🎮 PlayStation 5"' 2>/dev/null

        # TODO: Add monitor switching command here when you upgrade to Thunderbolt dock
        # ddcctl -d 1 -i 18  # Switch left monitor to HDMI (PS5)

        was_on=true
      fi
    else
      if [[ "$was_on" == "true" ]]; then
        local timestamp=$(date "+%H:%M:%S")
        echo "[$timestamp] 💤 PS5 turned OFF"

        # macOS notification
        osascript -e 'display notification "PS5 is now off" with title "🎮 PlayStation 5"' 2>/dev/null

        # TODO: Add monitor switching command here when you upgrade to Thunderbolt dock
        # ddcctl -d 1 -i 15  # Switch left monitor to DisplayPort (Mac)

        was_on=false
      fi
    fi

    sleep 2  # Check every 2 seconds
  done
}
