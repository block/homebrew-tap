class Lhm < Formula
  desc "Merges global and repo lefthook configs"
  homepage "https://github.com/block/lhm"
  license "Apache-2.0"
  version "0.12.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/lhm/releases/download/v0.12.0/lhm-aarch64-apple-darwin.bz2"
      sha256 "9b69278ce447f2793167e822aa684234ae4ccfb3f3580162509645c69234229b"
    else
      url "https://github.com/block/lhm/releases/download/v0.12.0/lhm-x86_64-apple-darwin.bz2"
      sha256 "2b975e4968f112e5db9dab589e58d09997639ca327ba15009e388677a5f37d08"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/lhm/releases/download/v0.12.0/lhm-aarch64-unknown-linux-gnu.bz2"
      sha256 "818f6e5e7bf32eb12585962c2401414a1319a8d1aed5465537fb6bf34ec16da4"
    else
      url "https://github.com/block/lhm/releases/download/v0.12.0/lhm-x86_64-unknown-linux-gnu.bz2"
      sha256 "f4743db21dccfb67c841865d952bbe93cdda58c9bdda6a2d025dca623632e80b"
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
