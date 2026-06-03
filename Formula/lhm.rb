class Lhm < Formula
  desc "Merges global and repo lefthook configs"
  homepage "https://github.com/block/lhm"
  license "Apache-2.0"
  version "0.11.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/lhm/releases/download/v0.11.1/lhm-aarch64-apple-darwin.bz2"
      sha256 "44f28668345cfcedbaaa02f7086277c6e273e98656cc57b8edaeb3f2eb526c26"
    else
      url "https://github.com/block/lhm/releases/download/v0.11.1/lhm-x86_64-apple-darwin.bz2"
      sha256 "420213fd867f72a4b6ae50cab456deb6d188ce62886d8be3a4e9ba5e52e811cb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/lhm/releases/download/v0.11.1/lhm-aarch64-unknown-linux-gnu.bz2"
      sha256 "c8567e7c1555c39af0d3343c81d61bac5d51bb4617fd448f3862e468b43bb9eb"
    else
      url "https://github.com/block/lhm/releases/download/v0.11.1/lhm-x86_64-unknown-linux-gnu.bz2"
      sha256 "19aa7e9d4dfeaa79fb1a59a41c58915d7911e46ea6e3d4f3878d226a7baa7536"
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
