# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.
# Run: gh workflow run bump-formula.yaml -f repo=block/qrgo -f formula=qrgo -f tag=<tag> -f artifact_url=<artifact_url> [-f sha256=<sha256>]

class Qrgo < Formula
  desc "A CLI utility for screen-capturing a QR code and launching it in an Android emulator or iOS simulator."
  homepage "https://github.com/block/qrgo"
  url "https://github.com/block/qrgo/releases/download/1.0.3/qrgo-release.tar.gz"
  sha256 "d1084a02faa44d0bc942dcb2df5d409b402b2af36b31d213a1a6513e017e4a56"
  license "Apache-2.0"
  version "1.0.3"

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"qrgo"
  end

  test do
    system "\#{bin}/qrgo", "--help"
  end
end
