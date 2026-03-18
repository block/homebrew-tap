class Lhm < Formula
  desc "Merges global and repo lefthook configs"
  homepage "https://github.com/block/lhm"
  license "Apache-2.0"
  version "0.7.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/lhm/releases/download/v0.7.0/lhm-aarch64-apple-darwin.bz2"
      sha256 "3bcdbe995fde97d9f55e559c85f265fa1984843530331d58f488a8bf7fbb319c"
    else
      url "https://github.com/block/lhm/releases/download/v0.7.0/lhm-x86_64-apple-darwin.bz2"
      sha256 "126854a429cac93ff056f6615787626971dfc72e4b23b78bb0b989548f9f181d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/lhm/releases/download/v0.7.0/lhm-aarch64-unknown-linux-gnu.bz2"
      sha256 "8ef4b76f686879bd623b4b3f665668b192ae698de70d791fe0be1fdbe3d79984"
    else
      url "https://github.com/block/lhm/releases/download/v0.7.0/lhm-x86_64-unknown-linux-gnu.bz2"
      sha256 "7feb0438fcaa8081870a27eead31f61bcdf61da5e53e76a644384c615993fe1d"
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
