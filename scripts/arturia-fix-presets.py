#!/usr/bin/env python3
"""
Arturia Preset Folder Restructuring Script

Two known broken structures and their fixes:

  Case A — flat preset files landed directly in Factory/ instead of Factory/Factory/:
    Factory/PresetName  →  Factory/Factory/PresetName

  Case B — channel subdirs (Mono/, Stereo/, etc.) landed inside Factory/Factory/
            instead of directly in Factory/:
    Factory/Factory/Stereo/PresetName  →  Factory/Stereo/PresetName

Needs reinstall — the plugin preset folder exists (possibly with a Factory/ subfolder)
  but contains no actual preset files. The installer skips copying presets when the
  folder already exists, so the fix is:
    1. Delete the entire Presets/PLUGINNAME/ folder
    2. Reinstall using the .pkg downloaded from the Arturia website
       (NOT through Arturia Software Center, which also skips the presets)
"""

import shutil
import sys
from pathlib import Path


SKIP = {'Shared', 'FactoryEdit'}
BASE = Path('/Volumes/Audio/Audio/Libraries/Arturia/Presets')


def has_preset_files(path: Path) -> bool:
    """Return True if path contains any non-XML preset files outside Tutorials/."""
    return any(
        f for f in path.rglob('*')
        if f.is_file() and not f.name.endswith('.xml') and 'Tutorials' not in f.parts
    )


def classify_plugin(plugin: str) -> str:
    """
    Return the fix needed for a plugin, or 'ok' / 'no_factory' / 'needs_reinstall'.

      'case_a'          — Factory/ has flat files but no Factory/Factory/
      'case_b'          — Factory/Factory/ has subdirectories (not flat files)
      'needs_reinstall' — folder exists but contains no actual preset files
      'ok'              — structure looks correct
      'no_factory'      — no Factory/ folder at all
    """
    factory = BASE / plugin / 'Factory'
    nested = factory / 'Factory'

    if not factory.exists():
        if not has_preset_files(BASE / plugin):
            return 'needs_reinstall'
        return 'no_factory'

    if nested.exists():
        contents = list(nested.iterdir())
        subdirs = [x for x in contents if x.is_dir()]
        direct_files = [x for x in contents if x.is_file()]
        if subdirs and not direct_files:
            return 'case_b'
        if not has_preset_files(nested):
            return 'needs_reinstall'
        return 'ok'

    # No Factory/Factory/ — inspect Factory/ directly
    contents = list(factory.iterdir())
    subdirs = [x for x in contents if x.is_dir()]
    flat_files = [x for x in contents if x.is_file() and x.name != '.DS_Store' and not x.name.endswith('.xml')]
    if subdirs:
        # Has subdirs (e.g. Mono/, Stereo/) — correct structure, check for content
        if not has_preset_files(factory):
            return 'needs_reinstall'
        return 'ok'
    if flat_files:
        return 'case_a'
    if not has_preset_files(factory):
        return 'needs_reinstall'
    return 'ok'


def _empty_stats() -> dict:
    return {'files_moved': 0, 'files_skipped': 0, 'dirs_moved': 0, 'dirs_skipped': 0, 'errors': []}


def _move_items(src: Path, dest_parent: Path, dry_run: bool, skip_name: str = None) -> dict:
    """Move all items from src/ into dest_parent/, skipping any named skip_name."""
    stats = _empty_stats()
    for item in list(src.iterdir()):
        if skip_name and item.name == skip_name:
            continue
        dest = dest_parent / item.name
        label = 'file' if item.is_file() else 'dir'
        key_suffix = 'files' if item.is_file() else 'dirs'
        if dest.exists():
            stats[f'{key_suffix}_skipped'] += 1
            print(f"  ⊘ Skip (exists): {item.name}")
        elif dry_run:
            stats[f'{key_suffix}_moved'] += 1
            print(f"  [DRY RUN] Would move {label}: {item.name}")
        else:
            try:
                shutil.move(str(item), str(dest))
                stats[f'{key_suffix}_moved'] += 1
                print(f"  → Moved {label}: {item.name}")
            except Exception as e:
                stats['errors'].append(str(e))
                print(f"  ✗ Error: {e}")
    return stats


