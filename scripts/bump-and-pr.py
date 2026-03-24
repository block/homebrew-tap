#!/usr/bin/env python3

from __future__ import annotations

import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

import brew_utils


compute_sha256 = brew_utils.compute_sha256
extract_all_fields = brew_utils.extract_all_fields
extract_field = brew_utils.extract_field
extract_release_tag_from_url = brew_utils.extract_release_tag_from_url
fail = brew_utils.fail
replace_nth_field = brew_utils.replace_nth_field
resolve_sha256 = brew_utils.resolve_sha256
update_fields = brew_utils.update_fields
validate_artifact_url = brew_utils.validate_artifact_url


REQUIRED_ENV_VARS = (
    "BUMP_TYPE",
    "BUMP_NAME",
    "REPO",
    "NEW_TAG",
    "PR_BASE",
    "PR_REPO",
    "GH_TOKEN",
)


def require_env(name: str) -> str:
    value = os.environ.get(name)
    if not value:
        fail(f"Missing required environment variable: {name}")
    return value


def derive_new_version(tag: str) -> str:
    match = re.search(r"([0-9]+\.[0-9]+\.[0-9]+)$", tag)
    return match.group(1) if match else tag


def is_multi_arch_formula(contents: str) -> bool:
    return len(extract_all_fields(contents, "url")) > 1


def bump_formula_file(
    *,
    formula_name: str,
    new_version: str,
    new_tag: str,
    artifact_url: str,
    input_sha256: str,
) -> tuple[str, list[tuple[str, str]]]:
    formula_file = Path("Formula") / f"{formula_name}.rb"
    if not formula_file.exists():
        fail(f"{formula_file} does not exist")

    contents = formula_file.read_text()
    old_tag = extract_release_tag_from_url(extract_field(contents, "url", formula_file))
    artifacts: list[tuple[str, str]] = []

    if is_multi_arch_formula(contents):
        old_urls = extract_all_fields(contents, "url")
        source_tag = extract_release_tag_from_url(old_urls[0])
        contents = update_fields(contents, {"version": new_version}, formula_file)
        for i, old_url in enumerate(old_urls):
            new_url = old_url.replace(source_tag, new_tag)
            validate_artifact_url(new_url)
            sha256 = resolve_sha256(None, new_url)
            contents = replace_nth_field(contents, "url", i, new_url, formula_file)
            contents = replace_nth_field(contents, "sha256", i, sha256, formula_file)
            artifacts.append((new_url, sha256))
    else:
        if not artifact_url:
            fail("--artifact-url is required for single-arch formulas")
        validate_artifact_url(artifact_url)
        sha256 = resolve_sha256(input_sha256 or None, artifact_url)
        contents = update_fields(
            contents,
            {
                "url": artifact_url,
                "sha256": sha256,
                "version": new_version,
            },
            formula_file,
        )
        artifacts.append((artifact_url, sha256))

    formula_file.write_text(contents)
    return old_tag, artifacts


def bump_cask_file(
    *,
    cask_name: str,
    new_version: str,
    artifact_url: str,
    input_sha256: str,
) -> tuple[str, list[tuple[str, str]]]:
    cask_file = Path("Casks") / f"{cask_name}.rb"
    if not cask_file.exists():
        fail(f"{cask_file} does not exist")

    contents = cask_file.read_text()
    old_tag = extract_release_tag_from_url(extract_field(contents, "url", cask_file))

    validate_artifact_url(artifact_url)
    sha256 = resolve_sha256(input_sha256 or None, artifact_url)
    contents = update_fields(
        contents,
        {
            "version": new_version,
            "url": artifact_url,
            "sha256": sha256,
        },
        cask_file,
    )

    cask_file.write_text(contents)
    return old_tag, [(artifact_url, sha256)]


def run_command(args: list[str], *, capture_output: bool = False) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(
        args,
        text=True,
        capture_output=capture_output,
        check=False,
    )
    if result.returncode != 0:
        if capture_output:
            if result.stdout:
                sys.stdout.write(result.stdout)
            if result.stderr:
                sys.stderr.write(result.stderr)
        raise SystemExit(result.returncode)
    return result


