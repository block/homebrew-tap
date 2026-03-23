# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.
# Run: gh workflow run bump-formula.yaml -f repo=block/anchorsmd -f formula=anchors -f tag= -f artifact_url=<artifact_url> [-f sha256=]

class Anchors < Formula
  desc "CLI for the ANCHORS requirements-driven development framework"
  homepage "https://github.com/block/anchorsmd"
  url "https://github.com/block/anchorsmd/releases/download/0.1.0/anchors-release.tar.gz"
  sha256 "03abad3f4091b5c7af2a92964b7c50a62b293ce91554f22f94db3c7f9c3c48ba"
  license "Apache-2.0"
  version "0.1.0"

  def install
    libexec.install "anchors"
    libexec.install "skill"
    bin.install_symlink libexec/"anchors"
  end

  test do
    system "#{bin}/anchors", "help"
  end
end
