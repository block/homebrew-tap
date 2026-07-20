class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  version "0.3.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.3.1/cachew-darwin-arm64.tar.gz"
      sha256 "b992dcbfe8502e854e838bd3a4bd4dfffad95362346e2c51f2937ca8bdb41620"
    else
      url "https://github.com/block/cachew/releases/download/v0.3.1/cachew-darwin-amd64.tar.gz"
      sha256 "5a9db70d09b6ea35c35833ae15bcc7295908ca9c53ad0ae88bb5527b4a7fcccf"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.3.1/cachew-linux-arm64.tar.gz"
      sha256 "83377cf74865973e4dd2c80de22207035951c9cd6a52861106ffd9743a35a399"
    else
      url "https://github.com/block/cachew/releases/download/v0.3.1/cachew-linux-amd64.tar.gz"
      sha256 "19a6c609283601e8c579d126191a936a3b2647d62a78fa90933f22bb60ff9222"
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
