# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Run: gh workflow run bump-formula.yaml -f repo=block/schemabot -f formula=schemabot -f tag=<tag>

class Schemabot < Formula
  desc "Safe schema changes at the speed of agents"
  homepage "https://github.com/block/schemabot"
  license "Apache-2.0"
  version "0.1.70"

  on_macos do
    depends_on arch: :arm64
    url "https://github.com/block/schemabot/releases/download/v0.1.70/schemabot_0.1.70_darwin_arm64.tar.gz"
    sha256 "7225d88cd157c8bb3fb6111ce7d3b1416119a84d89ab6aaf56b648f0b3097489"
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/schemabot/releases/download/v0.1.70/schemabot_0.1.70_linux_arm64.tar.gz"
      sha256 "64e1d1b8ad52475d5f747673de9215ba9c68dfa852bb755ee848e31f8948a49e"
    else
      url "https://github.com/block/schemabot/releases/download/v0.1.70/schemabot_0.1.70_linux_amd64.tar.gz"
      sha256 "afe0faa57fba19d3a19de87bb25496a872cae9f393be93c0e4c3f37cd1693a6e"
    end
  end

  def install
    bin.install "schemabot"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/schemabot --version")
    assert_match "Usage:", shell_output("#{bin}/schemabot --help")
    assert_match "init", shell_output("#{bin}/schemabot init --help")
  end
end
