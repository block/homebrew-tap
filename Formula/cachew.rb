class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  version "0.3.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.3.0/cachew-darwin-arm64.tar.gz"
      sha256 "8b74d76391036c5a372ee0b857dceaa1dfb2c961bd6354b48f59cc7381c1270d"
    else
      url "https://github.com/block/cachew/releases/download/v0.3.0/cachew-darwin-amd64.tar.gz"
      sha256 "8817a3804407215b0dd9f5a18b5f1c75a29eb4c0f36b4a613dfde432091c6932"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.3.0/cachew-linux-arm64.tar.gz"
      sha256 "fe3152e2669c8cbad913e3035535bcdb9eca8600c3e5c4168b6e570f8f6f5cd4"
    else
      url "https://github.com/block/cachew/releases/download/v0.3.0/cachew-linux-amd64.tar.gz"
      sha256 "155f06b438e3cd03bb16cd6ee7365946b64e9a6fc164beb19965adbc8544c10b"
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
