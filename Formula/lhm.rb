class Lhm < Formula
  desc "Merges global and repo lefthook configs"
  homepage "https://github.com/block/lhm"
  license "Apache-2.0"
  version "0.9.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/lhm/releases/download/v0.9.0/lhm-aarch64-apple-darwin.bz2"
      sha256 "e81cf795d78360d9495fdd52ab5c1dc2251a283f397d126193fcafe7307a2ef7"
    else
      url "https://github.com/block/lhm/releases/download/v0.9.0/lhm-x86_64-apple-darwin.bz2"
      sha256 "d4a10bf07b08c55948057a6766ac1fed56c2a130ffc6f4cc8f84fa034ec83525"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/lhm/releases/download/v0.9.0/lhm-aarch64-unknown-linux-gnu.bz2"
      sha256 "0c4e393669dfd67788a00a53953b757ca4b719fe52713cf5649009525b308967"
    else
      url "https://github.com/block/lhm/releases/download/v0.9.0/lhm-x86_64-unknown-linux-gnu.bz2"
      sha256 "7d128e9d4702712814d3096136d9d83ca56b2a373a9af065cddef6ec45e02718"
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
