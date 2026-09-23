class Lhm < Formula
  desc "Merges global and repo lefthook configs"
  homepage "https://github.com/block/lhm"
  license "Apache-2.0"
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/lhm/releases/download/v0.14.1/lhm-aarch64-apple-darwin.bz2"
      sha256 "53c395395f6e9e6d852fe46cdd1d5ae88f85b954932eef6d938ebcc440529499"
    else
      url "https://github.com/block/lhm/releases/download/v0.14.1/lhm-x86_64-apple-darwin.bz2"
      sha256 "d52256b759265cda8e5e6f4333eec4f93a06260c537453099c7e3956cdafac7f"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/lhm/releases/download/v0.14.1/lhm-aarch64-unknown-linux-gnu.bz2"
      sha256 "07bceb59d9137eacb80536e2e173ad957e0f8fdef67ccc2b86e25a30ceb3d2e0"
    else
      url "https://github.com/block/lhm/releases/download/v0.14.1/lhm-x86_64-unknown-linux-gnu.bz2"
      sha256 "213ca1ca3124309d95cb7fd39810bf2478e546866b12d2989f0c8ec3aeac33ae"
    end
  end

  def install
    # bz2 is auto-extracted by Homebrew; the resulting file needs to be renamed
    binary = buildpath.glob("lhm-*").first
    binary.chmod 0755
    bin.install binary => "lhm"
  end

  test do
    system bin/"lhm", "--help"
  end
end
