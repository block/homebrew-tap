class Stoic < Formula
  desc "CLI tool for Android investigations"
  homepage "https://github.com/block/stoic"
  url "https://github.com/block/stoic/releases/download/v0.4.0/stoic-0.4.0.tar.gz"
  sha256 "28c88cb50bb304e411b11382359f7915bde1154902a2400e6d8efa4b0c8b78ed"
  license "Apache-2.0"

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/stoic"
  end

  test do
    system "#{bin}/stoic", "--help"
  end
end
