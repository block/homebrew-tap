class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.5.8/cachew-darwin-arm64.tar.gz"
      sha256 "7268ba5ed0d17fddc61447365c363f9c644600f33fa710fd6f42c70d4cbea3a4"
    else
      url "https://github.com/block/cachew/releases/download/v0.5.8/cachew-darwin-amd64.tar.gz"
      sha256 "6fe480dc39e15fd24cb2f61ef2d4624b8999af08587c8e147a19fc3c7784e50f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.5.8/cachew-linux-arm64.tar.gz"
      sha256 "a5e4ae5683f5718cc19f368d7ee903bb5d2b23b9e63935d62e7fed8d2c18049e"
    else
      url "https://github.com/block/cachew/releases/download/v0.5.8/cachew-linux-amd64.tar.gz"
      sha256 "e0af7035dcb2b4e2ddf71ba258c840bc2a8c96f7c31debdf00a06b784cad8a6f"
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
