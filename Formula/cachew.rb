class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.8.5/cachew-darwin-arm64.tar.gz"
      sha256 "f39640aee16b80c5caba90a3a4be074cdfd8b82bd6a4c408c70c3c77f2300c06"
    else
      url "https://github.com/block/cachew/releases/download/v0.8.5/cachew-darwin-amd64.tar.gz"
      sha256 "5e0b3b863456c3bf3fb327397585734dc96fa2826fa64a5a05a696701d4bf6b0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.8.5/cachew-linux-arm64.tar.gz"
      sha256 "a55a91e9df9be8be804f496dc08d06152aa423f2dbafcb17b533c226f00a133f"
    else
      url "https://github.com/block/cachew/releases/download/v0.8.5/cachew-linux-amd64.tar.gz"
      sha256 "ed75d329ab50d025a50140bc92eb6fc57f2d099cfd478cea086c63cdfb239299"
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
