class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.8.4/cachew-darwin-arm64.tar.gz"
      sha256 "da8d66f2226cdb566afa31543912eae07afa0fa2704c28ed13457856927eea23"
    else
      url "https://github.com/block/cachew/releases/download/v0.8.4/cachew-darwin-amd64.tar.gz"
      sha256 "a2b2717198ed3a33d038a21778ab546b1ef6faedc052e5522f3010cf62f5055e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.8.4/cachew-linux-arm64.tar.gz"
      sha256 "5651a35d13266ac14dffba9133534591adc343a83a6a87c1cd05b864c3549d0f"
    else
      url "https://github.com/block/cachew/releases/download/v0.8.4/cachew-linux-amd64.tar.gz"
      sha256 "1832f5f4fbd2d3bece1cd6293ed68be78dfb64061b230b6847045b04e0609e64"
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
