class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.5.5/cachew-darwin-arm64.tar.gz"
      sha256 "b4e6591855df9fb21b22e03c79df32fe414ccb47a8ed5cbce8df908a83e149df"
    else
      url "https://github.com/block/cachew/releases/download/v0.5.5/cachew-darwin-amd64.tar.gz"
      sha256 "405889d6df270e6818f8c3ae3e20a13dbf362695af95ddca5dff002156f2b80c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.5.5/cachew-linux-arm64.tar.gz"
      sha256 "aa508445807402f2c497ea47049b872560b1886ad6edce901642001b796e47c0"
    else
      url "https://github.com/block/cachew/releases/download/v0.5.5/cachew-linux-amd64.tar.gz"
      sha256 "daf6b3c1890e7cf1338f7d614cb81750b7a975db88013363cb435f2b0600d7fd"
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
