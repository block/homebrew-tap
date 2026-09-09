# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Run: gh workflow run bump-formula.yaml -f repo=block/schemabot -f formula=schemabot -f tag=<tag>

class Schemabot < Formula
  desc "Safe schema changes at the speed of agents"
  homepage "https://github.com/block/schemabot"
  license "Apache-2.0"
  version "0.1.67"

  on_macos do
    depends_on arch: :arm64

    url "https://github.com/block/schemabot/releases/download/v0.1.67/schemabot_0.1.67_darwin_arm64.tar.gz"
    sha256 "5b29b355bb87ed7b9e0146767b5ed7c18cec84bda93c3b67deab2f1484f292ec"
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/schemabot/releases/download/v0.1.67/schemabot_0.1.67_linux_arm64.tar.gz"
      sha256 "83f867508e82bd131a3ed457bfd8e5a80a858c0724d33a772871bdd11b923692"
    else
      url "https://github.com/block/schemabot/releases/download/v0.1.67/schemabot_0.1.67_linux_amd64.tar.gz"
      sha256 "2dfc594bcdae1de1f7a48255b2763eca9de5d6829e28a6c1b01c191be4a4feac"
    end
  end

  def install
    bin.install "schemabot"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/schemabot --version")
    assert_match "Usage:", shell_output("#{bin}/schemabot --help")
  end
end
