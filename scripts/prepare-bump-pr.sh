#!/usr/bin/env bash
set -euo pipefail

# Parse arguments
TYPE=""
NAME=""
TAG=""
REPO=""
ARTIFACT_URL=""
SHA256=""
PYTHON_SCRIPT=""
INSTALL_COMMAND=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --type) TYPE="$2"; shift 2 ;;
    --name) NAME="$2"; shift 2 ;;
    --tag) TAG="$2"; shift 2 ;;
    --repo) REPO="$2"; shift 2 ;;
    --artifact-url) ARTIFACT_URL="$2"; shift 2 ;;
    --sha256) SHA256="$2"; shift 2 ;;
    --python-script) PYTHON_SCRIPT="$2"; shift 2 ;;
    --install-command) INSTALL_COMMAND="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

# Extract semver from tag
if [[ "$TAG" =~ ([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
  VERSION="${BASH_REMATCH[1]}"
else
  VERSION="$TAG"
fi

# Build script arguments
SCRIPT_ARGS=(
  --"$TYPE" "$NAME"
  --version "$VERSION"
  --tag "$TAG"
)
if [[ -n "$ARTIFACT_URL" ]]; then
  SCRIPT_ARGS+=(--artifact-url "$ARTIFACT_URL")
fi
if [[ -n "$SHA256" ]]; then
  SCRIPT_ARGS+=(--sha256 "$SHA256")
fi

# Run the bump script and capture OLD_TAG from its stdout
OLD_TAG="$({ python3 "$PYTHON_SCRIPT" "${SCRIPT_ARGS[@]}"; } | tee >(cat 1>&2) | grep -o 'from tag .* to' | cut -d' ' -f3)"

if [[ -z "${OLD_TAG:-}" ]]; then
  OLD_TAG="unknown"
fi

# Determine the rb file directory based on type
case "$TYPE" in
  formula) FILE_DIR="Formula" ;;
  cask)    FILE_DIR="Casks" ;;
  *)       echo "Unknown type: $TYPE" >&2; exit 1 ;;
esac

RB_FILE="${FILE_DIR}/${NAME}.rb"
SHA256_VALUE="$(sed -nE 's/^\s*sha256 "([0-9a-f]{64})"\s*$/\1/p' "$RB_FILE" | head -n1)"
if [[ -z "${SHA256_VALUE:-}" ]]; then
  echo "Unable to read updated sha256 from ${RB_FILE}" >&2
  exit 1
fi

BRANCH="bump-${NAME}-to-${VERSION}"
COMMIT_MESSAGE="Bump ${NAME} to ${VERSION}"

echo "branch=${BRANCH}" >> "$GITHUB_OUTPUT"
echo "commit_message=${COMMIT_MESSAGE}" >> "$GITHUB_OUTPUT"
{
  echo "body<<EOF"
  if [[ "$OLD_TAG" != "unknown" && "$OLD_TAG" != "$TAG" ]]; then
    echo "https://github.com/${REPO}/compare/${OLD_TAG}...${TAG}"
    echo
  fi
  echo "Artifact: ${ARTIFACT_URL}"
  echo "SHA256: ${SHA256_VALUE}"
  echo
  echo "You can test your changes before merging this pull request with:"
  echo '```sh'
  echo 'git -C $(brew --repo block/tap) fetch'
  echo "git -C \$(brew --repo block/tap) checkout origin/${BRANCH}"
  echo "$INSTALL_COMMAND"
  echo '```'
  echo
  echo "When you're done, reset the tap with:"
  echo '```sh'
  echo 'git -C $(brew --repo block/tap) checkout main'
  echo '```'
  echo EOF
} >> "$GITHUB_OUTPUT"
