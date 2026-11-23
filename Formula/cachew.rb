class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.8.3/cachew-darwin-arm64.tar.gz"
      sha256 "e0bf2232b729ba223e069e6e2f4d0e3f2820a41ec7132fe94822d96ea460faf8"
    else
      url "https://github.com/block/cachew/releases/download/v0.8.3/cachew-darwin-amd64.tar.gz"
      sha256 "46d70bd584c61ec2d616312ec236dab5dc4e47b99ae118e3260247c380325095"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.8.3/cachew-linux-arm64.tar.gz"
      sha256 "b9261547971f3a674e3ef2f894406890393407e441f9c9133bb6ff75cc4084ce"
    else
      url "https://github.com/block/cachew/releases/download/v0.8.3/cachew-linux-amd64.tar.gz"
      sha256 "c448c5ddbf48dcfd11660f4ede8fd8d91e5f1caa3bbdc5673c0a7c0dbd7be502"
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
