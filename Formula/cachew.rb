class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.5.4/cachew-darwin-arm64.tar.gz"
      sha256 "0412464deb81f85658e2efdd85eb52e162ae75ea7ccddd66f5343982fc31bdd2"
    else
      url "https://github.com/block/cachew/releases/download/v0.5.4/cachew-darwin-amd64.tar.gz"
      sha256 "1a57f5d5ff42f72c76faccce42abc4b1cee4461ec58e5775d8024dd01471dff0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.5.4/cachew-linux-arm64.tar.gz"
      sha256 "5dc608807de864155b3766555c7c356ea79b2804d85263853b458a748a7a07b4"
    else
      url "https://github.com/block/cachew/releases/download/v0.5.4/cachew-linux-amd64.tar.gz"
      sha256 "b6d5715c3b54c6b9a3398f77028819ab753e2525d7e2a1ca1d5ae07aef5b9702"
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
