class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  version "0.5.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.5.0/cachew-darwin-arm64.tar.gz"
      sha256 "ba332d0361b528952eceaeef26a4f287a9b53c413f6010b4224e4c83febcc461"
    else
      url "https://github.com/block/cachew/releases/download/v0.5.0/cachew-darwin-amd64.tar.gz"
      sha256 "5c2e181db244dd57ca0094f67c1493ebe1f4a4193756b0ada2ca038276f6f4c1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.5.0/cachew-linux-arm64.tar.gz"
      sha256 "4a568d8cf283a237ec6ee5763e25fa6c22df00de8ea77fae42d2da78ef3c7f21"
    else
      url "https://github.com/block/cachew/releases/download/v0.5.0/cachew-linux-amd64.tar.gz"
      sha256 "9e648b635e5228c5c9c7d22da0a6497e711344be01efa202f2a225e8a1429540"
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