def fix_case_a(plugin: str, dry_run: bool) -> dict:
    """Move flat preset files from Factory/ into Factory/Factory/."""
    factory = BASE / plugin / 'Factory'
    nested = factory / 'Factory'
    if dry_run:
        print(f"  [DRY RUN] Would create Factory/Factory/")
    else:
        nested.mkdir(parents=True, exist_ok=True)
        print(f"  ✓ Created Factory/Factory/")
    return _move_items(factory, nested, dry_run, skip_name='Factory')


def fix_case_b(plugin: str, dry_run: bool) -> dict:
    """Move channel subdirs from Factory/Factory/ up to Factory/."""
    factory = BASE / plugin / 'Factory'
    nested = factory / 'Factory'
    stats = _move_items(nested, factory, dry_run)
    if dry_run:
        print(f"  [DRY RUN] Would remove Factory/Factory/")
    else:
        try:
            nested.rmdir()
            print(f"  ✓ Removed empty Factory/Factory/")
        except Exception as e:
            stats['errors'].append(str(e))
            print(f"  ✗ Could not remove Factory/Factory/: {e}")
    return stats


def main():
    dry_run = '--execute' not in sys.argv

    print("=" * 70)
    if dry_run:
        print("DRY RUN MODE - No files will be moved")
        print("Add '--execute' flag to actually move files")
    else:
        print("EXECUTION MODE - Files will be moved")
    print("=" * 70)
    print()

    case_a, case_b, needs_reinstall = [], [], []
    for plugin_dir in sorted(BASE.iterdir()):
        if not plugin_dir.is_dir() or plugin_dir.name in SKIP:
            continue
        result = classify_plugin(plugin_dir.name)
        if result == 'case_a':
            case_a.append(plugin_dir.name)
        elif result == 'case_b':
            case_b.append(plugin_dir.name)
        elif result == 'needs_reinstall':
            needs_reinstall.append(plugin_dir.name)

    if not case_a and not case_b and not needs_reinstall:
        print("No plugins need fixing.")
        return

    all_stats = []

    if case_a:
        print(f"Case A — flat files in Factory/ need moving into Factory/Factory/ ({len(case_a)} plugins):")
        for i, plugin in enumerate(case_a, 1):
            print(f"\n[{i}/{len(case_a)}] {plugin}")
            print("-" * 70)
            all_stats.append(fix_case_a(plugin, dry_run))

    if case_b:
        print(f"\nCase B — subdirs in Factory/Factory/ need moving up to Factory/ ({len(case_b)} plugins):")
        for i, plugin in enumerate(case_b, 1):
            print(f"\n[{i}/{len(case_b)}] {plugin}")
            print("-" * 70)
            all_stats.append(fix_case_b(plugin, dry_run))

    print("\n" + "=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print(f"Plugins processed: {len(all_stats)}")
    print(f"Items moved:       {sum(s['files_moved'] + s['dirs_moved'] for s in all_stats)}")
    print(f"Items skipped:     {sum(s['files_skipped'] + s['dirs_skipped'] for s in all_stats)}")
    total_errors = sum(len(s['errors']) for s in all_stats)
    print(f"Errors:            {total_errors}")
    if total_errors:
        for s in all_stats:
            for e in s['errors']:
                print(f"  - {e}")

    if needs_reinstall:
        print(f"\n{'=' * 70}")
        print(f"NEEDS REINSTALL — no preset files found ({len(needs_reinstall)} plugins):")
        print(f"  For each plugin below:")
        print(f"    1. Delete the folder: {BASE}/PLUGINNAME/")
        print(f"    2. Reinstall using the .pkg from the Arturia website")
        print(f"       (do NOT use Arturia Software Center — it will not copy presets)")
        print(f"{'=' * 70}")
        for plugin in needs_reinstall:
            print(f"  {plugin}")

    if dry_run:
        print("\nRun with '--execute' to apply Case A / Case B fixes.")


if __name__ == '__main__':
    main()
