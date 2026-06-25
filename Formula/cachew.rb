class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  version "0.1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.1.1/cachew-darwin-arm64.tar.gz"
      sha256 "8f93d4fdd7f3bf90d6550a9749a4de38f90679da991f20ed15a93cca3ec1bfe3"
    else
      url "https://github.com/block/cachew/releases/download/v0.1.1/cachew-darwin-amd64.tar.gz"
      sha256 "28abae022d53a492907e08a0b841e711e1302c382b49c6210478fa507ea465c4"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.1.1/cachew-linux-arm64.tar.gz"
      sha256 "47d723a419e513279b88328d838599b6681f9d39eb31cf2ad7807c99fb7b3d75"
    else
      url "https://github.com/block/cachew/releases/download/v0.1.1/cachew-linux-amd64.tar.gz"
      sha256 "1a40e9e9f2c340026cc04a9cb991d0828244e1606ada51e46f7227343f937add"
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
