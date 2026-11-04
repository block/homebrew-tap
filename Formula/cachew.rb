class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.5.7/cachew-darwin-arm64.tar.gz"
      sha256 "a27f701e587e52692af09ac9c364b1956d68e48340db2fedbbd07d7b1739d3b3"
    else
      url "https://github.com/block/cachew/releases/download/v0.5.7/cachew-darwin-amd64.tar.gz"
      sha256 "a7c9ead4d39a51c23202c4485b9be08702c010127b46934db7544d30d0e309ae"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.5.7/cachew-linux-arm64.tar.gz"
      sha256 "b706ebb78a9800617955a9f6b0634ad76915c7cbc3f1d0d7b624f2eaaf126004"
    else
      url "https://github.com/block/cachew/releases/download/v0.5.7/cachew-linux-amd64.tar.gz"
      sha256 "2ae9ee5c8e6bbe2170ef3cc33b61cdc7e2198079dfd662d215770407facf669c"
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
