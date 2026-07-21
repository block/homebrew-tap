class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  version "0.4.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.4.0/cachew-darwin-arm64.tar.gz"
      sha256 "eb730ae02396685fee3173d89764328557e42b57b98d3fc7e79975e980e48941"
    else
      url "https://github.com/block/cachew/releases/download/v0.4.0/cachew-darwin-amd64.tar.gz"
      sha256 "c8ded60eb0d4517426b1e975880c1cbba7fcd7fd368d71cf5ab08ba2a98e52f1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.4.0/cachew-linux-arm64.tar.gz"
      sha256 "8db883d51c744a24f20641880a4659e95ebd202a25cd2c793377d9f77b38751d"
    else
      url "https://github.com/block/cachew/releases/download/v0.4.0/cachew-linux-amd64.tar.gz"
      sha256 "aafda9ee9c36f15b39681957ee63d9a9c424237047f6f3d388840f4b15818ac8"
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
