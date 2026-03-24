#!/usr/bin/env python3

from __future__ import annotations

import pathlib
import shutil
import subprocess
import tempfile
import unittest


REPO_ROOT = pathlib.Path(__file__).resolve().parent.parent


class BumpTestBase(unittest.TestCase):
    """Base class for bump-formula and bump-cask regression tests."""

    maxDiff = None

    # Subclasses must set these
    SCRIPT: pathlib.Path
    DIR_NAME: str  # "Formula" or "Casks"
    CLI_FLAG: str  # "--formula" or "--cask"

    def setUp(self) -> None:
        self._sandbox = pathlib.Path(tempfile.mkdtemp(prefix=f"bump-{self.DIR_NAME.lower()}-test."))
        (self._sandbox / self.DIR_NAME).mkdir(parents=True, exist_ok=True)

    def tearDown(self) -> None:
        shutil.rmtree(self._sandbox)

    def run_bump(self, *args: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            ["python3", str(self.SCRIPT), *args],
            cwd=self._sandbox,
            capture_output=True,
            text=True,
            check=False,
        )

    def rb_path(self, name: str) -> pathlib.Path:
        return self._sandbox / self.DIR_NAME / f"{name}.rb"
