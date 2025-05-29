class Stoic < Formula
  desc "CLI tool for Android investigations"
  homepage "https://github.com/block/stoic"
  url "https://github.com/block/stoic/releases/download/v0.0.2/stoic-0.0.2.tar.gz"
  sha256 "9e59eb30ea15be23d0bef8551acfd37ed89a90ce4f66958e2778bd8f088cdd56"
  license "Apache-2.0"

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/stoic"
  end

  test do
    system "#{bin}/stoic", "--help"
  end
end
