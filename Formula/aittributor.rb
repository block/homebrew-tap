class Aittributor < Formula
  desc "Git hook that adds AI agent attribution to commits"
  homepage "https://github.com/block/aittributor"
  license "Apache-2.0"
  version "0.5.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/aittributor/releases/download/v0.5.1/aittributor-aarch64-apple-darwin.bz2"
      sha256 "3229978e7ae787691b7e97fbee10b18346d6623c96cc8349eb5149413390eb98"
    else
      url "https://github.com/block/aittributor/releases/download/v0.5.1/aittributor-x86_64-apple-darwin.bz2"
      sha256 "8c78916bedeabcb51651efc0d8bce46b4072a85a867b6ccdd34f2b85048549fb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/aittributor/releases/download/v0.5.1/aittributor-aarch64-unknown-linux-gnu.bz2"
      sha256 "b9237acf18ae98d421026c97b67d5a5c1f8d1ea459b9606a7dcf632e17c7fe52"
    else
      url "https://github.com/block/aittributor/releases/download/v0.5.1/aittributor-x86_64-unknown-linux-gnu.bz2"
      sha256 "5d370297a35f886dbca8cb6a7585dc7fe9998970e596a092ccfb74bed9d7acd9"
    end
  end

  def install
    binary = buildpath.children.first
    binary.chmod 0755
    bin.install binary => "aittributor"
  end

  test do
    system bin/"aittributor", "--help"
  end
end
