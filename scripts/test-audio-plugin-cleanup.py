#!/usr/bin/env python3
"""Tests for audio-plugin-cleanup.py.

Focus: never lose a paid VST2 that doesn't have a VST3 twin.

The classify_vst2() function decides what `--delete` will remove. A
regression in SUFFIX_RE / normalize() / the set-intersection in
classify_vst2 could silently classify a no-twin VST2 as a dupe, and a
subsequent `--delete --mode rm` would permanently erase it.

Run:  python3 scripts/test-audio-plugin-cleanup.py
      python3 scripts/test-audio-plugin-cleanup.py -v
"""
from __future__ import annotations

import sys
import tempfile
import unittest
from importlib.util import module_from_spec, spec_from_file_location
from pathlib import Path
from unittest.mock import patch

SCRIPT = Path(__file__).resolve().parent / "audio-plugin-cleanup.py"
spec = spec_from_file_location("plugin_cleanup", SCRIPT)
plugin_cleanup = module_from_spec(spec)
sys.modules["plugin_cleanup"] = plugin_cleanup
spec.loader.exec_module(plugin_cleanup)


class NormalizeTests(unittest.TestCase):
    """SUFFIX_RE coverage — drift here is the data-loss surface."""

    def test_strips_x64(self):
        self.assertEqual(plugin_cleanup.normalize("Plugin_x64"), "Plugin")

    def test_strips_x86_64(self):
        self.assertEqual(plugin_cleanup.normalize("Plugin_x86_64"), "Plugin")

    def test_strips_64bit(self):
        self.assertEqual(plugin_cleanup.normalize("Plugin_64bit"), "Plugin")

    def test_strips_64_dash_bit(self):
        self.assertEqual(plugin_cleanup.normalize("Plugin_64-bit"), "Plugin")

    def test_strips_bare_64(self):
        self.assertEqual(plugin_cleanup.normalize("Plugin_64"), "Plugin")

    def test_strips_space_separator(self):
        self.assertEqual(plugin_cleanup.normalize("Plugin 64"), "Plugin")

    def test_case_insensitive(self):
        self.assertEqual(plugin_cleanup.normalize("Plugin_X64"), "Plugin")

    def test_no_match_returns_unchanged(self):
        self.assertEqual(plugin_cleanup.normalize("Plugin"), "Plugin")

    def test_only_strips_trailing_suffix(self):
        # x64 in the middle is part of the name — must not strip
        self.assertEqual(plugin_cleanup.normalize("Plugin_x64_Mono"), "Plugin_x64_Mono")

    def test_no_match_when_only_digit(self):
        # "Plugin_5" should not match the 64 alternative
        self.assertEqual(plugin_cleanup.normalize("Plugin_5"), "Plugin_5")


class ClassifyVst2Tests(unittest.TestCase):
    """The decision boundary between dupe (deletable) and keep (NEVER touch)."""

    @staticmethod
    def _paths(stems, ext):
        return [Path(f"/fake/{s}{ext}") for s in stems]

    def test_exact_stem_match_is_dupe(self):
        vst2 = self._paths(["Foo"], ".vst")
        vst3 = self._paths(["Foo"], ".vst3")
        dupes, keep = plugin_cleanup.classify_vst2(vst2, vst3)
        self.assertEqual([p.stem for p in dupes], ["Foo"])
        self.assertEqual(keep, [])

    def test_suffix_normalized_match_is_dupe(self):
        # Common vendor pattern: VST2 has _x64 suffix, VST3 doesn't
        vst2 = self._paths(["Valhalla_x64"], ".vst")
        vst3 = self._paths(["Valhalla"], ".vst3")
        dupes, keep = plugin_cleanup.classify_vst2(vst2, vst3)
        self.assertEqual([p.stem for p in dupes], ["Valhalla_x64"])
        self.assertEqual(keep, [])

    def test_no_twin_is_never_a_dupe(self):
        """The critical no-data-loss invariant.

        If a VST2 has no VST3 counterpart (paid plugin with a
        VST2-only license, vendor that hasn't shipped VST3 yet, etc.),
        classify_vst2 must classify it as keep, NEVER as dupe.
        """
        vst2 = self._paths(["LonelyPaid", "AnotherLonely_x64", "VendorWithSpace 64"], ".vst")
        vst3 = self._paths(["UnrelatedPlugin"], ".vst3")
        dupes, keep = plugin_cleanup.classify_vst2(vst2, vst3)

        self.assertEqual(
            dupes, [],
            "VST2 without a matching VST3 stem must NEVER appear in dupes",
        )
        self.assertEqual(len(keep), 3)
        self.assertEqual(
            {p.stem for p in keep},
            {"LonelyPaid", "AnotherLonely_x64", "VendorWithSpace 64"},
        )

    def test_partial_overlap_keeps_no_twin_entries(self):
        # Foo and Bar have twins; Lonely doesn't.
        vst2 = self._paths(["Foo", "Bar_x64", "Lonely"], ".vst")
        vst3 = self._paths(["Foo", "Bar"], ".vst3")
        dupes, keep = plugin_cleanup.classify_vst2(vst2, vst3)
        self.assertEqual({p.stem for p in dupes}, {"Foo", "Bar_x64"})
        self.assertEqual([p.stem for p in keep], ["Lonely"])

    def test_empty_inputs(self):
        dupes, keep = plugin_cleanup.classify_vst2([], [])
        self.assertEqual((dupes, keep), ([], []))

    def test_no_vst3_means_everything_kept(self):
        vst2 = self._paths(["A", "B", "C"], ".vst")
        dupes, keep = plugin_cleanup.classify_vst2(vst2, [])
        self.assertEqual(dupes, [])
        self.assertEqual(len(keep), 3)


