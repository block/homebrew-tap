#!/usr/bin/env python3

from __future__ import annotations

import textwrap
import unittest

from test_helpers import REPO_ROOT, BumpTestBase


SAMPLE_FORMULA = textwrap.dedent(
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


class BumpFormulaCliRegressionTests(BumpTestBase):
    SCRIPT = REPO_ROOT / "scripts" / "bump-formula.py"
    DIR_NAME = "Formula"
    CLI_FLAG = "--formula"

    def test_single_arch_updates_fields_with_provided_sha(self) -> None:
        self.rb_path("demo").write_text(SAMPLE_FORMULA)

        expected = textwrap.dedent(
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

        result = self.run_bump(
            self.CLI_FLAG, "demo",
            "--version", "1.2.3",
            "--tag", "v1.2.3",
            "--artifact-url", "https://github.com/block/demo/releases/download/v1.2.3/demo-v1.2.3.tar.gz",
            "--sha256", "a" * 64,
        )

        self.assertEqual(result.returncode, 0, msg=result.stderr)
        self.assertEqual(self.rb_path("demo").read_text(), expected)
        self.assertIn("from version 0.1.0 to 1.2.3", result.stdout)
        self.assertIn("from tag v0.1.0 to v1.2.3", result.stdout)
        self.assertIn("Updated Formula/demo.rb", result.stderr)

    def test_single_arch_requires_artifact_url(self) -> None:
        self.rb_path("demo").write_text(SAMPLE_FORMULA)

        result = self.run_bump(self.CLI_FLAG, "demo", "--version", "1.2.3", "--tag", "v1.2.3")

        self.assertEqual(result.returncode, 1)
        self.assertIn("--artifact-url is required for single-arch formulas", result.stderr)

    def test_rejects_invalid_sha256(self) -> None:
        self.rb_path("demo").write_text(SAMPLE_FORMULA)

        result = self.run_bump(
            self.CLI_FLAG, "demo",
            "--version", "1.2.3",
            "--tag", "v1.2.3",
            "--artifact-url", "https://github.com/block/demo/releases/download/v1.2.3/demo-v1.2.3.tar.gz",
            "--sha256", "not-a-sha",
        )

        self.assertEqual(result.returncode, 1)
        self.assertIn("sha256 must be a 64-character lowercase hex string", result.stderr)

    def test_rejects_non_https_artifact_url(self) -> None:
        self.rb_path("demo").write_text(SAMPLE_FORMULA)

        result = self.run_bump(
            self.CLI_FLAG, "demo",
            "--version", "1.2.3",
            "--tag", "v1.2.3",
            "--artifact-url", "http://example.com/demo.tar.gz",
            "--sha256", "a" * 64,
        )

        self.assertEqual(result.returncode, 1)
        self.assertIn("artifact_url must start with https://", result.stderr)

    def test_only_target_formula_is_changed(self) -> None:
        self.rb_path("demo").write_text(SAMPLE_FORMULA)
        other = self.rb_path("other")
        other.write_text(
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
        other_before = other.read_text()

        result = self.run_bump(
            self.CLI_FLAG, "demo",
            "--version", "1.2.3",
            "--tag", "v1.2.3",
            "--artifact-url", "https://github.com/block/demo/releases/download/v1.2.3/demo-v1.2.3.tar.gz",
            "--sha256", "a" * 64,
        )

        self.assertEqual(result.returncode, 0, msg=result.stderr)
        self.assertEqual(other.read_text(), other_before)

    def test_single_arch_computes_sha256_from_live_release(self) -> None:
        self.rb_path("demo").write_text(SAMPLE_FORMULA)

        expected = textwrap.dedent(
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
            self.CLI_FLAG, "demo",
            "--version", "0.9.1",
            "--tag", "v0.9.1",
            "--artifact-url", "https://github.com/block/stoic/releases/download/v0.9.1/stoic-release.tar.gz",
        )

        self.assertEqual(result.returncode, 0, msg=result.stderr)
        self.assertEqual(self.rb_path("demo").read_text(), expected)
        self.assertEqual(
            result.stdout,
            "from version 0.1.0 to 0.9.1\nfrom tag v0.1.0 to v0.9.1\n",
        )
        self.assertEqual(
            result.stderr,
            "Computing SHA256 from https://github.com/block/stoic/releases/download/v0.9.1/stoic-release.tar.gz\nUpdated Formula/demo.rb\n",
        )

    def test_multi_arch_rewrites_each_url_and_sha_with_live_release(self) -> None:
        self.rb_path("multi").write_text(
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

        expected = textwrap.dedent(
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

        result = self.run_bump(self.CLI_FLAG, "multi", "--version", "0.7.1", "--tag", "v0.7.1")

        self.assertEqual(result.returncode, 0, msg=result.stderr)
        self.assertEqual(self.rb_path("multi").read_text(), expected)
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
            self.CLI_FLAG, "does-not-exist",
            "--version", "1.0.0",
            "--tag", "v1.0.0",
            "--artifact-url", "https://github.com/block/demo/releases/download/v1.0.0/demo.tar.gz",
            "--sha256", "a" * 64,
        )

        self.assertEqual(result.returncode, 1)
        self.assertIn("Formula/does-not-exist.rb does not exist", result.stderr)


if __name__ == "__main__":
    unittest.main(verbosity=2)
