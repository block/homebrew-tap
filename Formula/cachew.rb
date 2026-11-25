class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.8.6/cachew-darwin-arm64.tar.gz"
      sha256 "04ac52ea89a2a4a2d07fb96591c89b531861bf1f6332082b0eac6e0f19810e8f"
    else
      url "https://github.com/block/cachew/releases/download/v0.8.6/cachew-darwin-amd64.tar.gz"
      sha256 "2d8858e22234cc723469c8ca48c9ebc1c34258519c1d68170c4939a95c43f286"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.8.6/cachew-linux-arm64.tar.gz"
      sha256 "00d683a422c9886e3a61b04795157a4a7a5d04f0af6386f11494d271f8b060f5"
    else
      url "https://github.com/block/cachew/releases/download/v0.8.6/cachew-linux-amd64.tar.gz"
      sha256 "212c7c56ba94ad539cca10f643cc532501c61212903fa9d254d44e8020e7f62f"
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
