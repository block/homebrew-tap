class Stoic < Formula
  desc "CLI tool for Android investigations"
  homepage "https://github.com/block/stoic"
  url "https://github.com/block/stoic/releases/download/v0.0.5/stoic-0.0.5.tar.gz"
  sha256 "f1e67b957cb20ed7ab0433c788f9df523b8b9ba9cd9790fbdc090355a21c5f30"
  license "Apache-2.0"

  depends_on "rsync"  # Ensure modern rsync is available

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/stoic"
  end

  test do
    system "#{bin}/stoic", "--help"
  end
end
