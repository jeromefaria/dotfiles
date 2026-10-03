#!/bin/bash
# ============================================================================
# scripts/audio-volume-guard.sh
# ============================================================================
# Guards the /Volumes/Audio mount point against the "squatter directory" bug.
#
# Several plugin vendors keep their libraries on the Audio volume via symlinks
# out of /Library:
#
#   /Library/Arturia                        -> /Volumes/Audio/Audio/Libraries/Arturia
#   /Library/Application Support/Softube    -> /Volumes/Audio/Audio/Libraries/Softube
#   /Library/Application Support/iZotope    -> /Volumes/Audio/Audio/Libraries/iZotope
#
# When an installer runs as root while the volume is unmounted, it follows the
# symlink, macOS silently creates /Volumes/Audio *on the boot disk*, and the
# payload lands on the internal SSD. The real volume can then no longer claim
# its mount point and falls back to "/Volumes/Audio 1", so every symlink above
# resolves to the wrong place until the squatter is removed.
#
# Four states, from st_dev against /Volumes plus the sentinel marker:
#
#   mounted     the real volume is here — sentinel present. Healthy.
#   unverified  something is mounted here but the sentinel is missing, so this
#               may not be the Audio volume at all. Run --init on the real
#               volume once; until then the pre-flight fails closed.
#   squatter    a plain directory on the boot disk — the bug. Blocks mounting.
#   absent      nothing there — volume unplugged. Harmless on its own, but it
#               is the precondition an installer turns into a squatter.
#
# Severity is mode-dependent, because the same state means different things to
# a background watcher and to an about-to-install caller:
#
#   --check    pre-flight for installers: everything but `mounted` fails, since
#              installing in any other state is what causes the damage
#   (default)  background watcher: squatter and unverified notify; `absent`
#              does not, because an unplugged drive is an ordinary daily
#              occurrence and an alert that cries wolf gets dismissed
#
# Configuration lives in audio-volume-guard.conf; environment variables
# override it.
#
# Usage:
#   audio-volume-guard.sh             # watcher mode: notify on squatter/unverified
#   audio-volume-guard.sh --check     # exit 0 healthy / 1 unsafe, no notify
#   audio-volume-guard.sh --repair    # remove the squatter if it is still empty
#   audio-volume-guard.sh --init      # write the sentinel onto the mounted volume
#   audio-volume-guard.sh --status    # human-readable state report
#   audio-volume-guard.sh install     # emit the launchd plist and load it
#   audio-volume-guard.sh uninstall   # unload and delete the plist
# ============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/io.sh
source "${SCRIPT_DIR}/lib/io.sh"
# shellcheck source=lib/launchd-svc.sh
source "${SCRIPT_DIR}/lib/launchd-svc.sh"

CONFIG="${AUDIO_VOLUME_CONFIG:-${SCRIPT_DIR}/audio-volume-guard.conf}"

TUNABLES=(
  AUDIO_VOLUME_MOUNT AUDIO_VOLUME_LABEL AUDIO_VOLUME_SENTINEL
  AUDIO_VOLUME_NOTIFY_ENABLED AUDIO_VOLUME_NOTIFIER_GROUP
  AUDIO_VOLUME_NOTIFY_COOLDOWN_HOURS AUDIO_VOLUME_LOG_DIR
  AUDIO_VOLUME_STATE_DIR AUDIO_VOLUME_LAUNCHD_LABEL
)

# Which tunables arrived from the environment, recorded before the conf runs.
# The conf assigns with `:=`, so afterwards every one of them is set and an
# environment override is no longer distinguishable from a configured default.
ENV_OVERRIDES=()
for tunable in "${TUNABLES[@]}"; do
  [ -n "${!tunable:-}" ] && ENV_OVERRIDES+=("$tunable")
done
unset tunable

# shellcheck disable=SC1090
[ -f "$CONFIG" ] && source "$CONFIG"

