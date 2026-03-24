#!/usr/bin/env python3

import argparse
import sys
from pathlib import Path

from brew_utils import (
    extract_field,
    extract_release_tag_from_url,
    fail,
    resolve_sha256,
    update_fields,
    validate_artifact_url,
)


def main() -> None:
    parser = argparse.ArgumentParser(description="Patch a Homebrew cask url/sha256/version in place")
    parser.add_argument("--cask", required=True, help="Cask name (e.g. penpal)")
    parser.add_argument("--version", required=True, help="Version to set")
    parser.add_argument("--tag", required=True, help="Release tag (e.g. penpal/v0.2.0)")
    parser.add_argument("--artifact-url", required=True, help="Full GitHub release artifact URL")
    parser.add_argument("--sha256", required=False, help="SHA256 for the artifact (computed from URL if omitted)")
    args = parser.parse_args()

    cask_file = Path("Casks") / f"{args.cask}.rb"
    if not cask_file.exists():
        fail(f"{cask_file} does not exist")

    contents = cask_file.read_text()
    old_version = extract_field(contents, "version", cask_file)
    old_url = extract_field(contents, "url", cask_file)

    validate_artifact_url(args.artifact_url)
    sha256 = resolve_sha256(args.sha256, args.artifact_url)

    contents = update_fields(
        contents,
        {
            "version": args.version,
            "url": args.artifact_url,
            "sha256": sha256,
        },
        cask_file,
    )

    cask_file.write_text(contents)

    old_tag = extract_release_tag_from_url(old_url)

    print(f"Updated {cask_file}", file=sys.stderr)
    print(f"from version {old_version} to {args.version}")
    print(f"from tag {old_tag} to {args.tag}")


if __name__ == "__main__":
    main()
