#!/usr/bin/env python3
"""
Audio Plugin Cleanup — find and remove duplicate VST2 plugins.

Scans the three standard macOS plugin directories:
  AU:   /Library/Audio/Plug-Ins/Components  (.component)
  VST2: /Library/Audio/Plug-Ins/VST         (.vst)
  VST3: /Library/Audio/Plug-Ins/VST3        (.vst3)

A VST2 plugin is considered a removal candidate when a VST3 plugin with the
same bundle stem exists. AU plugins are never removed.

Usage:
  audio-plugin-cleanup.py                 # summary (dry run)
  audio-plugin-cleanup.py --list          # list removal candidates with sizes
  audio-plugin-cleanup.py --keep          # list VST2 plugins that must be kept
  audio-plugin-cleanup.py --coverage      # show AU/VST/VST3 coverage per plugin
  audio-plugin-cleanup.py --delete        # remove VST2 duplicates (needs sudo)
"""

import argparse
import os
import re
import shutil
import sys
from pathlib import Path

AU_DIR   = Path("/Library/Audio/Plug-Ins/Components")
VST_DIR  = Path("/Library/Audio/Plug-Ins/VST")
VST3_DIR = Path("/Library/Audio/Plug-Ins/VST3")

EXTS = {AU_DIR: ".component", VST_DIR: ".vst", VST3_DIR: ".vst3"}

# Architecture/bitness suffixes some vendors append (e.g. "ValhallaVintageVerb_x64.vst"
# vs "ValhallaVintageVerb.vst3"). Stripping these lets the matcher pair them.
SUFFIX_RE = re.compile(r"[_ ]?(x86_64|x64|64bit|64-bit|64)$", re.IGNORECASE)


def normalize(stem: str) -> str:
    return SUFFIX_RE.sub("", stem).strip()


def stems(directory: Path) -> dict[str, Path]:
    if not directory.is_dir():
        return {}
    ext = EXTS[directory]
    return {p.stem: p for p in directory.iterdir() if p.name.endswith(ext)}


def size_bytes(path: Path) -> int:
    if path.is_symlink() or path.is_file():
        return path.stat().st_size
    return sum(f.stat().st_size for f in path.rglob("*") if f.is_file())


def fmt_mb(n: int) -> str:
    return f"{n / 1024 / 1024:7.1f} MB"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    g = ap.add_mutually_exclusive_group()
    g.add_argument("--list",     action="store_true", help="list VST2 removal candidates with sizes")
    g.add_argument("--keep",     action="store_true", help="list VST2 plugins with no VST3 counterpart")
    g.add_argument("--coverage", action="store_true", help="show AU/VST2/VST3 coverage per plugin")
    g.add_argument("--delete",   action="store_true", help="remove VST2 duplicates (re-run with sudo if not root)")
    args = ap.parse_args()

    au   = stems(AU_DIR)
    vst2 = stems(VST_DIR)
    vst3 = stems(VST3_DIR)

    # Match VST2 → VST3 by exact stem, then by normalized stem for the leftovers.
    vst3_norm = {normalize(s): s for s in vst3}
    dupes, keep = [], []
    for s in sorted(vst2):
        if s in vst3 or normalize(s) in vst3_norm:
            dupes.append(s)
        else:
            keep.append(s)

    if args.coverage:
        all_stems = sorted(set(au) | set(vst2) | set(vst3))
        for s in all_stems:
            tags = "".join([
                "A" if s in au   else "-",
                "2" if s in vst2 else "-",
                "3" if s in vst3 else "-",
            ])
            print(f"  [{tags}]  {s}")
        return 0

    if args.list:
        total = 0
        for s in dupes:
            sz = size_bytes(vst2[s])
            total += sz
            print(f"  {fmt_mb(sz)}  {s}")
        print(f"\n{len(dupes)} candidates, {fmt_mb(total)} total")
        return 0

    if args.keep:
        for s in keep:
            sz = size_bytes(vst2[s])
            print(f"  {fmt_mb(sz)}  {s}")
        print(f"\n{len(keep)} VST2 plugins have no VST3 counterpart")
        return 0

    if args.delete:
        if not dupes:
            print("Nothing to delete.")
            return 0
        if os.geteuid() != 0:
            print("Need root to delete. Re-run with:")
            print(f"  sudo {sys.executable} {Path(__file__).resolve()} --delete")
            return 1
        total = sum(size_bytes(vst2[s]) for s in dupes)
        print(f"About to remove {len(dupes)} VST2 plugins ({fmt_mb(total)}).")
        ans = input("Type 'yes' to proceed: ").strip().lower()
        if ans != "yes":
            print("Aborted.")
            return 1
        removed = 0
        for s in dupes:
            path = vst2[s]
            try:
                shutil.rmtree(path)
                removed += 1
                print(f"  removed  {s}")
            except OSError as e:
                print(f"  FAILED   {s}: {e}", file=sys.stderr)
        print(f"\nRemoved {removed}/{len(dupes)} plugins.")
        return 0

    # Default: summary
    print(f"AU:   {len(au):4d}  {AU_DIR}")
    print(f"VST2: {len(vst2):4d}  {VST_DIR}")
    print(f"VST3: {len(vst3):4d}  {VST3_DIR}")
    print()
    dupe_total = sum(size_bytes(vst2[s]) for s in dupes)
    print(f"VST2 with VST3 counterpart (removable): {len(dupes):4d}  {fmt_mb(dupe_total)}")
    print(f"VST2 without VST3 (must keep):          {len(keep):4d}")
    print()
    print("Re-run with --list, --keep, --coverage, or --delete.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
