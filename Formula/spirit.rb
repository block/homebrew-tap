# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.
# Run: gh workflow run bump-formula.yaml -f repo=block/spirit -f formula=spirit -f tag=<tag> -f artifact_url=<artifact_url> [-f sha256=<sha256>]

class Spirit < Formula
  desc "Online schema change and data operations for MySQL 8.0+"
  homepage "https://github.com/block/spirit"
  url "https://github.com/block/spirit/releases/download/v0.11.0/spirit_0.11.0_darwin_arm64.tar.gz"
  sha256 "98376654d021dbcbce41c2f631fcf63ee5fbe000edab7ad615a3c7f6722cc30b"
  license "Apache-2.0"
  version "0.11.0"

  def install
    bin.install "spirit"
  end

  test do
    system "#{bin}/spirit", "--help"
  end
end
