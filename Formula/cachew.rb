class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.7.0/cachew-darwin-arm64.tar.gz"
      sha256 "a8d415a3b1becdf39f34dae244b71a2ca7f3e02a303e7a05bb4a5e129f94dfea"
    else
      url "https://github.com/block/cachew/releases/download/v0.7.0/cachew-darwin-amd64.tar.gz"
      sha256 "c142a63b427aab71340d1f8b43c43296e82d7ae545d93d1c66244f098c7e1a01"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.7.0/cachew-linux-arm64.tar.gz"
      sha256 "39e770cee9ab736210ca64b2510f9afb493601e423c73c69e2b864ce5a5f616b"
    else
      url "https://github.com/block/cachew/releases/download/v0.7.0/cachew-linux-amd64.tar.gz"
      sha256 "69b07a96a46de5a231cecb62f888ae342cff06d6110f16a24b3be1dd6075bf82"
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
