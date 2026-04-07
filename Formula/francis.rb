# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.
# Run: gh workflow run bump-formula.yaml -f repo=block/francis -f formula=francis -f tag=<tag> -f artifact_url=<artifact_url> [-f sha256=<sha256>]

class Francis < Formula
  desc "CLI for rigorous A/B performance testing on Android"
  homepage "https://github.com/block/francis"
  url "https://github.com/block/francis/releases/download/v0.0.20/francis-release.tar.gz"
  sha256 "598aa6ab4d2f419d7a120557b9c5272ad2a62de3eb21209820bddfffae32f2e7"
  license "Apache-2.0"
  version "0.0.20"

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/jvm/francis"
  end

  test do
    system "\#{bin}/francis", "--help"
  end
end
