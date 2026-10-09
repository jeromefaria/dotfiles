# Home Mirror — the case, and what it would take

`home-mirror.conf` has sat unbuilt since 2026-07-30. This records why it is
worth finishing, what it does *not* buy, and the preconditions — so the decision
can be made on evidence rather than on the fact that a config file exists.

Status: **config only.** `home-mirror-sync.sh` and `home-mirror-manage.sh` named
in the conf header do not exist, there is no launchd plist, and `/Volumes/Mirror`
has never been mounted.

## Timeline, since it matters

The X9 became the Time Machine destination on **2026-07-30 12:54** (the volume's
`.fseventsd` birth). `home-mirror.conf` was written **2h 44m later, the same
afternoon**, and names "Time Machine (X9)" in its own header. So it does not
predate the disk upgrade and was not superseded by it — it was designed as a
deliberate second layer with the new disk already in place.

## What it actually adds

Not coverage. `/Library/Audio`, `~/Library/Preferences` and the rest of the
mirror's roots are already `[Included]` in Time Machine. What it adds is
**independence**:

- **Format.** TM restores need Time Machine. A plain rsync tree is browsable and
  restorable from any Mac, or from the Finder, with no dependency on TM's
  database or sparsebundle.
- **Mechanism.** TM and rsync fail differently. A TM chain can break while the
  files on disk stay perfectly readable.
- **Device.** A second physical disk, so one enclosure failure is not total.

## The evidence that argues for it

From the week of 2026-10-02, all verified rather than supposed:

- Time Machine ran **36 interrupted attempts** across roughly six weeks and
  produced exactly **one** usable restore point. It reported nothing wrong; the
  staleness alert that caught it had to be written first.
- The Audio drive's offsite sync had **never recorded a successful run**, because
  `local` used at top level aborted the script immediately after rclone
  succeeded. Months of green-looking nightly jobs, no success marker, no prune.
- The Audio enclosure **dropped off the USB bus twice in one evening**, once
  mid-sync, producing 1024 read errors.

The common thread is not that the backups were missing — it is that two
independent mechanisms failed *quietly*, and in both cases the thing that
surfaced it was an alert added after the fact. A third layer is only worth
having if it is noisier than those were.

## What would make it fail

- **Silent rot.** Another unattended job that can stop working without saying
  so. Non-negotiable: a staleness check wired up in the same commit as the sync
  script, not afterwards. `MAX_STALE_HOURS=48` is already in the conf; the
  pattern to copy is `tm-backup-staleness-check.sh`, including keeping the
  marker in `~/Library/Application Support` rather than `~/Library/Logs`, which
  a disk cleaner wipes.
- **USB contention.** Another always-attached disk on a bus where a DisplayLink
  dock and a 4K capture device already share a hub with two SSDs, and where
  drives have demonstrably dropped under load. The mirror should run when the
  capture device is idle, and the overlap guard added to `audio-backup-sync.sh`
  (defer while Time Machine is mid-backup) is the precedent.
- **Footprint drift.** The conf budgets ~102 GB from 2026-07-30 sizes. Spot
  checks on 2026-10-09 still hold — `/Library/Audio/Plug-Ins` 42 GB, `~/Work`
  16 GB — so the estimate is current, but it wants re-checking at build time
  rather than trusting a figure that is by then months old.

## The open question worth answering first

Is the boot volume the right target for the EVO?

The boot volume is 423 GB and now has 25 Time Machine restore points. The Audio
drive is **1.4 TB with a single offsite copy**, on an enclosure that dropped
twice this week, and it holds the irreplaceable material — the BRØQN catalogue,
project archives, masters. Time Machine excludes `/Volumes/Audio`, `/Volumes/Media`
and `/Volumes/Archive` entirely, so none of that has a second local copy.

Risk-weighted, a second copy of the audio masters may be worth more than a
second copy of a volume Time Machine already has. The deciding constraint is EVO
capacity: 102 GB of boot-volume mirror fits almost anything, whereas even a
scoped subset of the Audio drive (`Projects`, `Recordings`, `Releases` — not the
re-downloadable `Libraries`) needs materially more.

Worth measuring those three directories against the EVO's actual size before
committing to the scope in the conf.

## Preconditions before building

1. Attach the EVO, note its real capacity, and name the volume `Mirror`.
2. Create the `SENTINEL` marker (`/Volumes/Mirror/.home-mirror-dest`) so the sync
   gates on the destination being present, the way `audio-backup-sync.sh` gates
   on `SYSTEM.md`.
3. Decide scope: the conf as written, or re-point at the audio masters.
4. Write the sync and the staleness check **together**.
5. Re-measure the footprint, and update the conf's figure with a date.
