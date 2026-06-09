#!/usr/bin/env python3
"""
Audio Plugin Cleanup — remove unused AAX and VST2 duplicates. Safe by construction.

PURPOSE
  Reclaim disk by removing two narrow categories of plugin that this machine
  doesn't need:
    • VST2 plugins that ALSO exist as VST3   — the VST3 is the modern one to keep
    • AAX plugins                             — this machine doesn't run Pro Tools

  This script is NOT a general plugin uninstaller. It cannot wipe your collection.

SAFETY GUARANTEES — these are NEVER deleted, regardless of flags:
  • AU (.component)                          — always kept
  • VST3 (.vst3)                             — always kept
  • VST2 (.vst) with NO VST3 counterpart     — always kept (see --keep)

  There is no flag, scope, or mode that can remove AU, VST3, or an irreplaceable
  VST2. The only things `--delete` can ever touch are VST2 dupes and AAX bundles.

DIRECTORIES SCANNED
  AU:   /Library/Audio/Plug-Ins/Components               (.component)
  VST2: /Library/Audio/Plug-Ins/VST                      (.vst)
  VST3: /Library/Audio/Plug-Ins/VST3                     (.vst3)
  AAX:  /Library/Application Support/Avid/Audio/Plug-Ins (.aaxplugin)

ACTIONS (mutually exclusive — omit for a summary):
  --wizard      interactive guided cleanup (recommended for first-time use)
  --list        list removable candidates with sizes
  --keep        list VST2 plugins WITHOUT a VST3 twin (these are protected)
  --coverage    per-plugin [A|2|3|P] matrix across all formats
  --delete      remove candidates (needs sudo)

SCOPE for --list / --delete:
  --format vst2    VST2 duplicates only
  --format aax     AAX bundles only
  --format all     BOTH removable categories — VST2 dupes + AAX (default)
                   (Note: "all" means "all REMOVABLE", not "all plugins".
                    AU, VST3, and protected VST2 are untouched regardless.)

DELETE MODE for --delete:
  --mode trash   move to ~/.Trash with your ownership (default; recoverable)
  --mode rm      permanent delete via `rm -rfv`

TYPICAL WORKFLOW
  plugin-cleanup --wizard                         # guided cleanup (easiest)

  Or step-by-step:
  plugin-cleanup                                  # survey
  plugin-cleanup --list --format vst2             # inspect VST2 dupes
  sudo plugin-cleanup --delete --format vst2      # trash VST2 dupes

`--delete` always confirms ([y/N] prompt) and reprints the exact sudo recipe.
"""

import argparse
import os
import pwd
import re
import subprocess
import sys
from pathlib import Path

FORMATS = {
    "au":   {"dir": Path("/Library/Audio/Plug-Ins/Components"),               "ext": ".component", "recursive": False},
    "vst2": {"dir": Path("/Library/Audio/Plug-Ins/VST"),                      "ext": ".vst",       "recursive": False},
    "vst3": {"dir": Path("/Library/Audio/Plug-Ins/VST3"),                     "ext": ".vst3",      "recursive": False},
    "aax":  {"dir": Path("/Library/Application Support/Avid/Audio/Plug-Ins"), "ext": ".aaxplugin", "recursive": True},
}

# Architecture/bitness suffixes some vendors append (e.g. "ValhallaVintageVerb_x64.vst"
# vs "ValhallaVintageVerb.vst3"). Stripping these lets the matcher pair them.
SUFFIX_RE = re.compile(r"[_ ]?(x86_64|x64|64bit|64-bit|64)$", re.IGNORECASE)


def normalize(stem: str) -> str:
    return SUFFIX_RE.sub("", stem).strip()


def scan(fmt: str) -> list[Path]:
    spec = FORMATS[fmt]
    directory: Path = spec["dir"]
    if not directory.is_dir():
        return []
    ext: str = spec["ext"]

    if spec["recursive"]:
        return sorted(directory.rglob(f"*{ext}"))

    return sorted(p for p in directory.iterdir() if p.name.endswith(ext))


def by_stem(paths: list[Path]) -> dict[str, Path]:
    return {p.stem: p for p in paths}


def size_bytes(path: Path) -> int:
    if path.is_symlink() or path.is_file():
        return path.stat().st_size

    return sum(f.stat().st_size for f in path.rglob("*") if f.is_file())


