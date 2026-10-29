class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.5.6/cachew-darwin-arm64.tar.gz"
      sha256 "539081e5ff88debd17aa5ab259447c3ac9822c608e359a5b69ab6d5c85d0bdca"
    else
      url "https://github.com/block/cachew/releases/download/v0.5.6/cachew-darwin-amd64.tar.gz"
      sha256 "30d7677674a99a71fae3d5737d8b5ad074f82804625b080cf8d927e5e94a164f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.5.6/cachew-linux-arm64.tar.gz"
      sha256 "6aaf635171b3543f3039f21ca0ef82c5ea69317d9fef8f1728339cbd52215948"
    else
      url "https://github.com/block/cachew/releases/download/v0.5.6/cachew-linux-amd64.tar.gz"
      sha256 "0a8d8623be1c94857243b079d16cd8cc128be8ce55f808c96058422f292742ff"
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
