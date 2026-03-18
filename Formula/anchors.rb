# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.
# Run: gh workflow run bump-formula.yaml -f repo=block/anchorsmd -f formula=anchors -f tag= -f artifact_url=<artifact_url> [-f sha256=]

class Anchors < Formula
  desc "CLI for the ANCHORS requirements-driven development framework"
  homepage "https://github.com/block/anchorsmd"
  url "https://github.com/block/anchorsmd/releases/download/0.0.0/anchors-release.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "Apache-2.0"
  version "0.0.0"

  def install
    libexec.install "anchors"
    libexec.install "skill"
    bin.install_symlink libexec/"anchors"
  end

  test do
    system "#{bin}/anchors", "help"
  end
end
