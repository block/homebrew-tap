class Stoic < Formula
  desc "CLI tool for Android investigations"
  homepage "https://github.com/block/stoic"
  url "https://github.com/block/stoic/releases/download/v0.1.0/stoic-0.1.0.tar.gz"
  sha256 "eb909b50d632c01ffe8f41565b982027f5950ccc8b0f9417f336cd8e864b69fa"
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
