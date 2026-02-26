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

This tap uses one shared GitHub Actions workflow to bump any existing formula in place.

1. Add a formula at `Formula/<formula>.rb`.
2. Include `url`, `sha256`, and `version` fields in the formula.
3. Trigger the shared bump workflow manually:

```bash
gh workflow run bump-formula.yaml \
  -f repo=<org>/<repo> \
  -f formula=<formula> \
  -f tag=vX.Y.Z \
  -f artifact_url=https://github.com/<org>/<repo>/releases/download/vX.Y.Z/<asset.tar.gz> \
  -f sha256=<optional-sha256>
```

4. Watch the run:

```bash
gh run list --workflow bump-formula.yaml --limit 1
gh run watch <run-id>
```

The workflow updates only the target formula's existing `url`, `sha256`, and `version` fields, then opens a PR.

If `sha256` is omitted, the workflow downloads `artifact_url` and computes it automatically.

After the workflow succeeds, users can install with:

```bash
brew install block/tap/<formula>
```
