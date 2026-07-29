# Time Machine backup strategy

Two small tools plus a version-controlled exclusion set that keep Time Machine
**healthy** (a growing chain of history) instead of **thrashing** (filling the
disk, thinning to nothing, corrupting, and forcing a fresh full backup).

## The problem this solves

The erase-and-full-backup cycle is almost always a **sizing** problem, not a
Time Machine bug. Time Machine wants the destination at **>=1.5x** the backup
footprint (ideally 2-3x) to maintain history. Below that it thins aggressively,
can't keep a consistent chain, and eventually you erase and start over.

## The 2026-07 disk profile (why these exclusions)

Internal Data volume: **~370 GB**. Where it lives:

| Region | Size | Decision |
|---|---:|---|
| `/Applications` | ~79 GB | **Keep** (full-fidelity restore; reinstalling audio apps + re-authorising is painful) |
| `/Library/Audio` | ~42 GB | **Keep** — plugins/presets |
| `~/Library/Application Support` | ~56 GB | Mostly keep; caches excluded |
| `/opt/homebrew` | ~20 GB | **Exclude** — `brew` reinstalls |
| `~/Downloads` | ~12 GB | **Exclude** — re-downloadable |
| `/Library/Developer` | ~8 GB | **Exclude** — Xcode / CommandLineTools |
| Plex server data | ~5 GB | **Exclude** — rebuilds from library |
| caches + dev toolchains | ~13 GB | **Exclude** — all regeneratable |

Tier-1 exclusions total **~57 GB**, taking the footprint to **~313 GB**.

### Sizing math

| Destination | Footprint | Ratio | Verdict |
|---|---:|---:|---|
| 465 GB, nothing excluded | 370 GB | 1.26x | thrashes |
| 465 GB + Tier 1 | 313 GB | 1.49x | still marginal |
| 465 GB + Tier 1 + `/Applications` | 234 GB | 1.99x | healthy |
| **1 TB + Tier 1** | 313 GB | **~3.2x** | **healthy, keeps apps** |

An HDD is a fine Time Machine target — the workload is background and
append-heavy. Drive type only affects the *initial* full backup and restore
speed, which is exactly what `tm-fast-backup` mitigates.

## The tools

`tm-backup.conf` — single source of truth: the throttle knob + the
`TM_EXCLUSIONS` array.

`tm-exclusions.sh` (alias `tm-exclusions`):

```bash
tm-exclusions list      # show the configured paths
tm-exclusions status    # show each path's excluded/included state
tm-exclusions apply     # exclude every configured path (sticky; sudo)
tm-exclusions remove    # un-exclude every configured path (sudo)
```

Exclusions are **sticky** (`tmutil addexclusion -p`): they survive a path being
recreated and re-apply cleanly after erasing or swapping the backup disk.

`tm-fast-backup.sh` (alias `tm-fast-backup`):

```bash
tm-fast-backup            # lift the I/O throttle, caffeinate, blocking backup, restore throttle
tm-fast-backup --gentle   # blocking backup at normal priority (dock/hub-safe; no sudo)
tm-fast-backup --dry-run  # show what it would do (combine with --gentle)
```

The throttle (`debug.lowpri_throttle_enabled`) gates backupd's low-priority
I/O. Lifting it (default mode) is the biggest single speedup on a slow/HDD
destination or a large first backup. It's restored afterwards (and resets on
reboot regardless).

**Direct-connect only for the throttle-lift.** When the destination is reached
through a USB hub or dock, lifting the throttle maximises DMA transaction rate
and can trigger a USB DART kernel panic on Apple Silicon (learned the hard way
— a hub-nested HDD backup panicked the machine mid-copy). Behind a hub/dock,
always use `--gentle`, which runs the same blocking backup at backupd's normal
throttled priority. Automatic scheduled backups are already gentle by design,
so `--gentle` just gives you a matching manual command.

## First-time setup on a new / erased disk

1. Connect the disk over **USB 3+** (a USB 2 link makes the first backup crawl).
2. Add it in System Settings > General > Time Machine — let macOS erase and
   format it **APFS** automatically.
3. `tm-exclusions apply` — apply the exclusion set.
4. `tm-fast-backup` — run the initial full backup fast; watch with
   `tmutil status` in another pane.
5. `tm-exclusions status` — confirm everything reads `excluded`.
