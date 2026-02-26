#!/usr/bin/env python3

import argparse
import hashlib
import re
import sys
import urllib.request
from pathlib import Path
from typing import Mapping


FIELD_VALUE_PATTERNS = {
    "url": r'[^"]+',
    "sha256": r"[0-9a-f]{64}",
    "version": r'[^"]+',
}


def fail(message: str) -> None:
    print(message, file=sys.stderr)
    raise SystemExit(1)


def replace_line(contents: str, pattern: str, replacement: str, error: str) -> str:
    # We operate on the whole file string; MULTILINE makes ^/$ match each line.
    updated, count = re.subn(pattern, replacement, contents, count=1, flags=re.MULTILINE)
    if count != 1:
        fail(error)
    return updated


def extract_field(contents: str, field_name: str, formula_file: Path) -> str:
    match = re.search(rf'^\s*{field_name}\s+"([^"]+)"\s*$', contents, flags=re.MULTILINE)
    if not match:
        fail(f"Unable to find {field_name} line in {formula_file}")
    return match.group(1)


def update_fields(contents: str, updates: Mapping[str, str], formula_file: Path) -> str:
    for field_name, new_value in updates.items():
        value_pattern = FIELD_VALUE_PATTERNS[field_name]
        contents = replace_line(
            contents,
            rf'^(\s*){field_name}\s+"{value_pattern}"[ \t]*$',
            rf'\1{field_name} "{new_value}"',
            f"Unable to update {field_name} in {formula_file}",
        )
    return contents


def validate_artifact_url(artifact_url: str) -> None:
    if not artifact_url.startswith("https://"):
        fail("artifact_url must start with https://")


def compute_sha256(artifact_url: str) -> str:
    digest = hashlib.sha256()
    with urllib.request.urlopen(artifact_url) as response:
        while True:
            chunk = response.read(1024 * 1024)
            if not chunk:
                break
            digest.update(chunk)
    return digest.hexdigest()


def resolve_sha256(sha256: str | None, artifact_url: str) -> str:
    if sha256 is None:
        print(f"Computing SHA256 from {artifact_url}", file=sys.stderr)
        sha256 = compute_sha256(artifact_url)

    if not re.fullmatch(r"[0-9a-f]{64}", sha256):
        fail("sha256 must be a 64-character lowercase hex string")

    return sha256


def extract_release_tag_from_url(url: str) -> str:
    tag_match = re.search(r"/releases/download/([^/]+)/", url)
    return tag_match.group(1) if tag_match else "unknown"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Patch a Homebrew formula url/sha256/version in place")
    parser.add_argument("--formula", required=True, help="Formula name (for example, stoic)")
    parser.add_argument("--version", required=True, help="Version to set in the formula")
    parser.add_argument("--tag", required=True, help="Release tag associated with this bump")
    parser.add_argument("--artifact-url", required=True, help="Release artifact URL")
    parser.add_argument("--sha256", required=False, help="SHA256 digest for the release artifact")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    validate_artifact_url(args.artifact_url)
    sha256 = resolve_sha256(args.sha256, args.artifact_url)

    formula_name = Path(args.formula).stem
    formula_file = Path("Formula") / f"{formula_name}.rb"

    if not formula_file.exists():
        fail(f"{formula_file} does not exist")

    contents = formula_file.read_text()

    old_version = extract_field(contents, "version", formula_file)
    old_url = extract_field(contents, "url", formula_file)
    old_tag = extract_release_tag_from_url(old_url)

    contents = update_fields(
        contents,
        {
            "url": args.artifact_url,
            "sha256": sha256,
            "version": args.version,
        },
        formula_file,
    )

    formula_file.write_text(contents)

    print(f"Updated {formula_file}", file=sys.stderr)
    print(f"from version {old_version} to {args.version}")
    print(f"from tag {old_tag} to {args.tag}")


if __name__ == "__main__":
    main()
