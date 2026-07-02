class Lhm < Formula
  desc "Merges global and repo lefthook configs"
  homepage "https://github.com/block/lhm"
  license "Apache-2.0"
  version "0.13.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/lhm/releases/download/v0.13.0/lhm-aarch64-apple-darwin.bz2"
      sha256 "b20640fc91fe21fb9f31a6cc3bc956fe8c2d247f711bb4af19e941044787b36a"
    else
      url "https://github.com/block/lhm/releases/download/v0.13.0/lhm-x86_64-apple-darwin.bz2"
      sha256 "1222fc4accd7989b84d60ce7dc3b85a8e348cc5e2e281834d08936292e915bc0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/lhm/releases/download/v0.13.0/lhm-aarch64-unknown-linux-gnu.bz2"
      sha256 "101f24028ff5941c5ca1fa5974d6e6f7a213b408f4cdf48cd084b1885a36a6a4"
    else
      url "https://github.com/block/lhm/releases/download/v0.13.0/lhm-x86_64-unknown-linux-gnu.bz2"
      sha256 "bd6eac5b984bea1aaa4b121918cdf0cfa33808a59223b5b0b71e4b340104dfd9"
    end
  end

  def install
    # bz2 is auto-extracted by Homebrew; the resulting file needs to be renamed
    binary = buildpath.children.first
    binary.chmod 0755
    bin.install binary => "lhm"
  end

  test do
    system bin/"lhm", "--help"
  end
end
