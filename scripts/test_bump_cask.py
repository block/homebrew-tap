#!/usr/bin/env python3

from __future__ import annotations

import textwrap
import unittest

from test_helpers import REPO_ROOT, BumpTestBase


SAMPLE_CASK = textwrap.dedent(
    """\
    cask "demo" do
      version "0.1.0"
      url "https://github.com/block/demo/releases/download/demo-0.1.0/Demo-0.1.0-arm64.zip"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"

      name "Demo"
      desc "A demo app"
      homepage "https://github.com/block/demo"

      depends_on arch: :arm64

      app "Demo.app"
    end
    """
)


class BumpCaskCliRegressionTests(BumpTestBase):
    SCRIPT = REPO_ROOT / "scripts" / "bump-cask.py"
    DIR_NAME = "Casks"
    CLI_FLAG = "--cask"

    def test_updates_fields_with_provided_sha(self) -> None:
        self.rb_path("demo").write_text(SAMPLE_CASK)

        expected = textwrap.dedent(
            """\
            cask "demo" do
              version "1.2.3"
              url "https://github.com/block/demo/releases/download/demo-1.2.3/Demo-1.2.3-arm64.zip"
              sha256 "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

              name "Demo"
              desc "A demo app"
              homepage "https://github.com/block/demo"

              depends_on arch: :arm64

              app "Demo.app"
            end
            """
        )

        result = self.run_bump(
            self.CLI_FLAG, "demo",
            "--version", "1.2.3",
            "--tag", "demo-1.2.3",
            "--artifact-url", "https://github.com/block/demo/releases/download/demo-1.2.3/Demo-1.2.3-arm64.zip",
            "--sha256", "a" * 64,
        )

        self.assertEqual(result.returncode, 0, msg=result.stderr)
        self.assertEqual(self.rb_path("demo").read_text(), expected)
        self.assertIn("from version 0.1.0 to 1.2.3", result.stdout)
        self.assertIn("from tag demo-0.1.0 to demo-1.2.3", result.stdout)
        self.assertIn("Updated Casks/demo.rb", result.stderr)

    def test_rejects_invalid_sha256(self) -> None:
        self.rb_path("demo").write_text(SAMPLE_CASK)

        result = self.run_bump(
            self.CLI_FLAG, "demo",
            "--version", "1.2.3",
            "--tag", "demo-1.2.3",
            "--artifact-url", "https://github.com/block/demo/releases/download/demo-1.2.3/Demo-1.2.3-arm64.zip",
            "--sha256", "not-a-sha",
        )

        self.assertEqual(result.returncode, 1)
        self.assertIn("sha256 must be a 64-character lowercase hex string", result.stderr)

    def test_rejects_non_https_artifact_url(self) -> None:
        self.rb_path("demo").write_text(SAMPLE_CASK)

        result = self.run_bump(
            self.CLI_FLAG, "demo",
            "--version", "1.2.3",
            "--tag", "demo-1.2.3",
            "--artifact-url", "http://example.com/demo.zip",
            "--sha256", "a" * 64,
        )

        self.assertEqual(result.returncode, 1)
        self.assertIn("artifact_url must start with https://", result.stderr)

    def test_only_target_cask_is_changed(self) -> None:
        self.rb_path("demo").write_text(SAMPLE_CASK)
        other = self.rb_path("other")
        other.write_text(
            textwrap.dedent(
                """\
                cask "other" do
                  version "9.9.9"
                  url "https://github.com/block/other/releases/download/other-9.9.9/Other-9.9.9-arm64.zip"
                  sha256 "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"

                  name "Other"
                  app "Other.app"
                end
                """
            )
        )
        other_before = other.read_text()

        result = self.run_bump(
            self.CLI_FLAG, "demo",
            "--version", "1.2.3",
            "--tag", "demo-1.2.3",
            "--artifact-url", "https://github.com/block/demo/releases/download/demo-1.2.3/Demo-1.2.3-arm64.zip",
            "--sha256", "a" * 64,
        )

        self.assertEqual(result.returncode, 0, msg=result.stderr)
        self.assertEqual(other.read_text(), other_before)

    def test_old_tag_unknown_when_url_has_no_release_path(self) -> None:
        self.rb_path("demo").write_text(
            SAMPLE_CASK.replace(
                "https://github.com/block/demo/releases/download/demo-0.1.0/Demo-0.1.0-arm64.zip",
                "https://example.com/demo.zip",
            )
        )

        result = self.run_bump(
            self.CLI_FLAG, "demo",
            "--version", "1.2.3",
            "--tag", "demo-1.2.3",
            "--artifact-url", "https://example.com/demo-new.zip",
            "--sha256", "a" * 64,
        )

        self.assertEqual(result.returncode, 0, msg=result.stderr)
        self.assertIn("from tag unknown to demo-1.2.3", result.stdout)

    def test_missing_cask_file_fails(self) -> None:
        result = self.run_bump(
            self.CLI_FLAG, "does-not-exist",
            "--version", "1.0.0",
            "--tag", "does-not-exist-1.0.0",
            "--artifact-url", "https://github.com/block/demo/releases/download/v1.0.0/demo.zip",
            "--sha256", "a" * 64,
        )

        self.assertEqual(result.returncode, 1)
        self.assertIn("Casks/does-not-exist.rb does not exist", result.stderr)


if __name__ == "__main__":
    unittest.main(verbosity=2)
