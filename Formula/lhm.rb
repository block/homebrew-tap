class Lhm < Formula
  desc "Merges global and repo lefthook configs"
  homepage "https://github.com/block/lhm"
  license "Apache-2.0"
  version "0.7.2"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/lhm/releases/download/v0.7.2/lhm-aarch64-apple-darwin.bz2"
      sha256 "a0b7e61c300ef09f0076629abe4840ca25a74f0b674bb21fbcac5a6e02cede57"
    else
      url "https://github.com/block/lhm/releases/download/v0.7.2/lhm-x86_64-apple-darwin.bz2"
      sha256 "5c8e4e6e271833e1e5c8238d4954ad66cb3310929625697be315713356647eca"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/lhm/releases/download/v0.7.2/lhm-aarch64-unknown-linux-gnu.bz2"
      sha256 "d52885c3dd6e11e73b201f50d6b4d8a1c1a48b57fe00c2de9cfed7afa00d5274"
    else
      url "https://github.com/block/lhm/releases/download/v0.7.2/lhm-x86_64-unknown-linux-gnu.bz2"
      sha256 "28d1ff6f0c4bcc978eb0390f8c86cf4a310ae63ca5d3c95db85a467d03f6f82a"
    end
  end

  def install
    # bz2 is auto-extracted by Homebrew; the resulting file needs to be renamed
    binary = buildpath.children.first
    binary.chmod 0755
    bin.install binary => "lhm"
  end

  test do
    system bin/"lhm", "--help"
  end
end