# Defaults repeated here so the script still runs if the conf is missing.
MOUNT_POINT="${AUDIO_VOLUME_MOUNT:-/Volumes/Audio}"
VOLUME_LABEL="${AUDIO_VOLUME_LABEL:-Audio}"
SENTINEL="${AUDIO_VOLUME_SENTINEL:-${MOUNT_POINT}/.audio-volume-guard}"
NOTIFY_ENABLED="${AUDIO_VOLUME_NOTIFY_ENABLED:-1}"
NOTIFIER_GROUP="${AUDIO_VOLUME_NOTIFIER_GROUP:-audio-volume-guard}"
COOLDOWN_HOURS="${AUDIO_VOLUME_NOTIFY_COOLDOWN_HOURS:-1}"
LOG_DIR="${AUDIO_VOLUME_LOG_DIR:-${HOME}/Library/Logs/audio-volume-guard}"
STATE_DIR="${AUDIO_VOLUME_STATE_DIR:-${HOME}/Library/Application Support/audio-volume-guard}"

LABEL="${AUDIO_VOLUME_LAUNCHD_LABEL:-com.jeromefaria.audiovolumeguard}"
PLIST="${HOME}/Library/LaunchAgents/${LABEL}.plist"

LOG_FILE="${LOG_DIR}/guard.log"

# Notification delivery outcomes. Distinguishing "failed" from "deliberately
# silenced" matters: only a real delivery may start the cooldown.
readonly NOTIFY_DELIVERED=0
readonly NOTIFY_FAILED=1
readonly NOTIFY_DISABLED=2

DEPENDENT_LINKS=(
  "/Library/Arturia"
  "/Library/Application Support/Softube"
  "/Library/Application Support/iZotope"
)

mkdir -p "$LOG_DIR" "$STATE_DIR" 2>/dev/null || true

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_FILE" 2>/dev/null || true
}

# Post a macOS notification and report whether it actually went out. Prefers
# terminal-notifier so the "Alerts" style toggle in System Settings targets
# only these alerts; falls back to osascript when it's absent or fails.
#
# Returns $NOTIFY_DELIVERED / $NOTIFY_FAILED / $NOTIFY_DISABLED. The caller
# must not treat a failure as delivery — a launchd agent with no GUI session,
# or with notification permission denied, fails here every single time.
notify() {
  [ "$NOTIFY_ENABLED" = "1" ] || return "$NOTIFY_DISABLED"
  local title="$1" message="$2"

  if command -v terminal-notifier >/dev/null 2>&1 \
     && terminal-notifier -title "$title" -message "$message" \
          -group "$NOTIFIER_GROUP" >/dev/null 2>&1; then
    return "$NOTIFY_DELIVERED"
  fi

  local escaped_title="${title//\"/\\\"}" escaped_message="${message//\"/\\\"}"
  if osascript -e "display notification \"${escaped_message}\" with title \"${escaped_title}\"" >/dev/null 2>&1; then
    return "$NOTIFY_DELIVERED"
  fi

  return "$NOTIFY_FAILED"
}

# Echo one of: mounted | unverified | squatter | absent
#
# A mounted filesystem has a different device id from the directory it is
# mounted under; a plain directory shares /Volumes' device id. That comparison
# separates "something is mounted here" from "something is squatting on the
# mount point". The sentinel then separates the real volume from any other
# filesystem that happens to be mounted at the same path.
volume_state() {
  [ -e "$MOUNT_POINT" ] || { echo "absent"; return; }

  local parent_device mount_device
  parent_device="$(stat -f '%d' "$(dirname "$MOUNT_POINT")" 2>/dev/null)"
  mount_device="$(stat -f '%d' "$MOUNT_POINT" 2>/dev/null)"

  if [ "$parent_device" = "$mount_device" ]; then
    echo "squatter"
  elif [ -e "$SENTINEL" ]; then
    echo "mounted"
  else
    echo "unverified"
  fi
}

# Echo one of: empty | occupied | unreadable
#
# Three outcomes rather than a boolean, because "I looked and found data" and
# "I could not look" must not produce the same message. The squatter is created
# by a root installer and can easily be unreadable to this user, in which case
# `find` exits non-zero having printed nothing — reporting that as `occupied`
# would have the watcher assert that data was written when nothing was observed,
# and reporting it as `empty` would invite deleting an installer's payload.
#
# Any output means occupied regardless of exit status; only a silent failure is
# `unreadable`.
squatter_content() {
  local entries status
  entries="$(find "$MOUNT_POINT" -mindepth 1 -print -quit 2>/dev/null)"
  status=$?

  if [ -n "$entries" ]; then
    echo "occupied"
  elif [ "$status" -ne 0 ]; then
    echo "unreadable"
  else
    echo "empty"
  fi
}

