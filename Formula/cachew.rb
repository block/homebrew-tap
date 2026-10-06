class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.5.3/cachew-darwin-arm64.tar.gz"
      sha256 "f6947d1a8c26d7c205a24e4e37f26f9b2860ec732b4857f4e5ba701d90bf9915"
    else
      url "https://github.com/block/cachew/releases/download/v0.5.3/cachew-darwin-amd64.tar.gz"
      sha256 "2b0fb3b4febb99742eb021f9bc3909dbafb196ed9537e14e4cea66c96f284f7f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.5.3/cachew-linux-arm64.tar.gz"
      sha256 "94fa88b00f89279d467059556ed02a9dd7d15e0764bfb8015ef52035c528a9a5"
    else
      url "https://github.com/block/cachew/releases/download/v0.5.3/cachew-linux-amd64.tar.gz"
      sha256 "1d7efcd7a88a8a78f04d564728125ede9fd9464981c31406eb1b3095357013f3"
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
