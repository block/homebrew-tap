#!/usr/bin/env bash

set -euo pipefail

# The preceding setup-homebrew action finds or installs Homebrew and makes its
# bin directory available on PATH. Linux bottle jobs also run in a Homebrew
# container image, so this script can invoke brew without changing PATH itself.
homebrew_version="6.0.13"

if [[ ! "$homebrew_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid Homebrew version: $homebrew_version" >&2
  exit 1
fi

# Each workflow step starts a new shell. Export this for commands in this step,
# then write it to GITHUB_ENV so GitHub Actions supplies it to later steps.
# This disables Homebrew's automatic updates; an explicit `brew update` would
# still defeat the pin and must not be added to these workflows.
export HOMEBREW_NO_AUTO_UPDATE=1
echo "HOMEBREW_NO_AUTO_UPDATE=1" >> "${GITHUB_ENV:?}"

# The brew launcher remains at the same path. Checking out the Homebrew
# repository changes the implementation that launcher runs.
homebrew_repository="$(brew --repository)"
git -C "$homebrew_repository" checkout --force --detach "refs/tags/$homebrew_version"

resolved_version="$(git -C "$homebrew_repository" describe --tags --exact-match HEAD)"
if [[ "$resolved_version" != "$homebrew_version" ]]; then
  echo "Expected Homebrew $homebrew_version, got $resolved_version" >&2
  exit 1
fi

gems_hash="$(shasum -a 256 "$homebrew_repository/Library/Homebrew/Gemfile.lock" | cut -f1 -d' ')"
echo "gems-hash=$gems_hash" >> "${GITHUB_OUTPUT:?}"

brew --version