# `du -sh` right-pads its size column, and prints nothing at all when it is
# denied access, so trim and supply a fallback rather than interpolating an
# empty string into user-facing text.
squatter_size() {
  local size
  size="$(du -sh "$MOUNT_POINT" 2>/dev/null | awk '{print $1}')"
  printf '%s' "${size:-an undetermined amount}"
}

cmd_check() {
  local state
  state="$(volume_state)"

  case "$state" in
    mounted)
      log "check: healthy — ${VOLUME_LABEL} mounted at ${MOUNT_POINT}"
      return 0
      ;;
    squatter)
      print_error "${MOUNT_POINT} is a plain directory on the boot disk, not the ${VOLUME_LABEL} volume."
      print_info "Installers writing through /Library symlinks would land on the internal SSD."
      print_info "Run: $(basename "$0") --repair"
      log "check: FAIL — squatter directory at ${MOUNT_POINT}"
      return 1
      ;;
    unverified)
      print_error "Something is mounted at ${MOUNT_POINT}, but it is not identifiable as the ${VOLUME_LABEL} volume."
      print_info "The sentinel ${SENTINEL} is missing."
      print_info "If this is the right volume, run: $(basename "$0") --init"
      log "check: FAIL — unverified mount at ${MOUNT_POINT} (no sentinel)"
      return 1
      ;;
    absent)
      print_error "The ${VOLUME_LABEL} volume is not mounted at ${MOUNT_POINT}."
      print_info "Installing now would silently create a squatter directory on the boot disk."
      print_info "Mount the volume first, then retry."
      log "check: FAIL — ${MOUNT_POINT} absent"
      return 1
      ;;
    *)
      # Unreachable today, but this is the one function that must fail closed:
      # a bash `case` with no matching arm exits 0, which would read as "safe
      # to install".
      print_error "Unrecognised volume state: ${state}"
      log "check: FAIL — unrecognised state '${state}'"
      return 1
      ;;
  esac
}

cmd_repair() {
  local state
  state="$(volume_state)"

  if [ "$state" != "squatter" ]; then
    print_info "Nothing to repair (state: ${state})."
    return 0
  fi

  local content
  content="$(squatter_content)"

  if [ "$content" = "occupied" ]; then
    print_error "The squatter at ${MOUNT_POINT} holds $(squatter_size) of data."
    print_warning "Refusing to delete it — that payload exists only here."
    print_info "Merge it onto the ${VOLUME_LABEL} volume first, then delete it by hand:"
    print_info "  rsync -rlptD \"${MOUNT_POINT}/\" \"/Volumes/${VOLUME_LABEL} 1/\""
    log "repair: refused — squatter at ${MOUNT_POINT} is occupied"
    return 1
  fi

  if [ "$content" = "unreadable" ]; then
    print_error "The squatter at ${MOUNT_POINT} could not be read, so its contents are unknown."
    print_warning "Refusing to delete it — it may hold an installer's payload."
    print_info "Inspect it first:  sudo ls -la \"${MOUNT_POINT}\""
    log "repair: refused — squatter at ${MOUNT_POINT} is unreadable"
    return 1
  fi

  if rmdir "$MOUNT_POINT" 2>/dev/null; then
    print_success "Removed the empty squatter at ${MOUNT_POINT}."
    log "repair: removed empty squatter at ${MOUNT_POINT}"
    return 0
  fi

  print_error "Could not remove ${MOUNT_POINT} — it is owned by root."
  print_info "Run: sudo rmdir \"${MOUNT_POINT}\""
  log "repair: rmdir failed (needs root) at ${MOUNT_POINT}"
  return 1
}

# Write the mount-gate marker onto whatever is mounted right now. Deliberately
# manual: the whole point of the sentinel is that *you* confirmed this is the
# real volume, so the guard must never place it automatically.
cmd_init() {
  local state
  state="$(volume_state)"

  case "$state" in
    mounted)
      print_info "Sentinel already present at ${SENTINEL}."
      return 0
      ;;
    unverified) ;;
    *)
      print_error "Cannot write the sentinel — state is ${state}, nothing is mounted at ${MOUNT_POINT}."
      return 1
      ;;
  esac

  if ! cat > "$SENTINEL" <<EOF
