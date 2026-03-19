class Aittributor < Formula
  desc "Git hook that adds AI agent attribution to commits"
  homepage "https://github.com/block/aittributor"
  license "Apache-2.0"
  version "0.6.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/aittributor/releases/download/v0.6.0/aittributor-aarch64-apple-darwin.bz2"
      sha256 "c5ec872d59e55e48eae6603fe320261f522724678b7935372bba7481313b3233"
    else
      url "https://github.com/block/aittributor/releases/download/v0.6.0/aittributor-x86_64-apple-darwin.bz2"
      sha256 "91b78f52f38a48bed237970c1341425101cffbe378d19f3f9b48d1616de6b4aa"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/aittributor/releases/download/v0.6.0/aittributor-aarch64-unknown-linux-gnu.bz2"
      sha256 "23b826643a22a13bc3118280c7d528b090b50e35c05d533700e4f3467fa8f2a3"
    else
      url "https://github.com/block/aittributor/releases/download/v0.6.0/aittributor-x86_64-unknown-linux-gnu.bz2"
      sha256 "33b336619a38f3903b6f21fe489d8742dfea0d98b738f08a3bc89cbdf5e82aa8"
    end
  end

  def install
    binary = buildpath.children.first
    binary.chmod 0755
    bin.install binary => "aittributor"
  end

  test do
    system bin/"aittributor", "--help"
  end
end
