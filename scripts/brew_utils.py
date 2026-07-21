#!/usr/bin/env python3

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


def extract_field(contents: str, field_name: str, rb_file: Path) -> str:
    match = re.search(rf'^\s*{field_name}\s+"([^"]+)"\s*$', contents, flags=re.MULTILINE)
    if not match:
        fail(f"Unable to find {field_name} line in {rb_file}")
    return match.group(1)


def extract_all_fields(contents: str, field_name: str) -> list[str]:
    return re.findall(rf'^\s*{field_name}\s+"([^"]+)"\s*$', contents, flags=re.MULTILINE)


def update_fields(contents: str, updates: Mapping[str, str], rb_file: Path) -> str:
    for field_name, new_value in updates.items():
        value_pattern = FIELD_VALUE_PATTERNS[field_name]
        contents = replace_line(
            contents,
            rf'^(\s*){field_name}\s+"{value_pattern}"[ \t]*$',
            rf'\1{field_name} "{new_value}"',
            f"Unable to update {field_name} in {rb_file}",
        )
    return contents


def replace_nth_field(contents: str, field_name: str, n: int, new_value: str, rb_file: Path) -> str:
    """Replace the nth occurrence (0-indexed) of a field."""
    value_pattern = FIELD_VALUE_PATTERNS[field_name]
    pattern = rf'^(\s*){field_name}\s+"{value_pattern}"[ \t]*$'
    matches = list(re.finditer(pattern, contents, flags=re.MULTILINE))
    if n >= len(matches):
        fail(f"Unable to update {field_name} occurrence {n} in {rb_file}")
    match = matches[n]
    indent = match.group(1)
    replacement = f'{indent}{field_name} "{new_value}"'
    return contents[: match.start()] + replacement + contents[match.end() :]


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
    tag_match = re.search(r"/releases/download/([^/]+(?:/[^/]+)?)/", url)
    return tag_match.group(1) if tag_match else "unknown"


def is_multi_arch_cask(contents: str) -> bool:
    """Return True if the cask uses a multi-key sha256 stanza (arm:, intel:, etc.)."""
    return bool(re.search(r"^\s*sha256\s+\w+:", contents, re.MULTILINE))


def extract_stanza_values(contents: str, stanza: str) -> dict[str, str]:
    """Extract key: "value" pairs from a single-line stanza, e.g. arch or os."""
    match = re.search(rf"^\s*{stanza}\s+(.+)$", contents, re.MULTILINE)
    if not match:
        return {}
    return dict(re.findall(r'(\w+):\s+"([^"]+)"', match.group(1)))


def expand_cask_url(url_template: str, *, version: str, arch: str, os: str) -> str:
    """Expand Ruby-style #{...} interpolations in a cask URL template."""
    return (
        url_template.replace("#{version}", version)
        .replace("#{arch}", arch)
        .replace("#{os}", os)
    )


def update_sha256_key(contents: str, key: str, new_hash: str, rb_file: Path) -> str:
    """Update a single named sha256 key within a multi-key sha256 stanza."""
    updated, count = re.subn(
        rf"({re.escape(key)}:\s+\")[0-9a-f]{{64}}(\")",
        rf"\g<1>{new_hash}\2",
        contents,
        count=1,
    )
    if count != 1:
        fail(f"Unable to update sha256 {key}: in {rb_file}")
    return updated
