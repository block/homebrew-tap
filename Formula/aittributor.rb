class Aittributor < Formula
  desc "Git hook that adds AI agent attribution to commits"
  homepage "https://github.com/block/aittributor"
  license "Apache-2.0"
  version "0.5.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/aittributor/releases/download/v0.5.0/aittributor-aarch64-apple-darwin.bz2"
      sha256 "118d962237b68dd836444ee6a637991dcdba234c8cb65332b84a23efc841a93c"
    else
      url "https://github.com/block/aittributor/releases/download/v0.5.0/aittributor-x86_64-apple-darwin.bz2"
      sha256 "48fcc66fdfdf7c8a7c39e916ffa0334b5ef3cc3e6d81951898527c68fa447a46"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/aittributor/releases/download/v0.5.0/aittributor-aarch64-unknown-linux-gnu.bz2"
      sha256 "f84969ffcf1f716cbe99702b0ce47dc97a432340ef7aa39ec919b21d65ae8a95"
    else
      url "https://github.com/block/aittributor/releases/download/v0.5.0/aittributor-x86_64-unknown-linux-gnu.bz2"
      sha256 "1787ca15cdcbf5b4e771c37d3d01ba034d91925ccf933a0e18b0c6c3b47f8a12"
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
