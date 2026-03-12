class Lhm < Formula
  desc "Merges global and repo lefthook configs"
  homepage "https://github.com/block/lhm"
  license "Apache-2.0"
  version "0.4.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/lhm/releases/download/v0.4.0/lhm-aarch64-apple-darwin.bz2"
      sha256 "8e99bdfa175d7c120b279eb7e576b4abf44aa3e73467d13b3ed37388747628e4"
    else
      url "https://github.com/block/lhm/releases/download/v0.4.0/lhm-x86_64-apple-darwin.bz2"
      sha256 "9584b252e951c3ea33979a22e69b1c376ea84cfee8ed87088fb0ebc41b959b12"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/lhm/releases/download/v0.4.0/lhm-aarch64-unknown-linux-gnu.bz2"
      sha256 "07e09ab5487873398d3f789670004b2cccc56ec4e4b4bbc85b387104318d4206"
    else
      url "https://github.com/block/lhm/releases/download/v0.4.0/lhm-x86_64-unknown-linux-gnu.bz2"
      sha256 "d3e7eee44380707bcc6a8f15ff79a1dc9c1335f3e2e5296c2cd68ac275288f82"
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