Mount-gate marker for audio-volume-guard.sh.

Its presence identifies this filesystem as the ${VOLUME_LABEL} volume, so the
guard can tell the real drive from any other volume that happens to be mounted
at ${MOUNT_POINT}. Safe to delete; re-create with: audio-volume-guard.sh --init
EOF
  then
    print_error "Could not write ${SENTINEL}."
    return 1
  fi

  print_success "Sentinel written to ${SENTINEL}."
  log "init: sentinel written to ${SENTINEL}"
}

# Watcher mode. A squatter or an unidentifiable mount is worth interrupting the
# user for; an unplugged drive is not, and notifying on it would train the user
# to dismiss the alert that actually matters.
cmd_notify() {
  local state message
  state="$(volume_state)"

  case "$state" in
    squatter)
      case "$(squatter_content)" in
        empty)
          message="An empty directory is blocking ${MOUNT_POINT}. Remove it before the ${VOLUME_LABEL} volume can mount."
          ;;
        occupied)
          message="$(squatter_size) was written to ${MOUNT_POINT} on the boot disk instead of the ${VOLUME_LABEL} volume."
          ;;
        *)
          # Unreadable: say so. Claiming a write here would be asserting
          # something the guard never managed to observe.
          message="A directory is blocking ${MOUNT_POINT} and its contents could not be read. The ${VOLUME_LABEL} volume cannot mount until it is checked."
          ;;
      esac
      ;;
    unverified)
      message="An unidentified volume is mounted at ${MOUNT_POINT}. Installers targeting the ${VOLUME_LABEL} library would write to it."
      ;;
    *)
      log "watch: ${state} — no action"
      return 0
      ;;
  esac

  local now notify_marker cooldown_seconds last_notify
  now="$(date +%s)"
  notify_marker="${STATE_DIR}/.last-squatter-notify"
  cooldown_seconds=$(( COOLDOWN_HOURS * 3600 ))
  last_notify=0
  [ -f "$notify_marker" ] && last_notify="$(cat "$notify_marker" 2>/dev/null || true)"
  [[ "$last_notify" =~ ^[0-9]+$ ]] || last_notify=0

  if [ $(( now - last_notify )) -lt "$cooldown_seconds" ]; then
    log "watch: suppressed (cooldown ${COOLDOWN_HOURS}h) — $message"
    return 0
  fi

  # Only a delivered notification starts the cooldown. Stamping the marker on a
  # failed delivery would swallow the next window of real alerts while the log
  # claimed the user had been warned.
  notify "${VOLUME_LABEL} volume mount blocked" "$message"
  case "$?" in
    "$NOTIFY_DELIVERED")
      log "watch: notified — $message"
      echo "$now" > "$notify_marker" 2>/dev/null || true
      ;;
    "$NOTIFY_DISABLED")
      log "watch: notifications disabled, cooldown not started — $message"
      ;;
    *)
      log "watch: delivery FAILED, cooldown not started — $message"
      ;;
  esac
}

