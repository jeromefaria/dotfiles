#!/bin/bash
# Audio drive → Google Drive sync (one-shot).
#
# Idempotent. Safe to run from launchd or manually. Respects all gates
# (source mounted, SSID allowlist, hotspot detection) by default.
#
# Usage:
#   audio-backup-sync.sh                  # default: run with all gates
#   audio-backup-sync.sh --dry-run        # preview rclone transfer, no writes
#   audio-backup-sync.sh --force          # bypass SSID + hotspot gates (still warns on hotspot)
#   audio-backup-sync.sh --force --yes    # bypass + skip warn (caution: burns hotspot data)
#   audio-backup-sync.sh --bwlimit 50M    # override bandwidth cap
#
# Exit codes:
#   0  = sync ran successfully, OR gate failed cleanly (treated as no-op)
#   1  = config / setup error
#   2+ = rclone failure (propagated)

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${AUDIO_BACKUP_CONFIG:-${SCRIPT_DIR}/audio-backup.conf}"

if [ ! -f "$CONFIG" ]; then
  echo "ERROR: config not found at $CONFIG" >&2
  exit 1
fi
# shellcheck disable=SC1090
source "$CONFIG"

# ─── Colors (TTY only) — provided by lib/io.sh ─────────────────────────
source "${SCRIPT_DIR}/lib/io.sh"

# ─── Args ──────────────────────────────────────────────────────────────
DRY_RUN=0
FORCE=0
SKIP_WARN=0
BWLIMIT_OVERRIDE=""

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run)        DRY_RUN=1; shift ;;
    --force)          FORCE=1; shift ;;
    --yes|-y)         SKIP_WARN=1; shift ;;
    --bwlimit)        BWLIMIT_OVERRIDE="$2"; shift 2 ;;
    --bwlimit=*)      BWLIMIT_OVERRIDE="${1#*=}"; shift ;;
    -h|--help)
      awk 'NR==1{next} /^#/{sub(/^# ?/,""); print; next} /^[[:space:]]*$/{next} {exit}' "$0"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

# ─── Logging ───────────────────────────────────────────────────────────
mkdir -p "$LOG_DIR" 2>/dev/null || true
LOG_FILE="${LOG_DIR}/$(date "+${LOG_FILE_PATTERN}")"

log() {
  # Both to stdout (color) and to logfile (plain)
  echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $*"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE" 2>/dev/null || true
}

log_warn() {
  echo -e "${YELLOW}[$(date '+%H:%M:%S')] ⚠ $*${NC}"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARN: $*" >> "$LOG_FILE" 2>/dev/null || true
}

log_err() {
  echo -e "${RED}[$(date '+%H:%M:%S')] ✗ $*${NC}" >&2
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >> "$LOG_FILE" 2>/dev/null || true
}

log_ok() {
  echo -e "${GREEN}[$(date '+%H:%M:%S')] ✓ $*${NC}"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] OK: $*" >> "$LOG_FILE" 2>/dev/null || true
}

# ─── Gate 1: source drive mounted ──────────────────────────────────────
if [ ! -f "$SENTINEL" ]; then
  log_warn "Source drive not mounted (sentinel $SENTINEL not found). Skipping."
  exit 0
fi

# ─── Gate 2: trusted-router allowlist + hotspot check ──────────────────
# Network identity is established via the Wi-Fi service's router IP, not
# SSID. On macOS Tahoe (and Sonoma 14.4+) the SSID/BSSID surface is
# redacted by the OS in every user-space API — `ipconfig getsummary` and
# `system_profiler` both literally return "<redacted>" without a Location
# Services entitlement. Router IP, by contrast, is exposed by
# `networksetup -getinfo Wi-Fi` with no permission required. It is also
# VPN-immune (the system default gateway is hijacked by a tunnel; the
# Wi-Fi service router is not).
current_wifi_router() {
  networksetup -getinfo Wi-Fi 2>/dev/null | awk -F': ' '/^Router:/{print $2; exit}'
}

is_trusted_router() {
  local router="$1"
  [ -z "$router" ] && return 1
  for allowed in "${TRUSTED_ROUTER_ALLOWLIST[@]}"; do
    [ "$router" = "$allowed" ] && return 0
  done
  return 1
}

is_hotspot() {
  local router="$1"
  [[ "$router" == ${HOTSPOT_GATEWAY_PATTERN}* ]]
}

WIFI_ROUTER="$(current_wifi_router)"
BWLIMIT="${BWLIMIT_OVERRIDE:-$BWLIMIT_DEFAULT}"

