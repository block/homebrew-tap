# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.
# Run: gh workflow run bump-formula.yaml -f repo=block/radiography -f formula=radiography -f tag=<tag> -f artifact_url=<artifact_url> [-f sha256=<sha256>]

class Radiography < Formula
  desc "CLI for scanning Android view hierarchies via Stoic"
  homepage "https://github.com/block/radiography"
  url "https://github.com/block/radiography/releases/download/v2.9/radiography-stoic-plugin-2.9.tar.gz"
  sha256 "49d6636a7e918c1ef7bcb8fa2192a674d09a29b3dbf6385657fcee99d6e2177e"
  license "Apache-2.0"
  version "2.9"

  depends_on "block/tap/stoic"

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"radiography"
  end

  test do
    system "\#{bin}/radiography", "--help"
  end
end
