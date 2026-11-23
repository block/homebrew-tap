class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.8.1/cachew-darwin-arm64.tar.gz"
      sha256 "dc292b80f7bc8f44a067b10751dccab25b3612ff444ef6f6f3aca7fab02abeee"
    else
      url "https://github.com/block/cachew/releases/download/v0.8.1/cachew-darwin-amd64.tar.gz"
      sha256 "b715ab9200e0ecbcc511e440f708c2c0c9da0b5f3b470cf787e48a9929e6f859"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.8.1/cachew-linux-arm64.tar.gz"
      sha256 "674c17c0ac17c4457db1934863c0a6f8ec34f23ef8755acb0f93e61ee00648cb"
    else
      url "https://github.com/block/cachew/releases/download/v0.8.1/cachew-linux-amd64.tar.gz"
      sha256 "5df451056c34b2294c65ac1735bb9d2231d14aecb47c0af61c23d7b438a66390"
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
