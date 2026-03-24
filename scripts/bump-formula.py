#!/usr/bin/env python3

import argparse
import sys
from pathlib import Path

from brew_utils import (
    extract_all_fields,
    extract_field,
    extract_release_tag_from_url,
    fail,
    replace_nth_field,
    resolve_sha256,
    update_fields,
    validate_artifact_url,
)


def is_multi_arch(contents: str) -> bool:
    urls = extract_all_fields(contents, "url")
    return len(urls) > 1


def derive_new_url(old_url: str, old_tag: str, new_tag: str) -> str:
    return old_url.replace(old_tag, new_tag)


def bump_single_arch(contents: str, args: argparse.Namespace, formula_file: Path) -> str:
    if not args.artifact_url:
        fail("--artifact-url is required for single-arch formulas")

    validate_artifact_url(args.artifact_url)
    sha256 = resolve_sha256(args.sha256, args.artifact_url)

    return update_fields(
        contents,
        {
            "url": args.artifact_url,
            "sha256": sha256,
            "version": args.version,
        },
        formula_file,
    )


def bump_multi_arch(contents: str, args: argparse.Namespace, formula_file: Path) -> str:
    old_urls = extract_all_fields(contents, "url")
    old_tag = extract_release_tag_from_url(old_urls[0])

    # Update version first
    contents = update_fields(contents, {"version": args.version}, formula_file)

    # Update each url/sha256 pair
    for i, old_url in enumerate(old_urls):
        new_url = derive_new_url(old_url, old_tag, args.tag)
        validate_artifact_url(new_url)
        sha256 = resolve_sha256(None, new_url)

        contents = replace_nth_field(contents, "url", i, new_url, formula_file)
        contents = replace_nth_field(contents, "sha256", i, sha256, formula_file)

    return contents


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Patch a Homebrew formula url/sha256/version in place")
    parser.add_argument("--formula", required=True, help="Formula name (for example, stoic)")
    parser.add_argument("--version", required=True, help="Version to set in the formula")
    parser.add_argument("--tag", required=True, help="Release tag associated with this bump")
    parser.add_argument("--artifact-url", required=False, help="Release artifact URL (required for single-arch formulas)")
    parser.add_argument("--sha256", required=False, help="SHA256 digest for the release artifact (single-arch only)")
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    formula_name = Path(args.formula).stem
    formula_file = Path("Formula") / f"{formula_name}.rb"

    if not formula_file.exists():
        fail(f"{formula_file} does not exist")

    contents = formula_file.read_text()

    old_version = extract_field(contents, "version", formula_file)
    old_url = extract_field(contents, "url", formula_file)
    old_tag = extract_release_tag_from_url(old_url)

    if is_multi_arch(contents):
        contents = bump_multi_arch(contents, args, formula_file)
    else:
        contents = bump_single_arch(contents, args, formula_file)

    formula_file.write_text(contents)

    print(f"Updated {formula_file}", file=sys.stderr)
    print(f"from version {old_version} to {args.version}")
    print(f"from tag {old_tag} to {args.tag}")


if __name__ == "__main__":
    main()
