#!/usr/bin/env python3

from __future__ import annotations

import pathlib
import shutil
import subprocess
import tempfile
import textwrap
import unittest


REPO_ROOT = pathlib.Path(__file__).resolve().parent.parent
BUMP_SCRIPT = REPO_ROOT / "scripts" / "bump-formula.py"


def write_single_arch_formula(path: pathlib.Path) -> None:
    path.write_text(
        textwrap.dedent(
            """\
            class Demo < Formula
              desc "demo"
              homepage "https://example.com"
              url "https://github.com/block/demo/releases/download/v0.1.0/demo-v0.1.0.tar.gz"
              sha256 "0000000000000000000000000000000000000000000000000000000000000000"
              license "Apache-2.0"
              version "0.1.0"
            end
            """
        )
    )


class BumpFormulaCliRegressionTests(unittest.TestCase):
    maxDiff = None

    def setUp(self) -> None:
        self._sandbox = pathlib.Path(tempfile.mkdtemp(prefix="bump-formula-test."))
        (self._sandbox / "Formula").mkdir(parents=True, exist_ok=True)

    def tearDown(self) -> None:
        shutil.rmtree(self._sandbox)

    def run_bump(self, *args: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            ["python3", str(BUMP_SCRIPT), *args],
            cwd=self._sandbox,
            capture_output=True,
            text=True,
            check=False,
        )

    def test_single_arch_updates_fields_with_provided_sha(self) -> None:
        formula_file = self._sandbox / "Formula" / "demo.rb"
        expected = self._sandbox / "expected.rb"

        write_single_arch_formula(formula_file)
        expected.write_text(
            textwrap.dedent(
                """\
                class Demo < Formula
                  desc "demo"
                  homepage "https://example.com"
                  url "https://github.com/block/demo/releases/download/v1.2.3/demo-v1.2.3.tar.gz"
                  sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
                  license "Apache-2.0"
                  version "1.2.3"
                end
                """
            )
        )

        result = self.run_bump(
            "--formula",
            "demo",
            "--version",
            "1.2.3",
            "--tag",
            "v1.2.3",
            "--artifact-url",
            "https://github.com/block/demo/releases/download/v1.2.3/demo-v1.2.3.tar.gz",
            "--sha256",
            "a" * 64,
        )

        self.assertEqual(result.returncode, 0, msg=result.stderr)
        self.assertEqual(formula_file.read_text(), expected.read_text())
        self.assertIn("from version 0.1.0 to 1.2.3", result.stdout)
        self.assertIn("from tag v0.1.0 to v1.2.3", result.stdout)
        self.assertIn("Updated Formula/demo.rb", result.stderr)

    def test_single_arch_requires_artifact_url(self) -> None:
        formula_file = self._sandbox / "Formula" / "demo.rb"
        write_single_arch_formula(formula_file)

        result = self.run_bump("--formula", "demo", "--version", "1.2.3", "--tag", "v1.2.3")

        self.assertEqual(result.returncode, 1)
        self.assertIn("--artifact-url is required for single-arch formulas", result.stderr)

    def test_rejects_invalid_sha256(self) -> None:
        formula_file = self._sandbox / "Formula" / "demo.rb"
        write_single_arch_formula(formula_file)

        result = self.run_bump(
            "--formula",
            "demo",
            "--version",
            "1.2.3",
            "--tag",
            "v1.2.3",
            "--artifact-url",
            "https://github.com/block/demo/releases/download/v1.2.3/demo-v1.2.3.tar.gz",
            "--sha256",
            "not-a-sha",
        )

        self.assertEqual(result.returncode, 1)
        self.assertIn("sha256 must be a 64-character lowercase hex string", result.stderr)

    def test_rejects_non_https_artifact_url(self) -> None:
        formula_file = self._sandbox / "Formula" / "demo.rb"
        write_single_arch_formula(formula_file)

        result = self.run_bump(
            "--formula",
            "demo",
            "--version",
            "1.2.3",
            "--tag",
            "v1.2.3",
            "--artifact-url",
            "http://example.com/demo.tar.gz",
            "--sha256",
            "a" * 64,
        )

        self.assertEqual(result.returncode, 1)
        self.assertIn("artifact_url must start with https://", result.stderr)

    def test_only_target_formula_is_changed(self) -> None:
        formula_file = self._sandbox / "Formula" / "demo.rb"
        other_file = self._sandbox / "Formula" / "other.rb"
        write_single_arch_formula(formula_file)
        other_file.write_text(
            textwrap.dedent(
                """\
                class Other < Formula
                  desc "other"
                  homepage "https://example.com"
                  url "https://github.com/block/other/releases/download/v9.9.9/other.tar.gz"
                  sha256 "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
                  license "Apache-2.0"
                  version "9.9.9"
                end
                """
            )
        )
        other_before = other_file.read_text()

        result = self.run_bump(
            "--formula",
            "demo",
            "--version",
            "1.2.3",
            "--tag",
            "v1.2.3",
            "--artifact-url",
            "https://github.com/block/demo/releases/download/v1.2.3/demo-v1.2.3.tar.gz",
            "--sha256",
            "a" * 64,
        )

        self.assertEqual(result.returncode, 0, msg=result.stderr)
        self.assertEqual(other_file.read_text(), other_before)

    def test_single_arch_computes_sha256_from_live_release(self) -> None:
        formula_file = self._sandbox / "Formula" / "demo.rb"
        write_single_arch_formula(formula_file)

        expected_formula = textwrap.dedent(
            """\
            class Demo < Formula
              desc "demo"
              homepage "https://example.com"
              url "https://github.com/block/stoic/releases/download/v0.9.1/stoic-release.tar.gz"
              sha256 "d5e3b99bfed472acd0b474d4e447b326c4c3e039712375b8b986c2887fac3871"
              license "Apache-2.0"
              version "0.9.1"
            end
            """
        )

        result = self.run_bump(
            "--formula",
            "demo",
            "--version",
            "0.9.1",
            "--tag",
            "v0.9.1",
            "--artifact-url",
            "https://github.com/block/stoic/releases/download/v0.9.1/stoic-release.tar.gz",
        )

        self.assertEqual(result.returncode, 0, msg=result.stderr)
        self.assertEqual(formula_file.read_text(), expected_formula)
        self.assertEqual(
            result.stdout,
            "from version 0.1.0 to 0.9.1\nfrom tag v0.1.0 to v0.9.1\n",
        )
        self.assertEqual(
            result.stderr,
            "Computing SHA256 from https://github.com/block/stoic/releases/download/v0.9.1/stoic-release.tar.gz\nUpdated Formula/demo.rb\n",
        )

    def test_multi_arch_rewrites_each_url_and_sha_with_live_release(self) -> None:
        formula_file = self._sandbox / "Formula" / "multi.rb"
        formula_file.write_text(
            textwrap.dedent(
                """\
                class Multi < Formula
                  desc "multi"
                  homepage "https://example.com"
                  license "Apache-2.0"
                  version "0.0.0"

                  on_macos do
                    if Hardware::CPU.arm?
                      url "https://github.com/block/lhm/releases/download/v0.0.0/lhm-aarch64-apple-darwin.bz2"
                      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
                    else
                      url "https://github.com/block/lhm/releases/download/v0.0.0/lhm-x86_64-apple-darwin.bz2"
                      sha256 "1111111111111111111111111111111111111111111111111111111111111111"
                    end
                  end
                end
                """
            )
        )

        expected_formula = textwrap.dedent(
            """\
            class Multi < Formula
              desc "multi"
              homepage "https://example.com"
              license "Apache-2.0"
              version "0.7.1"

              on_macos do
                if Hardware::CPU.arm?
                  url "https://github.com/block/lhm/releases/download/v0.7.1/lhm-aarch64-apple-darwin.bz2"
                  sha256 "3bcdbe995fde97d9f55e559c85f265fa1984843530331d58f488a8bf7fbb319c"
                else
                  url "https://github.com/block/lhm/releases/download/v0.7.1/lhm-x86_64-apple-darwin.bz2"
                  sha256 "126854a429cac93ff056f6615787626971dfc72e4b23b78bb0b989548f9f181d"
                end
              end
            end
            """
        )

        result = self.run_bump("--formula", "multi", "--version", "0.7.1", "--tag", "v0.7.1")

        self.assertEqual(result.returncode, 0, msg=result.stderr)
        self.assertEqual(formula_file.read_text(), expected_formula)
        self.assertEqual(
            result.stdout,
            "from version 0.0.0 to 0.7.1\nfrom tag v0.0.0 to v0.7.1\n",
        )
        self.assertEqual(
            result.stderr,
            "Computing SHA256 from https://github.com/block/lhm/releases/download/v0.7.1/lhm-aarch64-apple-darwin.bz2\n"
            "Computing SHA256 from https://github.com/block/lhm/releases/download/v0.7.1/lhm-x86_64-apple-darwin.bz2\n"
            "Updated Formula/multi.rb\n",
        )

    def test_missing_formula_file_fails(self) -> None:
        result = self.run_bump(
            "--formula",
            "does-not-exist",
            "--version",
            "1.0.0",
            "--tag",
            "v1.0.0",
            "--artifact-url",
            "https://github.com/block/demo/releases/download/v1.0.0/demo.tar.gz",
            "--sha256",
            "a" * 64,
        )

        self.assertEqual(result.returncode, 1)
        self.assertIn("Formula/does-not-exist.rb does not exist", result.stderr)


if __name__ == "__main__":
    unittest.main(verbosity=2)
