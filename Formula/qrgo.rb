# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Avoid manual edits to `url` and `sha256`; the bump workflow rewrites them.
# Run: gh workflow run bump-formula.yaml -f repo=block/qrgo -f formula=qrgo -f tag=<tag> -f artifact_url=<artifact_url> [-f sha256=<sha256>]

class Qrgo < Formula
  desc "A CLI utility for screen-capturing a QR code and launching it in an Android emulator or iOS simulator."
  homepage "https://github.com/block/qrgo"
  url "https://github.com/block/qrgo/releases/download/1.4.2/qrgo-release.tar.gz"
  sha256 "e7dcdd70eeb2dfc1c0fbbd71bce5f94efd17b5466620784d02796575ab5fbc9f"
  license "Apache-2.0"

  depends_on arch: :arm64
  depends_on :macos

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"qrgo"
  end

  test do
    system bin/"qrgo", "--help"
  end
end
