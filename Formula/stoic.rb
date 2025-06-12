class Stoic < Formula
  desc "CLI tool for Android investigations"
  homepage "https://github.com/block/stoic"
  url "https://github.com/block/stoic/releases/download/v0.2.0/stoic-0.2.0.tar.gz"
  sha256 "945eac6d39c5ebdf4c98fed5882b401a711633c2103104d8378f76acc8194c19"
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
