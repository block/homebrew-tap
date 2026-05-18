# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.
# Run: gh workflow run bump-formula.yaml -f repo=block/qrgo -f formula=qrgo -f tag=<tag> -f artifact_url=<artifact_url> [-f sha256=<sha256>]

class Qrgo < Formula
  desc "A CLI utility for screen-capturing a QR code and launching it in an Android emulator or iOS simulator."
  homepage "https://github.com/block/qrgo"
  url "https://github.com/block/qrgo/releases/download/1.3.4/qrgo-release.tar.gz"
  sha256 "034ce96cafff7db0991d5aa2844e4b48a111a58bf94b01ef385c67d53ccc31e3"
  license "Apache-2.0"
  version "1.3.4"

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"qrgo"
  end

  test do
    system "\#{bin}/qrgo", "--help"
  end
end
