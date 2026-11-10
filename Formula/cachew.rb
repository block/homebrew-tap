class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.8.2/cachew-darwin-arm64.tar.gz"
      sha256 "5a060a4d8e52ec94184781a88e6f08d37c03c7aa1c80127469648a9e3fb4db3b"
    else
      url "https://github.com/block/cachew/releases/download/v0.8.2/cachew-darwin-amd64.tar.gz"
      sha256 "433ae20cecbe24c6f7f486a9bdf3d863ecc4209fc9b898287d5051a78dd9ca87"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.8.2/cachew-linux-arm64.tar.gz"
      sha256 "42d074ba1ff2b1d9ef35861bfa34586a802fa6536a6699bb40b2393b01af6048"
    else
      url "https://github.com/block/cachew/releases/download/v0.8.2/cachew-linux-amd64.tar.gz"
      sha256 "5dcf180a3a96da65d0cbfca02ffcfc047008d15a64d2cedf1c6e8f31d60dafd3"
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
