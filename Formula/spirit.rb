# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Avoid manual edits to `url` and `sha256`; the bump workflow rewrites them.
# Run: gh workflow run bump-formula.yaml -f repo=block/spirit -f formula=spirit -f tag=<tag> -f artifact_url=<artifact_url> [-f sha256=<sha256>]

class Spirit < Formula
  desc "Online schema change and data operations for MySQL 8.0+"
  homepage "https://github.com/block/spirit"
  url "https://github.com/block/spirit/releases/download/v0.17.0/spirit_0.17.0_darwin_arm64.tar.gz"
  sha256 "0673c8ece5b9f17cb1cfb1a77a0b3e8584db48a5f8f7b3db9dced8f2e4154104"
  license "Apache-2.0"
  depends_on arch: :arm64
  depends_on :macos

  def install
    bin.install "spirit"
  end

  test do
    system "#{bin}/spirit", "--help"
  end
end
