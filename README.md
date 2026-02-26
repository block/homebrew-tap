# Block homebrew-tap

Homebrew formulae for installation of Block open source tools via the Homebrew package manager.

## Installation

If you don't have Homebrew installed, install that first: https://brew.sh/

Next:

```
brew tap block/tap
brew install <FORMULA>
```

You can also install formulae directly via

```
brew install block/tap/<FORMULA>
```

## Introduction

See https://docs.brew.sh/

## Maintainers: Adding A New Formula

This tap uses GitHub Actions workflows to generate formula files from release artifacts.

1. Create a new workflow file at `.github/workflows/update-<formula>.yaml`.
2. Copy one of the existing `update-*.yaml` workflows as a template.
3. In that workflow:
   - Add a `workflow_dispatch` `tag` input.
   - Build the GitHub release download URL (or resolve the correct asset from the release API).
   - Download the artifact and compute `sha256`.
   - Write `Formula/<formula>.rb` using a heredoc.
   - Commit and push the generated formula.
4. In the generated formula content:
   - Set `homepage`, `url`, `sha256`, `license`, and `version`.
   - Add `depends_on` entries as needed.
   - For dependencies from this tap, use fully-qualified names (for example `depends_on "block/tap/stoic"`) to avoid ambiguous tap resolution.
   - Install the executable into `bin` with `bin.install_symlink`.
5. Commit the workflow file.
6. Trigger the workflow manually:

```bash
gh workflow run update-<formula>.yaml -f tag=vX.Y.Z
```

7. Watch the run:

```bash
gh run list --workflow update-<formula>.yaml --limit 1
gh run watch <run-id>
```

After the workflow succeeds, users can install with:

```bash
brew install block/tap/<formula>
```