def create_or_update_pr(
    *,
    branch: str,
    commit_message: str,
    pr_title: str,
    pr_body: str,
    pr_base: str,
    pr_repo: str,
    change_kind: str,
) -> None:
    change_kind_capitalized = change_kind.capitalize()

    status = run_command(["git", "status", "--porcelain"], capture_output=True)
    if not status.stdout.strip():
        print(f"No pull request was created because no {change_kind} changes were detected.")
        print(f"Branch: {branch}")
        return

    run_command(["git", "config", "user.name", "github-actions[bot]"])
    run_command(["git", "config", "user.email", "41898282+github-actions[bot]@users.noreply.github.com"])

    run_command(["git", "checkout", "-B", branch])
    run_command(["git", "add", "-A"])
    run_command(["git", "commit", "--signoff", "-m", commit_message])
    run_command(["git", "push", "--force", "--set-upstream", "origin", branch])

    body_file_path = ""
    try:
        with tempfile.NamedTemporaryFile("w", delete=False, encoding="utf-8") as body_file:
            body_file.write(f"{pr_body}\n")
            body_file_path = body_file.name

        existing_pr = run_command(
            [
                "gh",
                "pr",
                "list",
                "--repo",
                pr_repo,
                "--base",
                pr_base,
                "--head",
                branch,
                "--json",
                "url",
                "--jq",
                ".[0].url",
            ],
            capture_output=True,
        ).stdout.strip()

        if existing_pr and existing_pr != "null":
            run_command(["gh", "pr", "edit", existing_pr, "--title", pr_title, "--body-file", body_file_path])
            print(f"Pull request updated: {existing_pr}")
            return

        created_pr = run_command(
            [
                "gh",
                "pr",
                "create",
                "--repo",
                pr_repo,
                "--base",
                pr_base,
                "--head",
                branch,
                "--title",
                pr_title,
                "--body-file",
                body_file_path,
            ],
            capture_output=True,
        ).stdout.strip()

        if not created_pr:
            print(
                f"{change_kind_capitalized} changes were committed and pushed, but no pull request URL was returned.",
                file=sys.stderr,
            )
            print(f"Branch: {branch}", file=sys.stderr)
            raise SystemExit(1)

        print(f"Pull request created: {created_pr}")
    finally:
        if body_file_path:
            try:
                os.unlink(body_file_path)
            except FileNotFoundError:
                pass


def make_pr_body(
    repo: str,
    old_tag: str,
    new_tag: str,
    artifacts: list[tuple[str, str]],
    branch: str,
    install_command: str,
) -> str:
    if not artifacts:
        fail("No artifact metadata available for pull request body")

    lines: list[str] = []
    if old_tag != "unknown" and old_tag != new_tag:
        lines.append(f"https://github.com/{repo}/compare/{old_tag}...{new_tag}")
        lines.append("")

    if len(artifacts) == 1:
        artifact_url, sha256 = artifacts[0]
        lines.extend(
            [
                f"Artifact: {artifact_url}",
                f"SHA256: {sha256}",
                "",
            ]
        )
    else:
        lines.append("Artifacts:")
        for artifact_url, _ in artifacts:
            lines.append(f"- {artifact_url}")
        lines.append("")
        lines.append("SHA256:")
        for _, sha256 in artifacts:
            lines.append(f"- {sha256}")
        lines.append("")

    lines.extend(
        [
            "You can test your changes before merging this pull request with:",
            "```sh",
            "git -C $(brew --repo block/tap) fetch",
            f"git -C $(brew --repo block/tap) checkout origin/{branch}",
            install_command,
            "```",
            "",
            "When you're done, reset the tap with:",
            "```sh",
            "git -C $(brew --repo block/tap) checkout main",
            "```",
        ]
    )
    return "\n".join(lines)


def validate_bump_type(bump_type: str) -> None:
    if bump_type not in {"formula", "cask"}:
        fail(f"Unsupported BUMP_TYPE: {bump_type}")


def main() -> None:
    values = {name: require_env(name) for name in REQUIRED_ENV_VARS}

    bump_type = values["BUMP_TYPE"]
    bump_name = values["BUMP_NAME"]
    repo = values["REPO"]
    new_tag = values["NEW_TAG"]

    validate_bump_type(bump_type)

    artifact_url = os.environ.get("ARTIFACT_URL", "")
    input_sha256 = os.environ.get("INPUT_SHA256", "")
    new_version = derive_new_version(new_tag)

    if bump_type == "formula":
        old_tag, artifacts = bump_formula_file(
            formula_name=bump_name,
            new_version=new_version,
            new_tag=new_tag,
            artifact_url=artifact_url,
            input_sha256=input_sha256,
        )
        install_command = f"brew install block/tap/{bump_name}"
    else:
        if not artifact_url:
            fail("Missing required environment variable: ARTIFACT_URL")
        old_tag, artifacts = bump_cask_file(
            cask_name=bump_name,
            new_version=new_version,
            artifact_url=artifact_url,
            input_sha256=input_sha256,
        )
        install_command = f"brew install --cask block/tap/{bump_name}"

    branch = f"bump-{bump_name}-to-{new_version}"
    commit_message = f"Bump {bump_name} to {new_version}"
    pr_body = make_pr_body(repo, old_tag, new_tag, artifacts, branch, install_command)

    create_or_update_pr(
        branch=branch,
        commit_message=commit_message,
        pr_title=commit_message,
        pr_body=pr_body,
        pr_base=values["PR_BASE"],
        pr_repo=values["PR_REPO"],
        change_kind=bump_type,
    )


if __name__ == "__main__":
    main()
