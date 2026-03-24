from __future__ import annotations

import os
import pathlib
import shutil
import subprocess
import tempfile
import textwrap
import unittest

from scripts.test_helpers import install_fake_gh, install_fake_git


REPO_ROOT = pathlib.Path(__file__).resolve().parent.parent
ORCHESTRATOR_SCRIPT = REPO_ROOT / "scripts" / "bump-and-pr.py"


class BumpCaskAndPrScriptTests(unittest.TestCase):
    maxDiff = None

    def setUp(self) -> None:
        self._sandbox = pathlib.Path(tempfile.mkdtemp(prefix="bump-cask-and-pr-test."))
        (self._sandbox / "Casks").mkdir(parents=True, exist_ok=True)

        self._fake_bin = self._sandbox / "fake-bin"
        self._fake_bin.mkdir(parents=True, exist_ok=True)

        self._command_log = self._sandbox / "commands.log"
        self._command_log.touch()
        self._pr_body_log = self._sandbox / "pr-body.log"
        self._pr_body_log.touch()

        install_fake_git(self._fake_bin, changed_path="Casks/demo.rb")
        install_fake_gh(self._fake_bin)

    def tearDown(self) -> None:
        shutil.rmtree(self._sandbox)

    def write_cask(self, cask_name: str, sha256: str) -> None:
        (self._sandbox / "Casks" / f"{cask_name}.rb").write_text(
            textwrap.dedent(
                f"""\
                cask "{cask_name}" do
                  version "0.1.0"
                  url "https://github.com/block/{cask_name}/releases/download/{cask_name}-0.1.0/{cask_name.capitalize()}-0.1.0-arm64.zip"
                  sha256 "{sha256}"
                end
                """
            )
        )

    def run_script(self, **overrides: str | None) -> subprocess.CompletedProcess[str]:
        env = os.environ.copy()
        env.update(
            {
                "PATH": f"{self._fake_bin}{os.pathsep}{env.get('PATH', '')}",
                "COMMAND_LOG": str(self._command_log),
                "PR_BODY_LOG": str(self._pr_body_log),
                "FAKE_GIT_HAS_CHANGES": "true",
                "FAKE_EXISTING_PR_URL": "null",
                "FAKE_CREATED_PR_URL": "https://github.com/block/homebrew-tap/pull/123",
                "BUMP_TYPE": "cask",
                "BUMP_NAME": "demo",
                "REPO": "block/demo",
                "NEW_TAG": "demo-1.2.3",
                "ARTIFACT_URL": "https://github.com/block/demo/releases/download/demo-1.2.3/Demo-1.2.3-arm64.zip",
                "INPUT_SHA256": "a" * 64,
                "PR_BASE": "main",
                "PR_REPO": "block/homebrew-tap",
                "GH_TOKEN": "test-token",
            }
        )

        for key, value in overrides.items():
            if value is None:
                env.pop(key, None)
            else:
                env[key] = value

        return subprocess.run(
            ["python3", str(ORCHESTRATOR_SCRIPT)],
            cwd=self._sandbox,
            env=env,
            capture_output=True,
            text=True,
            check=False,
        )

    def read_commands(self) -> list[str]:
        return [line for line in self._command_log.read_text().splitlines() if line]

    def test_happy_path_creates_pr_and_writes_expected_body(self) -> None:
        self.write_cask("demo", "b" * 64)

        result = self.run_script()

        self.assertEqual(result.returncode, 0, msg=result.stderr)
        self.assertEqual(result.stdout, "Pull request created: https://github.com/block/homebrew-tap/pull/123\n")

        expected_sha = "a" * 64
        cask_contents = (self._sandbox / "Casks" / "demo.rb").read_text()
        self.assertIn('version "1.2.3"', cask_contents)
        self.assertIn('url "https://github.com/block/demo/releases/download/demo-1.2.3/Demo-1.2.3-arm64.zip"', cask_contents)
        self.assertIn(f'sha256 "{expected_sha}"', cask_contents)

        commands = self.read_commands()
        self.assertIn("git status --porcelain", commands)
        self.assertIn("git commit -m Bump demo to 1.2.3", commands)
        self.assertTrue(any(command.startswith("gh pr create ") for command in commands))

        pr_body = self._pr_body_log.read_text()
        self.assertIn("https://github.com/block/demo/compare/demo-0.1.0...demo-1.2.3", pr_body)
        self.assertIn("Artifact: https://github.com/block/demo/releases/download/demo-1.2.3/Demo-1.2.3-arm64.zip", pr_body)
        self.assertIn(f"SHA256: {expected_sha}", pr_body)
        self.assertIn("brew install --cask block/tap/demo", pr_body)

    def test_existing_pr_is_updated(self) -> None:
        self.write_cask("demo", "b" * 64)

        result = self.run_script(FAKE_EXISTING_PR_URL="https://github.com/block/homebrew-tap/pull/901")

        self.assertEqual(result.returncode, 0, msg=result.stderr)
        self.assertEqual(result.stdout, "Pull request updated: https://github.com/block/homebrew-tap/pull/901\n")

        commands = self.read_commands()
        self.assertTrue(any(command.startswith("gh pr edit ") for command in commands))
        self.assertFalse(any(command.startswith("gh pr create ") for command in commands))

    def test_no_changes_skips_pr(self) -> None:
        self.write_cask("demo", "b" * 64)

        result = self.run_script(FAKE_GIT_HAS_CHANGES="false")

        self.assertEqual(result.returncode, 0, msg=result.stderr)
        self.assertIn("No pull request was created because no cask changes were detected.", result.stdout)

    def test_empty_created_pr_url_fails(self) -> None:
        self.write_cask("demo", "b" * 64)

        result = self.run_script(FAKE_CREATED_PR_URL="")

        self.assertEqual(result.returncode, 1)
        self.assertIn("Cask changes were committed and pushed, but no pull request URL was returned.", result.stderr)

    def test_missing_required_env_var_fails(self) -> None:
        self.write_cask("demo", "e" * 64)

        result = self.run_script(REPO=None)

        self.assertEqual(result.returncode, 1)
        self.assertIn("Missing required environment variable: REPO", result.stderr)

    def test_missing_gh_token_fails(self) -> None:
        self.write_cask("demo", "e" * 64)

        result = self.run_script(GH_TOKEN=None)

        self.assertEqual(result.returncode, 1)
        self.assertIn("Missing required environment variable: GH_TOKEN", result.stderr)

    def test_requires_artifact_url(self) -> None:
        self.write_cask("demo", "e" * 64)

        result = self.run_script(ARTIFACT_URL="")

        self.assertEqual(result.returncode, 1)
        self.assertIn("Missing required environment variable: ARTIFACT_URL", result.stderr)

    def test_fails_when_cask_sha256_cannot_be_read(self) -> None:
        (self._sandbox / "Casks" / "demo.rb").write_text(
            textwrap.dedent(
                """\
                cask "demo" do
                  version "0.1.0"
                  url "https://example.com/demo.zip"
                end
                """
            )
        )

        result = self.run_script()

        self.assertEqual(result.returncode, 1)
        self.assertIn("Unable to update sha256 in Casks/demo.rb", result.stderr)
