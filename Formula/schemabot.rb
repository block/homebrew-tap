# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Run: gh workflow run bump-formula.yaml -f repo=block/schemabot -f formula=schemabot -f tag=<tag>

class Schemabot < Formula
  desc "Safe schema changes at the speed of agents"
  homepage "https://github.com/block/schemabot"
  license "Apache-2.0"

  on_macos do
    depends_on arch: :arm64
    url "https://github.com/block/schemabot/releases/download/v0.1.83/schemabot_0.1.83_darwin_arm64.tar.gz"
    sha256 "092a51c32b4a11d057fff9c8b822aaae6f5d296e7ca580ed4225b8e55c703ea8"
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/schemabot/releases/download/v0.1.83/schemabot_0.1.83_linux_arm64.tar.gz"
      sha256 "60792b75c1dc87bba92b7790531a216e78a46e832035c0bc3caae83f8f7e4d2d"
    else
      url "https://github.com/block/schemabot/releases/download/v0.1.83/schemabot_0.1.83_linux_amd64.tar.gz"
      sha256 "5db793305c87bf808d484ebd600b435ac02c7d7cf7e4a1ca74cee07676fa6890"
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
