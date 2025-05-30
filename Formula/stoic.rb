class Stoic < Formula
  desc "CLI tool for Android investigations"
  homepage "https://github.com/block/stoic"
  url "https://github.com/block/stoic/releases/download/v0.0.3/stoic-0.0.3.tar.gz"
  sha256 "c7c04f2582ca9488df3185ec5afaf5e91302134f5b0bc5d1ee6fca7fb95c0560"
  license "Apache-2.0"

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/stoic"
  end

  test do
    system "#{bin}/stoic", "--help"
  end
end
