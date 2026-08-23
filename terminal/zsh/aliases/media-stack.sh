#!/usr/bin/env zsh
# Media automation stack (Plex + *arr, Dockerised via Colima) — single `plex` command.
# Full reference: ~/dotfiles/docs/media-stack.md · `plex help` lists all subcommands.
# Secrets stay in ~/plex-stack/{.env,.qb-credentials,.arr-credentials} (gitignored),
# read at runtime — never embedded here.

export PLEX_STACK="$HOME/plex-stack"

# ---- internal helpers (prefixed _plex_) ----------------------------------

_plex_boot() {
  echo "starting Colima…"
  brew services start colima >/dev/null 2>&1            # (re)registers login auto-start + starts
  printf "waiting for Docker"
  for i in {1..40}; do docker info >/dev/null 2>&1 && break; printf "."; sleep 3; done
  docker info >/dev/null 2>&1 || { echo " — Docker not ready; try 'colima start' manually"; return 1; }
  echo " ok"
  ( cd "$PLEX_STACK" && docker compose up -d )
  printf "waiting for gluetun (VPN) to be healthy"
  for i in {1..25}; do
    [ "$(docker inspect --format '{{.State.Health.Status}}' gluetun 2>/dev/null)" = "healthy" ] && break
    printf "."; sleep 3
  done
  echo " ok"
  docker restart qbittorrent >/dev/null 2>&1            # fresh tunnel ⇒ qB needs a reconnect
  echo "stack up. run 'plex health' in ~30s to confirm downloads resumed."
}

_plex_halt() {
  echo "stopping stack (gracefully — Bazarr may take up to 60s)…"
  ( cd "$PLEX_STACK" && docker compose stop )
  echo "stopping Colima…"
  brew services stop colima >/dev/null 2>&1             # remove the KeepAlive agent first…
  colima stop >/dev/null 2>&1                           # …then stop the VM (now safe — no agent to fight it)
  echo "everything stopped (login auto-start disabled). bring it back with: plex boot"
}

_plex_health() {
  echo "gluetun:  $(docker inspect --format '{{.State.Health.Status}}' gluetun 2>/dev/null || echo down)"
  local pw; pw=$(sed -n 's/^password: //p' "$PLEX_STACK/.qb-credentials" 2>/dev/null)
  python3 - "$pw" <<'PY'
import sys, json, urllib.request, urllib.parse, http.cookiejar
pw = sys.argv[1] if len(sys.argv) > 1 else ""
QB = "http://localhost:8080"
jar = http.cookiejar.CookieJar(); op = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(jar))
try:
    op.open(urllib.request.Request(QB + "/api/v2/auth/login",
            data=urllib.parse.urlencode({"username": "admin", "password": pw}).encode(),
            headers={"Referer": QB}), timeout=6)
    info = json.loads(op.open(QB + "/api/v2/transfer/info").read())
    tor = json.loads(op.open(QB + "/api/v2/torrents/info").read())
    inc = [t for t in tor if t["progress"] < 1]
    live = [t for t in inc if t.get("num_complete", 0) > 0]
    print(f"qb:       {info.get('connection_status')} | DL {round(info.get('dl_info_speed',0)/1e6,2)}MB/s")
    print(f"torrents: {len(tor)} total | {len(inc)} incomplete ({len(live)} with seeders, {len(inc)-len(live)} dead → Decluttarr cleans these)")
except Exception as e:
    print(f"qb:       unreachable ({e})")
PY
}

_plex_autostart() {
  # Login auto-start = presence of the Colima brew LaunchAgent plist (RunAtLoad),
  # which is the true "will it start at next login" signal — independent of whether
  # Colima happens to be running right now.
  local plist="$HOME/Library/LaunchAgents/homebrew.mxcl.colima.plist"
  case "$1" in
    on)  brew services start colima >/dev/null 2>&1 && echo "auto-start ENABLED — the stack comes up at each login";;
    off) brew services stop colima >/dev/null 2>&1; colima stop >/dev/null 2>&1; echo "auto-start DISABLED (Colima also stopped — restart with: plex boot)";;
    status|"") [ -f "$plist" ] && echo "auto-start: ENABLED" || echo "auto-start: DISABLED";;
    *) echo "usage: plex autostart on|off|status";;
  esac
}

