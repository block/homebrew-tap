class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  version "0.1.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.1.0/cachew-darwin-arm64.tar.gz"
      sha256 "c8253639e834aeffda9de8edb3ec73ab5ec501016e03d0a6ffa6848bb061c6ab"
    else
      url "https://github.com/block/cachew/releases/download/v0.1.0/cachew-darwin-amd64.tar.gz"
      sha256 "a9feeb5e3c3b78c0550d1152faee7d976aa2319a48a43c6a246bff606b516073"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.1.0/cachew-linux-arm64.tar.gz"
      sha256 "690935c7e9f8481520f35c2568d72bff2ade8d52172794bb8710588c13656b40"
    else
      url "https://github.com/block/cachew/releases/download/v0.1.0/cachew-linux-amd64.tar.gz"
      sha256 "ffdc8ace9c840eca9dbf01597c86131a10595dae0bd962a2698cf5b5ebd29c62"
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