cmd_status() {
  local state
  state="$(volume_state)"

  print_header "Audio volume guard"

  case "$state" in
    mounted)
      print_success "${VOLUME_LABEL} volume mounted at ${MOUNT_POINT}"
      ;;
    unverified)
      print_warning "Unidentified volume at ${MOUNT_POINT} — sentinel missing (${SENTINEL})"
      ;;
    squatter)
      case "$(squatter_content)" in
        empty)    print_error "Empty directory squatting on ${MOUNT_POINT} (blocks mounting)" ;;
        occupied) print_error "Squatter directory at ${MOUNT_POINT} ($(squatter_size) on the boot disk)" ;;
        *)        print_error "Squatter directory at ${MOUNT_POINT} (unreadable — contents unknown)" ;;
      esac
      ;;
    absent)
      print_warning "${VOLUME_LABEL} volume not mounted (${MOUNT_POINT} absent)"
      ;;
  esac

  echo ""
  print_info "Dependent symlinks:"

  local link
  for link in "${DEPENDENT_LINKS[@]}"; do
    if [ ! -L "$link" ]; then
      print_warning "  ${link} — not a symlink"
      continue
    fi

    # `-e` resolves *through* a squatter, so a link pointing at the boot disk
    # would read as healthy in exactly the state this tool exists to detect.
    # Health is therefore reported against the volume state, not the link.
    case "$state" in
      mounted)
        if [ -e "$link" ]; then
          print_success "  ${link}"
        else
          print_error "  ${link} — dangling"
        fi
        ;;
      squatter)
        print_error "  ${link} — resolving onto the boot disk via the squatter"
        ;;
      unverified)
        print_warning "  ${link} — resolving onto an unidentified volume"
        ;;
      absent)
        print_error "  ${link} — dangling (volume not mounted)"
        ;;
    esac
  done

  echo ""
  if [ -f "$PLIST" ] && svc_is_loaded "$LABEL"; then
    print_success "Watcher loaded (${LABEL})"
  elif [ -f "$PLIST" ]; then
    print_warning "Plist present but not loaded (${LABEL})"
  else
    print_info "Watcher not installed — run: $(basename "$0") install"
  fi
}

# WatchPaths on /Volumes fires whenever a directory entry there changes, so the
# guard runs the moment a squatter appears — while it is still empty and cheap
# to remove — rather than after an installer has filled it.
#
# The agent is handed the config path, not the resolved values: the conf stays
# the single source of truth, so editing it does not require reinstalling.
emit_plist() {
  mkdir -p "$(dirname "$PLIST")" "$LOG_DIR"
  cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${LABEL}</string>

  <key>ProgramArguments</key>
  <array>
    <string>${SCRIPT_DIR}/audio-volume-guard.sh</string>
  </array>

  <key>WatchPaths</key>
  <array>
    <string>$(dirname "$MOUNT_POINT")</string>
  </array>

  <key>RunAtLoad</key>
  <true/>

  <key>StandardOutPath</key>
  <string>${LOG_DIR}/launchd.out.log</string>
  <key>StandardErrorPath</key>
  <string>${LOG_DIR}/launchd.err.log</string>

  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    <key>AUDIO_VOLUME_CONFIG</key>
    <string>${CONFIG}</string>
  </dict>
</dict>
</plist>
EOF
}

cmd_install() {
  # The agent inherits only $CONFIG and the watched path. Any other override
  # active in this shell is dropped, which would leave an agent guarding
  # something other than what the operator just configured.
  if [ ${#ENV_OVERRIDES[@]} -gt 0 ]; then
    print_warning "These environment overrides are not carried into the plist:"
    print_info "  ${ENV_OVERRIDES[*]}"
    print_info "The agent reads ${CONFIG} — put lasting changes there instead."
  fi

  print_step "Emitting plist at ${PLIST}"
  emit_plist

  if svc_start "$PLIST" "$LABEL"; then
    print_success "Watcher loaded (${LABEL})"
  else
    print_error "Plist emitted but launchd did not load it"
    return 1
  fi

  [ "$(volume_state)" = "unverified" ] \
    && print_warning "Sentinel missing — run '$(basename "$0") --init' with the ${VOLUME_LABEL} volume mounted"

  return 0
}

cmd_uninstall() {
  if [ ! -f "$PLIST" ]; then
    print_info "Not installed (no plist at ${PLIST})"
    return 0
  fi

  svc_stop "$PLIST" "$LABEL" || true
  print_step "Removing plist"
  rm -f "$PLIST"
  print_success "Watcher removed"
}

# Reprint the usage block from the header comment. The range stops *before*
# the closing rule so the dump doesn't trail a bare row of '=' characters.
show_usage() {
  awk '
    /^# Usage:/      { inside = 1 }
    inside && /^# ={10,}/ { exit }
    inside           { sub(/^# ?/, ""); print }
  ' "$0"
}

case "${1:-}" in
  --check)    cmd_check ;;
  --repair)   cmd_repair ;;
  --init)     cmd_init ;;
  --status)   cmd_status ;;
  install)    cmd_install ;;
  uninstall)  cmd_uninstall ;;
  "")         cmd_notify ;;
  -h|--help)  show_usage ;;
  *)
    print_error "Unknown option: $1"
    show_usage
    exit 1
    ;;
esac
