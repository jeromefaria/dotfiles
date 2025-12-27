#!/usr/bin/env bash
#
# Musikcube Now Playing - Tmux Status Bar Integration
# Queries musikcube websocket API to display currently playing track
#
# Usage: Called automatically by tmux status bar via:
#   set -g status-right '... #(~/.tmux/musikcube-now-playing.sh) ...'
#
# Requirements:
#   - musikcube running on port 7905
#   - websocat for websocket communication
#
# Output:
#   "♫ Artist - Title" when playing
#   "⏸ Artist - Title" when paused
#   "" (empty) when stopped or not running
#

set -o pipefail

WS_URL="ws://localhost:7905"
TIMEOUT=2

# Check if musikcube is running
if ! lsof -i :7905 >/dev/null 2>&1; then
    echo ""
    exit 0
fi

# Generate unique IDs for the request
REQUEST_ID="tmux-$(date +%s)"
DEVICE_ID="tmux-statusbar"

# Authentication message (with empty password - musikcube's default)
# Must be single-line JSON for websocket
AUTH_MSG="{\"name\":\"authenticate\",\"type\":\"request\",\"id\":\"${REQUEST_ID}-auth\",\"device_id\":\"${DEVICE_ID}\",\"options\":{\"password\":\"\"}}"

# Get playback overview message
PLAYBACK_MSG="{\"name\":\"get_playback_overview\",\"type\":\"request\",\"id\":\"${REQUEST_ID}-playback\",\"device_id\":\"${DEVICE_ID}\",\"options\":{}}"

# Connect to websocket, send auth and playback request, then extract info
RESPONSE=$(
    {
        echo "$AUTH_MSG"
        sleep 0.1
        echo "$PLAYBACK_MSG"
        sleep 0.3
    } | timeout ${TIMEOUT} websocat -n "$WS_URL" 2>&1
)

# Parse the response to extract artist and title
# The response should contain a "playing_track" object with title and artist
if [ -n "$RESPONSE" ]; then
    # Check if playback is actually active
    # state values: "stopped", "playing", "paused"
    STATE=$(echo "$RESPONSE" | grep -o '"state":"[^"]*"' | tail -1 | sed 's/"state":"\(.*\)"/\1/')

    if [ "$STATE" = "stopped" ] || [ -z "$STATE" ]; then
        echo ""
    else
        # Try to extract title and artist from the JSON response
        # Using grep and sed for simple JSON parsing
        TITLE=$(echo "$RESPONSE" | grep -o '"title":"[^"]*"' | tail -1 | sed 's/"title":"\(.*\)"/\1/')
        ARTIST=$(echo "$RESPONSE" | grep -o '"album_artist":"[^"]*"' | tail -1 | sed 's/"album_artist":"\(.*\)"/\1/')

        # Fallback to regular artist if album_artist is empty
        if [ -z "$ARTIST" ]; then
            ARTIST=$(echo "$RESPONSE" | grep -o '"artist":"[^"]*"' | tail -1 | sed 's/"artist":"\(.*\)"/\1/')
        fi

        if [ -n "$TITLE" ]; then
            # Show pause indicator if paused
            if [ "$STATE" = "paused" ]; then
                INDICATOR="⏸"
            else
                INDICATOR="♫"
            fi

            if [ -n "$ARTIST" ]; then
                # Limit length to prevent status bar overflow
                OUTPUT="${INDICATOR} ${ARTIST} - ${TITLE}"
                if [ ${#OUTPUT} -gt 50 ]; then
                    OUTPUT="${OUTPUT:0:47}..."
                fi
                echo "$OUTPUT"
            else
                OUTPUT="${INDICATOR} ${TITLE}"
                if [ ${#OUTPUT} -gt 50 ]; then
                    OUTPUT="${OUTPUT:0:47}..."
                fi
                echo "$OUTPUT"
            fi
        else
            echo ""
        fi
    fi
else
    echo ""
fi
