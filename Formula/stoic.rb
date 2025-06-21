class Stoic < Formula
  desc "CLI tool for Android investigations"
  homepage "https://github.com/block/stoic"
  url "https://github.com/block/stoic/releases/download/v0.3.0/stoic-0.3.0.tar.gz"
  sha256 "7d0d4deb7dd91f6a231e7d913da417fe5aec9361603635b2af123925f0721257"
  license "Apache-2.0"

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/stoic"
  end

  test do
    system "#{bin}/stoic", "--help"
  end
end
