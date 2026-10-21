#!/usr/bin/env python3
"""Verify the claims in the repo's markdown against the tree.

Written after a sweep found drift in 14 of 54 docs: 17 references to a
directory renamed long ago, two scripts that no longer exist, counts that had
moved, and install instructions that could not work. Every one of those was
mechanically detectable, which is the argument for this living in CI rather
than in someone's memory.

Checks:
  1. repo-relative path references in backticks resolve
  2. relative markdown links resolve
  3. referenced scripts exist
  4. no references to directories that have been renamed away

Usage:  python3 scripts/check-docs.py [-v]
Exit:   0 clean, 1 if anything failed
"""

import os
import re
import subprocess
import sys

VERBOSE = "-v" in sys.argv

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(REPO)

TOP_LEVEL = {
    "scripts", "config", "terminal", "editors", "mail", "packages",
    "git", "ssh", "docs", "claude", "bootstrap", "task",
}

# Paths that are referenced precisely because they do NOT exist in the repo:
# gitignored secret files, and placeholders in passages about writing docs.
EXPECTED_ABSENT = {
    "config/beets/secrets.yaml",
    "ssh/config.local",
    "docs/TOPIC.md",
    "docs/dev/TOPIC.md",
    "path/file.md",
    "path/to/file.md",
}

# Directories that were renamed. A reference to one is always stale.
RENAMED = {
    "shell/": "terminal/zsh/ (the shell/ directory was renamed)",
}

FENCED = re.compile(r"```.*?```", re.S)
PATH_REF = re.compile(r"`~?/?(?:dotfiles/)?([A-Za-z0-9_.-]+(?:/[A-Za-z0-9_.*-]+)+)`")
LINK = re.compile(r"\[([^\]]*)\]\(([^)]+)\)")
SCRIPT_REF = re.compile(
    r"(?:^|\s)\.?/?((?:scripts|packages|mail/scripts|bootstrap|terminal/zsh)"
    r"/[A-Za-z0-9_.-]+\.(?:sh|py))"
)


def docs():
    out = subprocess.run(
        ["git", "ls-files", "*.md"], capture_output=True, text=True, check=True
    ).stdout
    return [line for line in out.split("\n") if line]


def body(path):
    """Doc text with fenced code blocks removed — those hold illustrative
    examples that are not meant to resolve."""
    return FENCED.sub("", open(path, encoding="utf-8").read())


def check_paths(files):
    failures = []
    checked = 0
    for doc in files:
        for match in PATH_REF.finditer(body(doc)):
            path = match.group(1)
            if path.split("/")[0] not in TOP_LEVEL or "*" in path:
                continue
            checked += 1
            if not os.path.exists(path) and path not in EXPECTED_ABSENT:
                failures.append(f"{doc}: `{path}` does not exist")
    return "path references", checked, failures


def check_links(files):
    failures = []
    checked = 0
    for doc in files:
        for match in LINK.finditer(body(doc)):
            target = match.group(2).split("#")[0].strip()
            if not target or target.startswith(("http", "mailto:", "tel:", "{")):
                continue
            checked += 1
            resolved = os.path.normpath(os.path.join(os.path.dirname(doc), target))
            # Placeholders are written relative to the doc, so compare on the
            # target with any leading ../ stripped rather than the resolved path.
            bare = re.sub(r"^(?:\.\./)+", "", target)
            if not os.path.exists(resolved) and bare not in EXPECTED_ABSENT:
                failures.append(f"{doc}: link -> {target}")
    return "relative links", checked, failures


def check_scripts(files):
    failures = []
    seen = set()
    for doc in files:
        for match in SCRIPT_REF.finditer(open(doc, encoding="utf-8").read()):
            path = match.group(1)
            seen.add(path)
            if not os.path.exists(path):
                failures.append(f"{doc}: references missing script {path}")
    return "script references", len(seen), failures


def check_renamed(files):
    failures = []
    for doc in files:
        text = open(doc, encoding="utf-8").read()
        for stale, replacement in RENAMED.items():
            if f"dotfiles/{stale}" in text:
                count = text.count(f"dotfiles/{stale}")
                failures.append(f"{doc}: {count}x `dotfiles/{stale}` -> use {replacement}")
    return "renamed directories", len(files), failures


def main():
    files = docs()
    print(f"Checking {len(files)} markdown files\n")

    total_failures = []
    for check in (check_paths, check_links, check_scripts, check_renamed):
        name, checked, failures = check(files)
        status = "ok" if not failures else f"{len(failures)} FAILED"
        print(f"  {name:<22} {checked:>4} checked   {status}")
        for failure in failures:
            print(f"      {failure}")
        total_failures.extend(failures)

    print()
    if total_failures:
        print(f"✗ {len(total_failures)} problem(s) found")
        return 1
    print("✓ docs match the tree")
    return 0


if __name__ == "__main__":
    sys.exit(main())
