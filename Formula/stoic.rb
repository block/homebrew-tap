class Stoic < Formula
  desc "CLI tool for Android investigations"
  homepage "https://github.com/block/stoic"
  url "https://github.com/block/stoic/releases/download/v0.0.4/stoic-0.0.4.tar.gz"
  sha256 "2cf5ce3d2b0d99098232f2fc364fbcc491b2401ef98ddbd4218eab50a8fea6aa"
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
