# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.
# Run: gh workflow run bump-formula.yaml -f repo=block/stoic -f formula=stoic -f tag=<tag> -f artifact_url=<artifact_url> [-f sha256=<sha256>]

class Stoic < Formula
  desc "CLI tool for Android investigations"
  homepage "https://github.com/block/stoic"
  url "https://github.com/block/stoic/releases/download/v0.9.1/stoic-release.tar.gz"
  sha256 "d5e3b99bfed472acd0b474d4e447b326c4c3e039712375b8b986c2887fac3871"
  license "Apache-2.0"
  version "0.9.1"

  def install
    libexec.install Dir["*"]

    # Use native binary for macOS ARM64, JVM version for everything else
    if OS.mac? && Hardware::CPU.arm?
      bin.install_symlink libexec/"bin/darwin-arm64/stoic"
    else
      bin.install_symlink libexec/"bin/jvm/stoic"
    end
  end

  test do
    system "\#{bin}/stoic", "--help"
  end
end
