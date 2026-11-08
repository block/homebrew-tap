# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Run: gh workflow run bump-formula.yaml -f repo=block/pg-sprite -f formula=pg-sprite -f tag=<tag>

class PgSprite < Formula
  desc "Online schema change engine for PostgreSQL"
  homepage "https://github.com/block/pg-sprite"
  license "Apache-2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/block/pg-sprite/releases/download/v0.4.1/pg-sprite_0.4.1_darwin_arm64.tar.gz"
      sha256 "9f2f423cea049954ac9a2cae4f538dd882d735ae4784b14d125b66135ecad512"
    else
      url "https://github.com/block/pg-sprite/releases/download/v0.4.1/pg-sprite_0.4.1_darwin_amd64.tar.gz"
      sha256 "2aeabbde1bd459cf5ae970e6cb0e8b5c953b3fcce44f870f1cad9aa19dc5ac7b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/block/pg-sprite/releases/download/v0.4.1/pg-sprite_0.4.1_linux_arm64.tar.gz"
      sha256 "cf4f22e467e03262e18d9aac52e08b6ae68b0820c8459b7e50acc749b427bc77"
    else
      url "https://github.com/block/pg-sprite/releases/download/v0.4.1/pg-sprite_0.4.1_linux_amd64.tar.gz"
      sha256 "1feb05aef3fb928e275661fdd22ad06a881b932d424fe2a3892ca3d6bc73f019"
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