if [ "$FORCE" -eq 0 ]; then
  # Strict gates — used by launchd schedule
  if is_hotspot "$WIFI_ROUTER"; then
    log_warn "iPhone hotspot detected (router $WIFI_ROUTER). Skipping. (Use --force to override.)"
    exit 0
  fi
  if ! is_trusted_router "$WIFI_ROUTER"; then
    log_warn "Router '${WIFI_ROUTER:-<none>}' not in trusted allowlist. Skipping. (Use --force to override.)"
    exit 0
  fi
else
  # Forced — but warn on hotspot unless --yes
  if is_hotspot "$WIFI_ROUTER"; then
    if [ "$SKIP_WARN" -eq 0 ]; then
      echo -e "${RED}WARNING:${NC} iPhone hotspot detected (router $WIFI_ROUTER)."
      echo "  Backup may transfer substantial data over mobile connection."
      echo "  Bandwidth will be capped at $BWLIMIT_FORCE (override with --bwlimit)."
      read -r -p "  Proceed? [y/N]: " ans
      if [[ ! "$ans" =~ ^[Yy]$ ]]; then
        log_warn "User declined hotspot run. Aborting."
        exit 0
      fi
    fi
    BWLIMIT="${BWLIMIT_OVERRIDE:-$BWLIMIT_FORCE}"
    log_warn "Forced run on hotspot. Bandwidth capped at $BWLIMIT."
  elif ! is_trusted_router "$WIFI_ROUTER"; then
    log_warn "Forced run on untrusted router '${WIFI_ROUTER:-<none>}'. Bandwidth capped at $BWLIMIT_FORCE."
    BWLIMIT="${BWLIMIT_OVERRIDE:-$BWLIMIT_FORCE}"
  fi
fi

# ─── Gate 3: filters file present ──────────────────────────────────────
if [ ! -f "$FILTERS_FILE" ]; then
  log_err "Filters file not found at $FILTERS_FILE"
  exit 1
fi

# ─── Gate 4: rclone installed ──────────────────────────────────────────
if ! command -v rclone &> /dev/null; then
  log_err "rclone not installed. Install with: brew install rclone"
  exit 1
fi

# ─── Gate 5: rclone remote configured ──────────────────────────────────
if ! rclone listremotes | grep -q "^${RCLONE_REMOTE}:$"; then
  log_err "rclone remote '${RCLONE_REMOTE}:' not configured. Run: rclone config"
  exit 1
fi

# ─── Concurrency lock (stop a manual run and the nightly run overlapping) ─
LOCK_DIR="${TMPDIR:-/tmp}/audio-backup.lock"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  log_warn "Another audio-backup run already holds the lock ($LOCK_DIR). Skipping."
  exit 0
fi
trap 'rmdir "$LOCK_DIR" 2>/dev/null' EXIT

# ─── Run rclone ────────────────────────────────────────────────────────
DEST="${RCLONE_REMOTE}:${RCLONE_DEST_PATH}"
VERSIONS_DEST="${RCLONE_REMOTE}:${RCLONE_VERSIONS_PATH}/$(date +%Y-%m-%d)"

log "Source: $SOURCE"
log "Dest:   $DEST"
log "Router: ${WIFI_ROUTER:-<none>}"
log "BW:     $BWLIMIT"
log "Filters: $FILTERS_FILE"

# 'sync' mirrors SOURCE→DEST so source deletions/reorgs propagate; --backup-dir
# first MOVES every overwritten/deleted file into the dated versions folder, so
# the mirror stays clean while nothing is ever actually lost.
RCLONE_ARGS=(
  sync "$SOURCE" "$DEST"
  --filter-from "$FILTERS_FILE"
  --backup-dir "$VERSIONS_DEST"
  --bwlimit "$BWLIMIT"
  --log-file "$LOG_FILE"
  --log-level INFO
  --transfers 4
  --checkers 8
)

# Live progress bar on a TTY; periodic one-line stats when unattended (launchd),
# so the logfile gets heartbeats instead of thousands of progress redraws.
if [ -t 1 ]; then
  RCLONE_ARGS+=(--progress)
else
  RCLONE_ARGS+=(--stats 30s --stats-one-line)
fi

if [ "$DRY_RUN" -eq 1 ]; then
  log "DRY-RUN — no writes"
  RCLONE_ARGS+=(--dry-run)
fi

log "Starting rclone..."
if rclone "${RCLONE_ARGS[@]}"; then
  log_ok "Sync complete"
  exit 0
else
  rc=$?
  log_err "rclone exited $rc"
  exit "$rc"
fi
