class Cachew < Formula
  desc "Tiered, protocol-aware, caching HTTP proxy for software engineering infrastructure"
  homepage "https://github.com/block/cachew"
  license "Apache-2.0"
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.8.0/cachew-darwin-arm64.tar.gz"
      sha256 "3c714c14f789a1d573bdec30ced89801989c396d3667e32b4c181385e97ccc91"
    else
      url "https://github.com/block/cachew/releases/download/v0.8.0/cachew-darwin-amd64.tar.gz"
      sha256 "46716c685a599fac97d72038022db94cf8517996805e9eaa81f7e930c3d278fb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/cachew/releases/download/v0.8.0/cachew-linux-arm64.tar.gz"
      sha256 "5b4266b22e7768c9f40e410b12c2eb657f0b211cd68b8a1f82affd1126f6c39b"
    else
      url "https://github.com/block/cachew/releases/download/v0.8.0/cachew-linux-amd64.tar.gz"
      sha256 "ea2eee6e45a15bcae60fc2bb83b5855c9ac9b6632979637e03fe3096f4529612"
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
