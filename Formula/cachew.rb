class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.5.9/cachew-darwin-arm64.tar.gz"
      sha256 "19635336e66cb888ed1f0a4878b3151ca73bbee8743d77dff786a6c3cb3f6b8b"
    else
      url "https://github.com/block/cachew/releases/download/v0.5.9/cachew-darwin-amd64.tar.gz"
      sha256 "8242a28ec32633a4db1ca7b7b178e520856672b7f8e9d77035e872df5f31f01d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.5.9/cachew-linux-arm64.tar.gz"
      sha256 "5d1c92b43c923b5fe5dea8569c55a2516d2cc5cd6945aea73637a84c8b168da9"
    else
      url "https://github.com/block/cachew/releases/download/v0.5.9/cachew-linux-amd64.tar.gz"
      sha256 "fe5a062bbbf98e550e8549e1c0ca175d0f428cc10821008768e6f5c25e8badc1"
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
