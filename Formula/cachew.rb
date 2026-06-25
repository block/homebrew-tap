class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  version "0.2.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.2.1/cachew-darwin-arm64.tar.gz"
      sha256 "8fd93662359c6b692445771e46a882c33ea8f82b54aed86d0a150ad54d921429"
    else
      url "https://github.com/block/cachew/releases/download/v0.2.1/cachew-darwin-amd64.tar.gz"
      sha256 "1aa0f6e6902d86ae5781d153926c7f5dc06fa550ed5a5586fa1be964f5f1e63f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.2.1/cachew-linux-arm64.tar.gz"
      sha256 "e85ac3f42c034cfb63f0b4cee914c68af2c073e153501e930e64fbde06b88afb"
    else
      url "https://github.com/block/cachew/releases/download/v0.2.1/cachew-linux-amd64.tar.gz"
      sha256 "35eed8cf6618ab49089435df82999454d782e6398dcbfb74db5d2d6e146c361c"
    end
  end

  def install
    bin.install "cachew"
    bin.install "cachewd"
  end

  test do
    system bin/"cachew", "--version"
  end
end
