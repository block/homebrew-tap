class Lhm < Formula
  desc "Merges global and repo lefthook configs"
  homepage "https://github.com/block/lhm"
  license "Apache-2.0"
  version "0.11.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/lhm/releases/download/v0.11.0/lhm-aarch64-apple-darwin.bz2"
      sha256 "aad47a14b98c69ee80c8ab58954ef79b7af8bb7cc1c87a102b9011b87d07b3b3"
    else
      url "https://github.com/block/lhm/releases/download/v0.11.0/lhm-x86_64-apple-darwin.bz2"
      sha256 "5461e0e67074df4428a9ad67b5fe66b128f6cb33f37428059e2e8743dcb34bb0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/lhm/releases/download/v0.11.0/lhm-aarch64-unknown-linux-gnu.bz2"
      sha256 "64f2f36a5356f3e191952271e9684251c9d0263d0b0138b14541358c5d3d5f16"
    else
      url "https://github.com/block/lhm/releases/download/v0.11.0/lhm-x86_64-unknown-linux-gnu.bz2"
      sha256 "1db59f00493e678761f86d8bf14c519d2c10dc47434f5a4f8676bc22ead1ef5e"
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
