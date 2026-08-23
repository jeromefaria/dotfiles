# Media Automation Stack

Plex + the *arr suite, Dockerised (via Colima), for automated movie/TV acquisition,
subtitles, and remote access. Lives at `~/plex-stack`. Aliases in
`terminal/zsh/aliases/media-stack.sh`.

---

## Pipeline

```
Overseerr / Pocket / Ruddarr (phone)         Radarr (movies) / Sonarr (TV)
        │  request / interactive search              │
        └──────────────►  Prowlarr  ◄────────────────┘
                          indexers: YTS · 1337x(+FlareSolverr) · EZTV · RARBG-dump-shim
                             │  hands chosen release
                             ▼
        qBittorrent  ──(all torrent traffic via gluetun→NordVPN)──►  swarm
                             │  hardlink import (same-volume)
                             ▼
                    /Volumes/Media/Cinema  ·  /Volumes/Archive/Media/Television
                             │
                    Bazarr adds subtitles  ──►  Plex  ──►  devices
                             ▲
                    Decluttarr removes stalled/dead grabs, blocklists, re-searches
```

## Services

| Service | Port | Role |
|---|---|---|
| Plex | 32400 | Media server (native app, not in Docker) |
| Radarr | 7878 | Movies |
| Sonarr | 8989 | TV |
| Prowlarr | 9696 | Indexer manager (feeds Radarr/Sonarr) |
| Bazarr | 6767 | Subtitles |
| qBittorrent | 8080 | Download client (runs inside gluetun's netns) |
| gluetun | — | VPN gateway (NordVPN/WireGuard) for qBittorrent |
| Overseerr | 5055 | Discovery / request front-end (Plex login) |
| Decluttarr | — | Queue hygiene: removes stalled/dead downloads, re-searches |
| FlareSolverr | 8191 | Solves Cloudflare for 1337x |
| rarbg-shim | 9117 | Serves the local RARBG SQLite dump as a Torznab indexer |

## Where things live

- **Stack:** `~/plex-stack` (`docker-compose.yml`, per-service `config/`)
- **Secrets (gitignored):** `~/plex-stack/.env` (VPN key, PUID/PGID), `.arr-credentials`
  (Radarr/Sonarr/Prowlarr web login), `.qb-credentials` (qBittorrent). API keys are in
  each `config/*/config.xml`.
- **RARBG dump:** `~/Movies/rarbg_db.sqlite` (frozen May-2023; queried by hand via the
  `rbg` alias; backed up to iCloud Drive `Media Backups/`)
- **Media:** movies `/Volumes/Media/Cinema`, TV `/Volumes/Archive/Media/Television`
  (both USB; downloads live on the same volume as their library for instant hardlinks)

## The `plex` command

Everything is driven by one command — `plex help` lists it all. Defined in
`terminal/zsh/aliases/media-stack.sh`; tab-completion included.

```
plex boot                  # start Colima + stack, wait for VPN, reconnect qBittorrent
plex halt                  # gracefully stop the stack + Colima
plex up | down             # start / stop containers (Colima left running)
plex restart <svc>         # restart one container (e.g. plex restart radarr)
plex status                # health overview of all stack containers
plex health                # torrent-client + VPN snapshot (dead vs seeded)
plex vpn                   # gluetun's NordVPN exit IP (torrent privacy check)
plex logs [svc]            # follow logs — all, or one service
plex ts                    # Tailscale status
plex update                # pull latest images + recreate (monthly)
plex autostart on|off|status   # toggle login auto-start
plex fix qb|sonarr|ts-dns  # the runbook one-shots (see below)
plex web <svc>             # open a web UI (plex|radarr|sonarr|prowlarr|bazarr|qbit|overseerr)
```

---

## Runbooks

### 1. All torrents stalled at 0 seeds simultaneously
**Cause:** gluetun's VPN tunnel restarted (routine NordVPN reconnect); qBittorrent shares
its netns and loses every connection, and does NOT self-recover.
**Fix:** `plex fix qb`  (= `docker restart qbittorrent`).
**Not this** if only SOME torrents are at 0 seeds — that's normal dead-swarm staleness,
which Decluttarr removes + re-searches on its own.

### 2. New series stuck at 0 episodes / jammed refresh queue
**Cause:** Sonarr's `RefreshSeries` queue jams when several series are added at once.
**Fix:** `plex fix sonarr`  (= `docker restart sonarr`). Avoid by staggering bulk adds.

### 3. Remote access / DNS breaks (Tailscale ↔ NordVPN)
The Tailscale app enables DNS override by default, which clashes with NordVPN and breaks
all DNS. **Fix (persistent):** `plex fix ts-dns` (= `tailscale set --accept-dns=false`). Safe
because remote access uses raw `100.x` IPs, not MagicDNS names.

---

## Remote access

- **Tailscale** (Mac app — real interface, not the Homebrew userspace daemon). Mac IP
  `100.117.188.79`. Reach any service at `http://100.117.188.79:<port>`.
- **Phone:** Ruddarr (add/search) + Pocket-for-Seerr (browse/request) → point at the
  Tailscale IP + API keys. Termius for SSH; Files app → `smb://100.117.188.79` for drives.
- **Web login** for the *arr apps: user `jerome`, password in `~/plex-stack/.arr-credentials`.

## VPN architecture (important constraints)

- **Torrents:** always private via **gluetun** (its own NordVPN WireGuard tunnel, using the
  key in `.env`) — independent of the NordVPN desktop app.
- **NordVPN desktop app ↔ Tailscale DO NOT coexist:** the app is full-tunnel with no macOS
  split-tunneling; it breaks Tailscale's coordination channel. Keep the **desktop app off**
  for reliable remote access. (Torrents stay private regardless — gluetun handles them.)
- **One NordLynx key = one connection.** gluetun holds it; a second host WireGuard tunnel
  on the same key conflicts. So system-wide host-NordVPN + gluetun can't run together.
- **For browsing privacy with Tailscale up:** use gluetun's HTTP proxy (point the browser at
  `localhost:8888`) rather than a host VPN — one connection, no conflict. *(Not yet enabled.)*

