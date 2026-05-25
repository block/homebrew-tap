class Lhm < Formula
  desc "Merges global and repo lefthook configs"
  homepage "https://github.com/block/lhm"
  license "Apache-2.0"
  version "0.10.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/lhm/releases/download/v0.10.0/lhm-aarch64-apple-darwin.bz2"
      sha256 "88557f82f5cb019107a08230cb0252596bc51a1e7227f06786c7c5834a6c1280"
    else
      url "https://github.com/block/lhm/releases/download/v0.10.0/lhm-x86_64-apple-darwin.bz2"
      sha256 "d0887594315a2fea222603c4f36e266fc3498ebab006570d775075408cfff675"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/lhm/releases/download/v0.10.0/lhm-aarch64-unknown-linux-gnu.bz2"
      sha256 "3a4aa7d26169ae2ff68926f3e972b9d670adb9684f269a4aa4d2ee05282543d5"
    else
      url "https://github.com/block/lhm/releases/download/v0.10.0/lhm-x86_64-unknown-linux-gnu.bz2"
      sha256 "f2acb226de0f5511d5e563f012fe152ac3b3a9881d90c1d9a1b47831618697ea"
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
