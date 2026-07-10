class Lhm < Formula
  desc "Merges global and repo lefthook configs"
  homepage "https://github.com/block/lhm"
  license "Apache-2.0"
  version "0.14.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/lhm/releases/download/v0.14.0/lhm-aarch64-apple-darwin.bz2"
      sha256 "4ddb8bb0d708f17d788bb5b9119c3973860fa47ad413b17a24ef3edaaab341ab"
    else
      url "https://github.com/block/lhm/releases/download/v0.14.0/lhm-x86_64-apple-darwin.bz2"
      sha256 "aceb27952cd8da973d28aa12831a9efb8cc383ee0881fd33b1864edf98ed74b7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/lhm/releases/download/v0.14.0/lhm-aarch64-unknown-linux-gnu.bz2"
      sha256 "b19da8cf42f3b9999549b5bae5fd4cd8fba4de495a9091e49c3b4db4ab3b97f6"
    else
      url "https://github.com/block/lhm/releases/download/v0.14.0/lhm-x86_64-unknown-linux-gnu.bz2"
      sha256 "605003835ee69b449cf11106be441a9e3fb1db1a94103f785583159a64f93948"
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