## Security posture

- **Auth on all user-facing services** (Radarr/Sonarr/Prowlarr/Bazarr/qBittorrent). macOS
  firewall on; nothing port-forwarded to the internet; secrets not in any git repo.
- **FlareSolverr and rarbg-shim are internal-only** (`expose:`, no published port) — they
  have no auth, so they're reachable only by Prowlarr over the Docker network, never the LAN.
- **Remote access is Tailscale-only** (encrypted, device-scoped). Torrents ride gluetun's
  VPN with its kill-switch.
- Optional further hardening (not done): bind the published web UIs to `127.0.0.1` instead
  of `0.0.0.0` and reach them purely via Tailscale, removing trusted-LAN exposure.
- Housekeeping: `plex-pull` monthly for CVE fixes; lock the Tailscale ACL to your devices;
  rotate the qB/*arr passwords occasionally.

## Safety filters (malware / junk)

Two layers reject executable-file releases (fake torrents disguised as media):
- **qBittorrent** → "excluded file names" skips `*.exe/.bat/.cmd/.com/.scr/.msi/.lnk/.vbs/.ps1/.jar`
  inside any torrent (the dangerous file never downloads).
- **Radarr/Sonarr** → `Junk-Executable` custom format (−10000, with profile `minFormatScore` 0)
  rejects any release with an executable extension in its title before it's grabbed.

## Queue tuning (avoids dead-torrent starvation)

- qBittorrent `max_active_downloads=40`, `dont_count_slow_torrents=on` — so dead `metaDL`
  torrents can't occupy all the slots and starve live downloads (they promote by queue
  position, not health).
- Decluttarr `timer=10`, `max_strikes=6` (~60 min before removal), `remove_slow=off`.
  **Why patient, not aggressive:** with no VPN port forwarding, low-seed swarms (~3 seeders)
  download slowly but *do* finish. An aggressive Decluttarr killed + blocklisted those
  slow-but-alive releases, poisoning the blocklist so whole shows (High Maintenance, Platonic,
  Pam & Tommy) could never complete. Since the 40 download slots already prevent queue-clog,
  Decluttarr can afford patience — it only removes torrents dead/stalled for ~an hour.
  **If shows stall with "no release found" but releases exist:** the blocklist is likely
  poisoned — clear it (Sonarr/Radarr → Activity → Blocklist → Clear) and re-search.

## Preferences (encoded in Radarr/Sonarr)

- 1080p preferred, 720p fallback, **no 4K/Remux** (USB space). Prefer **x265**; **Bluray>WEB**;
  TV favours **MeGusta**; **RARBG/RARTV** as a tiebreaker; RARBG-dump indexer deprioritised.
- **Never rename** curated files (original release names aid subtitle matching).
- Codec-only upgrades allowed (x264→x265); no quality/source churn.

## Reboot survival

- **Auto-start is configured:** Colima runs as a login LaunchAgent, and every container is
  `restart: unless-stopped`, so after a reboot the whole stack comes back on its own — you
  just need to **log in** once (LaunchAgents fire at login, not cold boot).
- **`plex boot`** is a robust manual fallback/nudge: starts Colima + the stack, waits for
  gluetun to be healthy, then restarts qBittorrent (a fresh VPN tunnel needs a qB reconnect
  to rejoin swarms). Run it if auto-start hiccups, then `plex health` after ~30s.
- **`plex halt`** is the mirror: gracefully stops the stack then Colima.
- **Toggle auto-start:** `plex autostart on|off|status`. (Status reads the LaunchAgent plist —
  the true "starts at next login" signal — not Colima's current running state.)

## Maintenance

- **Updates:** `plex update` monthly (keeps CVE fixes current).
- **1337x** is excluded from *interactive* search (slow Cloudflare solve) but used for auto grabs.
