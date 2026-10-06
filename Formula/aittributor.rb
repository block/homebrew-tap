class Aittributor < Formula
  desc "Git hook that adds AI agent attribution to commits"
  homepage "https://github.com/block/aittributor"
  license "Apache-2.0"
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/aittributor/releases/download/v0.8.1/aittributor-aarch64-apple-darwin.bz2"
      sha256 "9e38394fcc153dcb3085c25841ec5de7138d49e5da961abeb89998d548a7f059"
    else
      url "https://github.com/block/aittributor/releases/download/v0.8.1/aittributor-x86_64-apple-darwin.bz2"
      sha256 "4785435025943b910c31f2ca8d3058bc84d61f8a70bee484ca599dcf0a12fd14"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/aittributor/releases/download/v0.8.1/aittributor-aarch64-unknown-linux-gnu.bz2"
      sha256 "a0fb006acea3770a8247f5343b600aa9f2e5253d9bc516776db9ba3771fbdd9c"
    else
      url "https://github.com/block/aittributor/releases/download/v0.8.1/aittributor-x86_64-unknown-linux-gnu.bz2"
      sha256 "c43d25a7ae03197dec1df5abf315c6f68dbba3a72cc19dd877fc26b52bf50488"
    end
  end

  def install
    binary = buildpath.glob("aittributor-*").first
    binary.chmod 0755
    bin.install binary => "aittributor"
  end

  test do
    system bin/"aittributor", "--help"
  end
end
