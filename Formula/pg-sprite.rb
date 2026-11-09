# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Run: gh workflow run bump-formula.yaml -f repo=block/pg-sprite -f formula=pg-sprite -f tag=<tag>

class PgSprite < Formula
  desc "Online schema change engine for PostgreSQL"
  homepage "https://github.com/block/pg-sprite"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/pg-sprite/releases/download/v0.5.0/pg-sprite_0.5.0_darwin_arm64.tar.gz"
      sha256 "c4f1743a40bafddb06a6874f0850288510179e9d8afeac3d07569b218c432c68"
    else
      url "https://github.com/block/pg-sprite/releases/download/v0.5.0/pg-sprite_0.5.0_darwin_amd64.tar.gz"
      sha256 "511b7f638cb2b0dfa2b573faeb73ff670ab9bc513953d417fb37609b1cc09db8"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/pg-sprite/releases/download/v0.5.0/pg-sprite_0.5.0_linux_arm64.tar.gz"
      sha256 "d3b5eddde3e425e7f714d2c926b2caa529e76f6437ab8e6b857b8c1f8097b6b9"
    else
      url "https://github.com/block/pg-sprite/releases/download/v0.5.0/pg-sprite_0.5.0_linux_amd64.tar.gz"
      sha256 "b0b1236741544be86dc6d5435efd13d0702972e8406049d2851a865b9a2b89b6"
    end
  end

  def install
    bin.install "pg-sprite"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pg-sprite --version")
    assert_match "Usage:", shell_output("#{bin}/pg-sprite --help")
  end
end