def fmt_mb(n: int) -> str:
    return f"{n / 1024 / 1024:7.1f} MB"


def classify_vst2(vst2: list[Path], vst3: list[Path]) -> tuple[list[Path], list[Path]]:
    vst3_stems = {p.stem for p in vst3}
    vst3_norm = {normalize(p.stem) for p in vst3}

    dupes, keep = [], []
    for p in vst2:
        if p.stem in vst3_stems or normalize(p.stem) in vst3_norm:
            dupes.append(p)
        else:
            keep.append(p)

    return dupes, keep


def candidates(scope: str) -> dict[str, list[Path]]:
    """Returns {format_name: [removable paths]} for the requested scope."""
    result: dict[str, list[Path]] = {}

    if scope in ("vst2", "all"):
        dupes, _ = classify_vst2(scan("vst2"), scan("vst3"))
        result["vst2"] = dupes

    if scope in ("aax", "all"):
        result["aax"] = scan("aax")

    return result


def sudo_user_pw() -> "pwd.struct_passwd | None":
    sudo_user = os.environ.get("SUDO_USER")
    if not sudo_user or os.geteuid() != 0:
        return None
    try:
        return pwd.getpwnam(sudo_user)
    except KeyError:
        return None


def unique_trash_dest(trash: Path, name: str) -> Path:
    dest = trash / name
    if not dest.exists():
        return dest

    stem, suffix = Path(name).stem, Path(name).suffix
    n = 1
    while True:
        dest = trash / f"{stem} {n}{suffix}"
        if not dest.exists():
            return dest
        n += 1


def trash_to_user_home(path: Path, pw: "pwd.struct_passwd") -> bool:
    """Move path into $SUDO_USER's ~/.Trash and restore their ownership."""
    trash = Path(pw.pw_dir) / ".Trash"
    if not trash.is_dir():
        print(f"  FAILED   {path.name}: {trash} does not exist", file=sys.stderr)
        return False

    dest = unique_trash_dest(trash, path.name)
    try:
        subprocess.run(["mv", "-v", str(path), str(dest)], check=True)
        subprocess.run(["chown", "-R", f"{pw.pw_uid}:{pw.pw_gid}", str(dest)], check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError) as e:
        print(f"  FAILED   {path.name}: {e}", file=sys.stderr)
        return False


def remove_path(path: Path, mode: str) -> bool:
    if mode == "rm":
        try:
            subprocess.run(["rm", "-rfv", str(path)], check=True)
            return True
        except (subprocess.CalledProcessError, FileNotFoundError) as e:
            print(f"  FAILED   {path.name}: {e}", file=sys.stderr)
            return False

    pw = sudo_user_pw()
    if pw:
        return trash_to_user_home(path, pw)

    try:
        subprocess.run(["trash", "-Fv", str(path)], check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError) as e:
        print(f"  FAILED   {path.name}: {e}", file=sys.stderr)
        return False


def prune_empty_dirs(root: Path) -> int:
    """Remove vendor subdirs left empty after AAX cleanup. Returns count removed."""
    if not root.is_dir():
        return 0

    pruned = 0
    for sub in sorted(root.iterdir()):
        if sub.is_dir() and not any(sub.iterdir()):
            try:
                sub.rmdir()
                pruned += 1
            except OSError:
                pass

    return pruned


