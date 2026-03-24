#!/usr/bin/env python3

from __future__ import annotations

import contextlib
import importlib.util
import io
import os
import pathlib
import shutil
import subprocess
import tempfile
import textwrap
import unittest
from unittest import mock


REPO_ROOT = pathlib.Path(__file__).resolve().parent.parent
ORCHESTRATOR_SCRIPT = REPO_ROOT / "scripts" / "bump-and-pr.py"


class BumpFormulaAndPrScriptTests(unittest.TestCase):
    maxDiff = None

    def setUp(self) -> None:
        self._sandbox = pathlib.Path(tempfile.mkdtemp(prefix="bump-formula-and-pr-test."))
        (self._sandbox / "Formula").mkdir(parents=True, exist_ok=True)

        self._fake_bin = self._sandbox / "fake-bin"
        self._fake_bin.mkdir(parents=True, exist_ok=True)

        self._command_log = self._sandbox / "commands.log"
        self._command_log.touch()
        self._pr_body_log = self._sandbox / "pr-body.log"
        self._pr_body_log.touch()

        self._install_fake_git()
        self._install_fake_gh()

    def tearDown(self) -> None:
        shutil.rmtree(self._sandbox)

    def _install_fake_git(self) -> None:
        fake_git = self._fake_bin / "git"
        fake_git.write_text(
            "#!/usr/bin/env bash\n"
            "set -euo pipefail\n"
            "echo \"git $*\" >> \"$COMMAND_LOG\"\n"
            "case \"${1:-}\" in\n"
            "  status)\n"
            "    if [[ \"${2:-}\" == \"--porcelain\" ]]; then\n"
            "      if [[ \"${FAKE_GIT_HAS_CHANGES:-true}\" == \"true\" ]]; then\n"
            "        printf ' M Formula/demo.rb\\n'\n"
            "      fi\n"
            "      exit 0\n"
            "    fi\n"
            "    ;;\n"
            "  config|checkout|add|commit|push)\n"
            "    exit 0\n"
            "    ;;\n"
            "esac\n"
            "echo \"unexpected git invocation: $*\" >&2\n"
            "exit 1\n"
        )
        fake_git.chmod(0o755)

    def _install_fake_gh(self) -> None:
        fake_gh = self._fake_bin / "gh"
        fake_gh.write_text(
            "#!/usr/bin/env bash\n"
            "set -euo pipefail\n"
            "echo \"gh $*\" >> \"$COMMAND_LOG\"\n"
            "capture_body() {\n"
            "  local body_file=\"\"\n"
            "  local i=1\n"
            "  while [[ $i -le $# ]]; do\n"
            "    local arg=\"${!i}\"\n"
            "    if [[ \"$arg\" == \"--body-file\" ]]; then\n"
            "      i=$((i + 1))\n"
            "      body_file=\"${!i}\"\n"
            "      break\n"
            "    fi\n"
            "    i=$((i + 1))\n"
            "  done\n"
            "  if [[ -n \"$body_file\" ]]; then\n"
            "    {\n"
            "      echo \"PR_BODY_START\"\n"
            "      cat \"$body_file\"\n"
            "      echo \"PR_BODY_END\"\n"
            "    } >> \"$PR_BODY_LOG\"\n"
            "  fi\n"
            "}\n"
            "if [[ \"${1:-}\" == \"pr\" && \"${2:-}\" == \"list\" ]]; then\n"
            "  printf '%s\\n' \"${FAKE_EXISTING_PR_URL:-null}\"\n"
            "  exit 0\n"
            "fi\n"
            "if [[ \"${1:-}\" == \"pr\" && \"${2:-}\" == \"edit\" ]]; then\n"
            "  capture_body \"$@\"\n"
            "  exit 0\n"
            "fi\n"
            "if [[ \"${1:-}\" == \"pr\" && \"${2:-}\" == \"create\" ]]; then\n"
            "  capture_body \"$@\"\n"
            "  printf '%s\\n' \"${FAKE_CREATED_PR_URL:-}\"\n"
            "  exit 0\n"
            "fi\n"
            "echo \"unexpected gh invocation: $*\" >&2\n"
            "exit 1\n"
        )
        fake_gh.chmod(0o755)

    def write_formula(self, formula_name: str, sha256: str) -> None:
        (self._sandbox / "Formula" / f"{formula_name}.rb").write_text(
            textwrap.dedent(
                f"""\
                class {formula_name.capitalize()} < Formula
                  url "https://github.com/block/{formula_name}/releases/download/v0.1.0/{formula_name}-v0.1.0.tar.gz"
                  sha256 "{sha256}"
                  version "0.1.0"
                end
                """
            )
        )

    def write_multi_arch_formula(self, formula_name: str, arm_sha: str, intel_sha: str) -> None:
        (self._sandbox / "Formula" / f"{formula_name}.rb").write_text(
            textwrap.dedent(
                f"""\
                class {formula_name.capitalize()} < Formula
                  on_arm do
                    url "https://github.com/block/{formula_name}/releases/download/v0.1.0/{formula_name}-v0.1.0-arm64.tar.gz"
                    sha256 "{arm_sha}"
                  end

                  on_intel do
                    url "https://github.com/block/{formula_name}/releases/download/v0.1.0/{formula_name}-v0.1.0-amd64.tar.gz"
                    sha256 "{intel_sha}"
                  end

                  version "0.1.0"
                end
                """
            )
        )

    def load_script_module(self):
        spec = importlib.util.spec_from_file_location("bump_and_pr", ORCHESTRATOR_SCRIPT)
        self.assertIsNotNone(spec)
        self.assertIsNotNone(spec.loader)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        return module

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
                "BUMP_TYPE": "formula",
                "BUMP_NAME": "demo",
                "REPO": "block/demo",
                "NEW_TAG": "v1.2.3",
                "ARTIFACT_URL": "https://github.com/block/demo/releases/download/v1.2.3/demo-v1.2.3.tar.gz",
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
        self.write_formula("demo", "b" * 64)

        result = self.run_script()

        self.assertEqual(result.returncode, 0, msg=result.stderr)
        self.assertEqual(result.stdout, "Pull request created: https://github.com/block/homebrew-tap/pull/123\n")

        expected_sha = "a" * 64
        formula_contents = (self._sandbox / "Formula" / "demo.rb").read_text()
        self.assertIn('url "https://github.com/block/demo/releases/download/v1.2.3/demo-v1.2.3.tar.gz"', formula_contents)
        self.assertIn(f'sha256 "{expected_sha}"', formula_contents)
        self.assertIn('version "1.2.3"', formula_contents)

        commands = self.read_commands()
        self.assertIn("git status --porcelain", commands)
        self.assertIn("git commit --signoff -m Bump demo to 1.2.3", commands)
        self.assertTrue(any(command.startswith("gh pr create ") for command in commands))

        pr_body = self._pr_body_log.read_text()
        self.assertIn("https://github.com/block/demo/compare/v0.1.0...v1.2.3", pr_body)
        self.assertIn("Artifact: https://github.com/block/demo/releases/download/v1.2.3/demo-v1.2.3.tar.gz", pr_body)
        self.assertIn(f"SHA256: {expected_sha}", pr_body)
        self.assertIn("brew install block/tap/demo", pr_body)

    def test_existing_pr_is_updated(self) -> None:
        self.write_formula("demo", "b" * 64)

        result = self.run_script(FAKE_EXISTING_PR_URL="https://github.com/block/homebrew-tap/pull/901")

        self.assertEqual(result.returncode, 0, msg=result.stderr)
        self.assertEqual(result.stdout, "Pull request updated: https://github.com/block/homebrew-tap/pull/901\n")

        commands = self.read_commands()
        self.assertTrue(any(command.startswith("gh pr edit ") for command in commands))
        self.assertFalse(any(command.startswith("gh pr create ") for command in commands))

    def test_no_changes_skips_pr(self) -> None:
        self.write_formula("demo", "b" * 64)

        result = self.run_script(FAKE_GIT_HAS_CHANGES="false")

        self.assertEqual(result.returncode, 0, msg=result.stderr)
        self.assertIn("No pull request was created because no formula changes were detected.", result.stdout)

    def test_empty_created_pr_url_fails(self) -> None:
        self.write_formula("demo", "b" * 64)

        result = self.run_script(FAKE_CREATED_PR_URL="")

        self.assertEqual(result.returncode, 1)
        self.assertIn("Formula changes were committed and pushed, but no pull request URL was returned.", result.stderr)

    def test_missing_required_env_var_fails(self) -> None:
        self.write_formula("demo", "e" * 64)

        result = self.run_script(REPO=None)

        self.assertEqual(result.returncode, 1)
        self.assertIn("Missing required environment variable: REPO", result.stderr)

    def test_single_arch_requires_artifact_url(self) -> None:
        self.write_formula("demo", "e" * 64)

        result = self.run_script(ARTIFACT_URL="")

        self.assertEqual(result.returncode, 1)
        self.assertIn("--artifact-url is required for single-arch formulas", result.stderr)

    def test_fails_when_formula_sha256_cannot_be_read(self) -> None:
        (self._sandbox / "Formula" / "demo.rb").write_text(
            textwrap.dedent(
                """\
                class Demo < Formula
                  url "https://example.com/demo.tar.gz"
                  version "0.1.0"
                end
                """
            )
        )

        result = self.run_script()

        self.assertEqual(result.returncode, 1)
        self.assertIn("Unable to update sha256 in Formula/demo.rb", result.stderr)

    def test_multi_arch_formula_pr_body_uses_updated_artifacts(self) -> None:
        self.write_multi_arch_formula("demo", "b" * 64, "c" * 64)
        module = self.load_script_module()

        new_arm_url = "https://github.com/block/demo/releases/download/v1.2.3/demo-v1.2.3-arm64.tar.gz"
        new_intel_url = "https://github.com/block/demo/releases/download/v1.2.3/demo-v1.2.3-amd64.tar.gz"
        expected_artifacts = [
            (new_arm_url, "d" * 64),
            (new_intel_url, "e" * 64),
        ]
        sha_lookup = {url: sha for url, sha in expected_artifacts}

        old_cwd = pathlib.Path.cwd()
        os.chdir(self._sandbox)
        try:
            # Avoid real network/download work in unit tests: remote assets,
            # outages, and rate limits would make this path flaky and slow.
            # The resolver is mocked so this test stays deterministic while
            # still verifying URL replacement and PR-body rendering logic.
            with mock.patch.object(module, "resolve_sha256", side_effect=lambda _sha, url: sha_lookup[url]):
                old_tag, artifacts = module.bump_formula_file(
                    formula_name="demo",
                    new_version="1.2.3",
                    new_tag="v1.2.3",
                    artifact_url="",
                    input_sha256="",
                )
        finally:
            os.chdir(old_cwd)

        self.assertEqual(old_tag, "v0.1.0")
        self.assertEqual(artifacts, expected_artifacts)

        formula_contents = (self._sandbox / "Formula" / "demo.rb").read_text()
        self.assertIn(f'url "{new_arm_url}"', formula_contents)
        self.assertIn(f'url "{new_intel_url}"', formula_contents)
        self.assertIn(f'sha256 "{expected_artifacts[0][1]}"', formula_contents)
        self.assertIn(f'sha256 "{expected_artifacts[1][1]}"', formula_contents)
        self.assertIn('version "1.2.3"', formula_contents)

        pr_body = module.make_pr_body(
            repo="block/demo",
            old_tag="v0.1.0",
            new_tag="v1.2.3",
            artifacts=artifacts,
            branch="bump-demo-to-1.2.3",
            install_command="brew install block/tap/demo",
        )

        self.assertIn("Artifacts:", pr_body)
        self.assertIn(new_arm_url, pr_body)
        self.assertIn(new_intel_url, pr_body)
        self.assertIn("d" * 64, pr_body)
        self.assertIn("e" * 64, pr_body)
        self.assertNotIn("Artifact: ", pr_body)

    def test_compute_sha256_surfaces_download_errors(self) -> None:
        module = self.load_script_module()

        with mock.patch.object(module.brew_utils.urllib.request, "urlopen", side_effect=OSError("timed out")):
            with self.assertRaises(OSError):
                module.compute_sha256("https://example.com/demo.tar.gz")

    def test_validate_artifact_url_rejects_non_https(self) -> None:
        module = self.load_script_module()

        stderr = io.StringIO()
        with contextlib.redirect_stderr(stderr):
            with self.assertRaises(SystemExit) as exit_context:
                module.validate_artifact_url("http://example.com/demo.tar.gz")

        self.assertEqual(exit_context.exception.code, 1)
        self.assertIn("artifact_url must start with https://", stderr.getvalue())


if __name__ == "__main__":
    unittest.main(verbosity=2)
