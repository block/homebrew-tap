class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.5.1/cachew-darwin-arm64.tar.gz"
      sha256 "5cada736bc9e06a9bb593225657217dcf86866ee9a4423c49ef7e1c7191b5dad"
    else
      url "https://github.com/block/cachew/releases/download/v0.5.1/cachew-darwin-amd64.tar.gz"
      sha256 "240747df76f79b79cd725cfd40118f00f273aeedefd749c635a8f7ea1ef4fb61"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.5.1/cachew-linux-arm64.tar.gz"
      sha256 "14d7b5079ba942e12b33331b62dd5d70956797a50988db99841dc5f2305bc80c"
    else
      url "https://github.com/block/cachew/releases/download/v0.5.1/cachew-linux-amd64.tar.gz"
      sha256 "9482deb0e83ecc1c3754609945bd4ee898ee2e9ad2ddaa28c46593841efa393c"
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
