class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.6.0/cachew-darwin-arm64.tar.gz"
      sha256 "529b74181237f5fd689814618f1dd3edcc23a8fb976ffd74330005066a83d698"
    else
      url "https://github.com/block/cachew/releases/download/v0.6.0/cachew-darwin-amd64.tar.gz"
      sha256 "937c81b84e5b0f284f505dcee28899575103266d472ddc7bfc6f701c9c86332c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.6.0/cachew-linux-arm64.tar.gz"
      sha256 "e82a33b1f6c94c3103d3dcfd45da5cc93c26b549c78c03966f408f2c553b15c9"
    else
      url "https://github.com/block/cachew/releases/download/v0.6.0/cachew-linux-amd64.tar.gz"
      sha256 "c59fed469849c447008e083717eaab8cb86e17599191cd1f9f8d74e429780363"
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
