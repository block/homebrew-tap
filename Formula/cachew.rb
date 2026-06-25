class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  version "0.2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.2.0/cachew-darwin-arm64.tar.gz"
      sha256 "543f2551fc666bbe0cee9e4b0d17aa1bd6cc26f54394c77e01409cdb7fe3c68a"
    else
      url "https://github.com/block/cachew/releases/download/v0.2.0/cachew-darwin-amd64.tar.gz"
      sha256 "c92b0f457129020198e264f434ba91ab28c2ae95a04df31e11ed035441d47a7d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.2.0/cachew-linux-arm64.tar.gz"
      sha256 "12bf56bb5d9ae0562539fbb1ddaaa554149b522d838e0eb949a2c2f198f91d80"
    else
      url "https://github.com/block/cachew/releases/download/v0.2.0/cachew-linux-amd64.tar.gz"
      sha256 "486eae0ab9c2348cee41f3c1566b784f74e573b63fd0f55f3ff1b321752eb80c"
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
