class Aittributor < Formula
  desc "Git hook that adds AI agent attribution to commits"
  homepage "https://github.com/block/aittributor"
  license "Apache-2.0"
  version "0.8.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/aittributor/releases/download/v0.8.0/aittributor-aarch64-apple-darwin.bz2"
      sha256 "46f3780a9aac54c521471776ac34bc35cab53a7bd7e69295d9a253087b3d5dd4"
    else
      url "https://github.com/block/aittributor/releases/download/v0.8.0/aittributor-x86_64-apple-darwin.bz2"
      sha256 "a17de7bf6dde94e9c63550342dc52803c3126358d82ca0317f677160b709aa94"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/aittributor/releases/download/v0.8.0/aittributor-aarch64-unknown-linux-gnu.bz2"
      sha256 "d006a450862f7e1ded1cb40b1c5f77d5a4f495d513e930c9b9588839154635ac"
    else
      url "https://github.com/block/aittributor/releases/download/v0.8.0/aittributor-x86_64-unknown-linux-gnu.bz2"
      sha256 "f49d356e7fcd00ae04a20054ce07496c26d4e5f9c1f5400d9946273d08ab7f05"
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
