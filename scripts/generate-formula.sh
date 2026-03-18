#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: generate-formula.sh <formula>" >&2
  exit 1
fi

formula="$1"
repo="block/${formula}"

if [[ ! -d "templates/${formula}" ]]; then
  echo "No template found for ${formula}" >&2
  exit 1
fi

context=$(gh release view --repo "$repo" --json tagName,assets | jq '{
  tag: .tagName,
  version: (.tagName | ltrimstr("v")),
  assets: [.assets[] | {name, url, sha256: (.digest | ltrimstr("sha256:"))}]
}')

./bin/scaffolder "templates/${formula}" Formula/ --json "$context" --script templates/template.js