class ScanAndCandidatesIntegrationTests(unittest.TestCase):
    """End-to-end via monkey-patched FORMATS pointing at a tmpdir."""

    def setUp(self):
        self.tmpdir = tempfile.TemporaryDirectory()
        root = Path(self.tmpdir.name)
        (root / "Components").mkdir()
        (root / "VST").mkdir()
        (root / "VST3").mkdir()
        (root / "AAX").mkdir()

        # Fixture layout:
        #   Foo:                VST + VST3        → VST2 IS a dupe
        #   Bar:                VST (_x64) + VST3 → VST2 IS a dupe (suffix-normalized)
        #   ValhallaPaidOnly:   VST only          → KEEP (no twin)
        #   StandalonePro_x64:  VST only          → KEEP (no twin, has suffix)
        #   BazVst3Only:        VST3 only         → irrelevant (not in vst2 scan)
        #   ProToolsBundle:     AAX               → returned in --format aax
        (root / "VST" / "Foo.vst").write_text("")
        (root / "VST" / "Bar_x64.vst").write_text("")
        (root / "VST" / "ValhallaPaidOnly.vst").write_text("")
        (root / "VST" / "StandalonePro_x64.vst").write_text("")
        (root / "VST" / "stray.txt").write_text("")  # should be ignored by .vst filter
        (root / "VST3" / "Foo.vst3").mkdir()
        (root / "VST3" / "Bar.vst3").mkdir()
        (root / "VST3" / "BazVst3Only.vst3").mkdir()
        (root / "AAX" / "ProToolsBundle.aaxplugin").mkdir()

        self.formats_patch = patch.dict(plugin_cleanup.FORMATS, {
            "au":   {"dir": root / "Components", "ext": ".component", "recursive": False},
            "vst2": {"dir": root / "VST",        "ext": ".vst",       "recursive": False},
            "vst3": {"dir": root / "VST3",       "ext": ".vst3",      "recursive": False},
            "aax":  {"dir": root / "AAX",        "ext": ".aaxplugin", "recursive": True},
        })
        self.formats_patch.start()

    def tearDown(self):
        self.formats_patch.stop()
        self.tmpdir.cleanup()

    def test_scan_filters_by_extension(self):
        vst2 = plugin_cleanup.scan("vst2")
        self.assertEqual(
            {p.stem for p in vst2},
            {"Foo", "Bar_x64", "ValhallaPaidOnly", "StandalonePro_x64"},
            "stray.txt must be excluded by the .vst extension filter",
        )

    def test_scan_returns_empty_for_missing_dir(self):
        # AU dir was made empty in setUp
        self.assertEqual(plugin_cleanup.scan("au"), [])

    def test_candidates_vst2_only_returns_dupes_not_keeps(self):
        groups = plugin_cleanup.candidates("vst2")
        stems = {p.stem for p in groups["vst2"]}
        self.assertEqual(
            stems, {"Foo", "Bar_x64"},
            "Only twin-matched VST2 plugins should be removal candidates",
        )

    def test_paid_no_twin_is_never_a_candidate(self):
        """The flagship data-loss assertion.

        A paid plugin's .vst with no matching .vst3 must never reach
        the deletion path under any scope.
        """
        for scope in ("vst2", "all"):
            with self.subTest(scope=scope):
                groups = plugin_cleanup.candidates(scope)
                vst2_stems = {p.stem for p in groups.get("vst2", [])}
                self.assertNotIn("ValhallaPaidOnly", vst2_stems)
                self.assertNotIn("StandalonePro_x64", vst2_stems)

    def test_candidates_aax_returns_all_aax(self):
        groups = plugin_cleanup.candidates("aax")
        self.assertEqual({p.stem for p in groups["aax"]}, {"ProToolsBundle"})

    def test_candidates_all_combines_vst2_and_aax_only(self):
        groups = plugin_cleanup.candidates("all")
        self.assertEqual(set(groups.keys()), {"vst2", "aax"})
        self.assertNotIn("au", groups, "AU is protected — never a removal target")
        self.assertNotIn("vst3", groups, "VST3 is protected — never a removal target")


if __name__ == "__main__":
    unittest.main(verbosity=2 if "-v" in sys.argv else 1)
