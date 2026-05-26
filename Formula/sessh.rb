# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.
# Run: gh workflow run bump-formula.yaml -f repo=block/sessh -f formula=sessh -f tag=<tag> -f artifact_url=<artifact_url> [-f sha256=<sha256>]

class Sessh < Formula
  desc "SSH with seamless connection recovery"
  homepage "https://github.com/block/sessh"
  url "https://github.com/block/sessh/releases/download/v0.5.0/sessh-0.5.0.tar.gz"
  sha256 "f78a0126245a2db44fcb734cf1a0a88046e6c3c57286dd80c6fb99cba7a22ec5"
  license "Apache-2.0"
  version "0.5.0"

  def install
    bin.install "bin/sessh"
    libexec.install "libexec/sessh"
  end

  test do
    assert_match "sessh #{version}", shell_output("#{bin}/sessh --version")
  end
end