def wizard() -> int:
    """Interactive guided cleanup. Confirms each step, then re-execs into --delete."""
    bar = "━" * 60
    print(f"\n{bar}\n Audio Plugin Cleanup — Wizard\n{bar}\n")
    print("Read-only until the final confirm. Quit anytime with q.\n")

    au_paths   = scan("au")
    vst2_paths = scan("vst2")
    vst3_paths = scan("vst3")
    aax_paths  = scan("aax")
    dupes, keep = classify_vst2(vst2_paths, vst3_paths)
    vst2_size = sum(size_bytes(p) for p in dupes)
    aax_size  = sum(size_bytes(p) for p in aax_paths)

    print(f"  AU:   {len(au_paths):4d}  (always kept)")
    print(f"  VST2: {len(vst2_paths):4d}  ({len(dupes)} removable dupes, {len(keep)} protected)")
    print(f"  VST3: {len(vst3_paths):4d}  (always kept)")
    print(f"  AAX:  {len(aax_paths):4d}  (all removable — no Pro Tools)\n")

    if len(dupes) + len(aax_paths) == 0:
        print("Nothing reclaimable. You're tidy.")
        return 0

    print(f"  Reclaimable: {len(dupes) + len(aax_paths)} plugins ({fmt_mb(vst2_size + aax_size)})\n")

    print("What to clean?")
    print(f"  [1] VST2 duplicates    {len(dupes):4d}  {fmt_mb(vst2_size)}")
    print(f"  [2] AAX bundles        {len(aax_paths):4d}  {fmt_mb(aax_size)}")
    print(f"  [3] Both               {len(dupes) + len(aax_paths):4d}  {fmt_mb(vst2_size + aax_size)}")
    print( "  [q] Quit")

    scope_map = {"1": "vst2", "2": "aax", "3": "all"}
    choice = input("Choice: ").strip().lower()
    if choice in ("q", ""):
        print("Cancelled.")
        return 0
    if choice not in scope_map:
        print("Invalid choice. Cancelled.")
        return 1

    scope = scope_map[choice]
    groups = candidates(scope)
    scope_count = sum(len(v) for v in groups.values())

    if scope_count == 0:
        print(f"\nNothing in scope '{scope}'. Cancelled.")
        return 0

    print(f"\nTargeting {scope_count} plugins ({fmt_mb(sum(size_bytes(p) for paths in groups.values() for p in paths))}):")
    preview = 8
    shown = 0
    for fmt_name, paths in groups.items():
        for path in paths:
            if shown < preview:
                print(f"  {fmt_mb(size_bytes(path))}  [{fmt_name}] {path.stem}")
                shown += 1
    if scope_count > preview:
        print(f"  … and {scope_count - preview} more")

    print("\nHow to delete?")
    print("  [1] Send to Trash (recoverable from ~/.Trash)  [default]")
    print("  [2] Permanent rm -rfv  (no recovery)")
    print( "  [q] Quit")

    mode_map = {"": "trash", "1": "trash", "2": "rm"}
    choice = input("Choice [1]: ").strip().lower()
    if choice == "q":
        print("Cancelled.")
        return 0
    if choice not in mode_map:
        print("Invalid choice. Cancelled.")
        return 1

    delete_mode = mode_map[choice]
    action = "Send to Trash" if delete_mode == "trash" else "PERMANENTLY DELETE"
    print(f"\n{action} {scope_count} plugins.")
    if os.geteuid() != 0:
        print("Requires sudo — you'll be prompted for your password.")

    confirm = input("Proceed? [y/N]: ").strip().lower()
    if confirm not in ("y", "yes"):
        print("Cancelled.")
        return 0

    cmd = [sys.executable, str(Path(__file__).resolve()),
           "--delete", "--format", scope, "--mode", delete_mode, "--yes"]
    if os.geteuid() != 0:
        os.execvp("sudo", ["sudo"] + cmd)
    os.execvp(sys.executable, cmd)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    action = parser.add_mutually_exclusive_group()
    action.add_argument("--wizard",   action="store_true", help="interactive guided cleanup (recommended)")
    action.add_argument("--list",     action="store_true", help="list removable candidates (scope with --format)")
    action.add_argument("--keep",     action="store_true", help="list VST2 plugins without a VST3 twin (never touched)")
    action.add_argument("--coverage", action="store_true", help="per-plugin [A|2|3|P] tag matrix across all formats")
    action.add_argument("--delete",   action="store_true", help="remove candidates (needs sudo; --format scopes, --mode picks trash/rm)")
    parser.add_argument("--format", choices=["vst2", "aax", "all"], default="all",
                        help="scope for --list / --delete (default: all). 'all' = VST2 dupes + AAX, NOT every plugin")
    parser.add_argument("--mode", choices=["trash", "rm"], default="trash",
                        help="trash → ~/.Trash with your ownership; rm → permanent (default: trash)")
    parser.add_argument("--yes", action="store_true",
                        help="skip the [y/N] confirm on --delete (intended for wizard re-exec; use with care)")
    args = parser.parse_args()

    if args.wizard:
        return wizard()

    if args.coverage:
        au   = by_stem(scan("au"))
        vst2 = by_stem(scan("vst2"))
        vst3 = by_stem(scan("vst3"))
        aax  = {p.stem for p in scan("aax")}

        all_stems = sorted(set(au) | set(vst2) | set(vst3) | aax)
        for stem in all_stems:
            tags = "".join([
                "A" if stem in au   else "-",
                "2" if stem in vst2 else "-",
                "3" if stem in vst3 else "-",
                "P" if stem in aax  else "-",
            ])
            print(f"  [{tags}]  {stem}")

        return 0

    if args.keep:
        _, keep = classify_vst2(scan("vst2"), scan("vst3"))
        for path in keep:
            print(f"  {fmt_mb(size_bytes(path))}  {path.stem}")
        print(f"\n{len(keep)} VST2 plugins have no VST3 counterpart")

        return 0

    if args.list:
        groups = candidates(args.format)
        grand = 0

        for fmt_name, paths in groups.items():
            if not paths:
                continue

            print(f"== {fmt_name.upper()} ==")
            subtotal = 0
            for path in paths:
                size = size_bytes(path)
                subtotal += size
                print(f"  {fmt_mb(size)}  {path.stem}")
            print(f"  {len(paths)} candidates, {fmt_mb(subtotal)} subtotal\n")
            grand += subtotal

        total_count = sum(len(v) for v in groups.values())
        print(f"{total_count} candidates total, {fmt_mb(grand)}")

        return 0

    if args.delete:
        groups = candidates(args.format)
        total_count = sum(len(v) for v in groups.values())

        if total_count == 0:
            print("Nothing to delete.")
            return 0

        if os.geteuid() != 0:
            explicit_format = any(a == "--format" or a.startswith("--format=") for a in sys.argv)
            explicit_mode = any(a == "--mode" or a.startswith("--mode=") for a in sys.argv)
            recipe = f"sudo {sys.executable} {Path(__file__).resolve()} --delete"
            if explicit_format:
                recipe += f" --format {args.format}"
            if explicit_mode:
                recipe += f" --mode {args.mode}"

            print("Need root to delete. Re-run with:")
            print(f"  {recipe}")
            return 1

        grand = sum(size_bytes(p) for paths in groups.values() for p in paths)
        breakdown = ", ".join(f"{len(v)} {k}" for k, v in groups.items() if v)
        verb = "send to Trash" if args.mode == "trash" else "PERMANENTLY DELETE"
        print(f"About to {verb} {total_count} plugins ({breakdown}) — {fmt_mb(grand)}.")

        if not args.yes:
            answer = input("Proceed? [y/N]: ").strip().lower()
            if answer not in ("y", "yes"):
                print("Aborted.")
                return 1

        removed = 0
        for fmt_name, paths in groups.items():
            for path in paths:
                if remove_path(path, args.mode):
                    removed += 1
                    print(f"  removed  [{fmt_name}] {path.name}")

        if groups.get("aax"):
            pruned = prune_empty_dirs(FORMATS["aax"]["dir"])
            if pruned:
                print(f"\nPruned {pruned} empty AAX vendor subdir(s).")

        print(f"\nRemoved {removed}/{total_count} plugins.")
        return 0

    # Default: summary
    au   = scan("au")
    vst2 = scan("vst2")
    vst3 = scan("vst3")
    aax  = scan("aax")

    print(f"AU:   {len(au):4d}  {FORMATS['au']['dir']}")
    print(f"VST2: {len(vst2):4d}  {FORMATS['vst2']['dir']}")
    print(f"VST3: {len(vst3):4d}  {FORMATS['vst3']['dir']}")
    print(f"AAX:  {len(aax):4d}  {FORMATS['aax']['dir']}")
    print()

    dupes, keep = classify_vst2(vst2, vst3)
    dupe_total = sum(size_bytes(p) for p in dupes)
    aax_total  = sum(size_bytes(p) for p in aax)

    print(f"VST2 with VST3 counterpart (removable): {len(dupes):4d}  {fmt_mb(dupe_total)}")
    print(f"VST2 without VST3 (must keep):          {len(keep):4d}")
    print(f"AAX (no Pro Tools — all removable):     {len(aax):4d}  {fmt_mb(aax_total)}")
    print()
    print("Removable = VST2 dupes + AAX only. AU, VST3, and VST2-without-VST3 are never deleted.")
    print("Easiest: `plugin-cleanup --wizard`. Manual: `--list --format {vst2|aax}`, then `sudo … --delete …`.")

    return 0


if __name__ == "__main__":
    sys.exit(main())
