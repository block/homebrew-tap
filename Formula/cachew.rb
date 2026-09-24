class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.5.2/cachew-darwin-arm64.tar.gz"
      sha256 "5af3e33bbb7c5bcbc8661b0b989db0967c450d81ac34fce177a85bb9261cd701"
    else
      url "https://github.com/block/cachew/releases/download/v0.5.2/cachew-darwin-amd64.tar.gz"
      sha256 "7553c8b43f96eed301485fface8f4d9e6af8886e52ddfc617c948d3511ffffa5"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.5.2/cachew-linux-arm64.tar.gz"
      sha256 "84c2476ae2df2799c3dfe494f5166f875edb2656351799a4604fc8b76c4cb177"
    else
      url "https://github.com/block/cachew/releases/download/v0.5.2/cachew-linux-amd64.tar.gz"
      sha256 "b16914cc273eda38879879028c82de30c10f84885850913ed6d1e87ee011f307"
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