_plex_web() {
  local -A ports=(plex 32400 radarr 7878 sonarr 8989 prowlarr 9696 bazarr 6767 qbit 8080 overseerr 5055)
  local p=${ports[$1]}
  [ -n "$p" ] || { echo "usage: plex web {plex|radarr|sonarr|prowlarr|bazarr|qbit|overseerr}"; return 1; }
  [ "$1" = plex ] && open "http://localhost:$p/web" || open "http://localhost:$p"
}

_plex_help() {
  cat <<'EOF'
plex — media automation stack control (full docs: ~/dotfiles/docs/media-stack.md)

  Lifecycle
    plex boot              start Colima + stack, wait for VPN, reconnect qBittorrent
    plex halt              gracefully stop the stack + Colima
    plex up | down         start / stop containers (Colima left running)
    plex restart <svc>     restart one container (e.g. plex restart radarr)

  Status
    plex status            health overview of all stack containers
    plex health            torrent-client + VPN snapshot (dead vs seeded)
    plex vpn               gluetun's NordVPN exit IP (torrent privacy check)
    plex logs [svc]        follow logs — all, or one service
    plex ts                Tailscale status (remote access)

  Maintenance
    plex update            pull latest images + recreate
    plex autostart on|off|status   toggle login auto-start

  Fixes (runbooks — see docs)
    plex fix qb            all torrents 0 seeds at once ⇒ restart qBittorrent
    plex fix sonarr        new series stuck at 0 episodes ⇒ restart Sonarr
    plex fix ts-dns        remote access/DNS broke ⇒ Tailscale accept-dns=false

  Web UIs
    plex web <svc>         open a UI (plex|radarr|sonarr|prowlarr|bazarr|qbit|overseerr)
EOF
}

# ---- dispatcher ----------------------------------------------------------

plex() {
  local cmd="$1"; [ $# -gt 0 ] && shift
  case "$cmd" in
    boot)     _plex_boot ;;
    halt)     _plex_halt ;;
    up)       ( cd "$PLEX_STACK" && docker compose up -d ) ;;
    down)     ( cd "$PLEX_STACK" && docker compose down ) ;;
    restart)  docker restart "${1:?usage: plex restart <service>}" ;;
    status)   docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "radarr|sonarr|prowlarr|bazarr|qbittorrent|gluetun|overseerr|decluttarr|flaresolverr|rarbg" || echo "stack not running (try: plex boot)" ;;
    health)   _plex_health ;;
    vpn)      docker exec gluetun sh -c "wget -qO- -T8 https://ipinfo.io/json" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('ip'),'|',d.get('org'),'|',d.get('city'),d.get('country'))" ;;
    logs)     if [ -n "$1" ]; then docker logs -f --tail 50 "$1"; else ( cd "$PLEX_STACK" && docker compose logs -f --tail 50 ); fi ;;
    update)   ( cd "$PLEX_STACK" && docker compose pull && docker compose up -d ) ;;
    autostart) _plex_autostart "$1" ;;
    ts)       /Applications/Tailscale.app/Contents/MacOS/Tailscale status ;;
    fix)      case "$1" in
                qb)     docker restart qbittorrent ;;
                sonarr) docker restart sonarr ;;
                ts-dns) /Applications/Tailscale.app/Contents/MacOS/Tailscale set --accept-dns=false && echo "Tailscale accept-dns disabled" ;;
                *) echo "usage: plex fix qb|sonarr|ts-dns" ;;
              esac ;;
    web)      _plex_web "$1" ;;
    help|"")  _plex_help ;;
    *)        echo "plex: unknown command '$cmd'"; _plex_help ;;
  esac
}

# ---- zsh tab-completion for subcommands ----------------------------------
_plex_complete() {
  local -a cmds
  cmds=(boot halt up down restart status health vpn logs update autostart ts fix web help)
  if (( CURRENT == 2 )); then _describe 'command' cmds
  elif (( CURRENT == 3 )); then
    case "${words[2]}" in
      autostart) _describe 'option' '(on off status)' ;;
      fix)       _describe 'fix' '(qb sonarr ts-dns)' ;;
      web)       _describe 'service' '(plex radarr sonarr prowlarr bazarr qbit overseerr)' ;;
      restart|logs) _describe 'service' '(radarr sonarr prowlarr bazarr qbittorrent gluetun overseerr decluttarr flaresolverr rarbg-shim)' ;;
    esac
  fi
}
# Guard so sourcing never errors where completion isn't loaded (e.g. test/automation shells)
if whence compdef >/dev/null 2>&1; then
  compdef _plex_complete plex
fi
