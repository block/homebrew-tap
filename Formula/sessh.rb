# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.
# Run: gh workflow run bump-formula.yaml -f repo=block/sessh -f formula=sessh -f tag=<tag> -f artifact_url=<artifact_url> [-f sha256=<sha256>]

class Sessh < Formula
  desc "SSH with persistent tmux-backed sessions"
  homepage "https://github.com/block/sessh"
  url "https://github.com/block/sessh/releases/download/v0.3.0/sessh-release.tar.gz"
  sha256 "63f3acf04850646f46334ab0d96be5a3c6c6a45d20a18190dfe868fcc20d3266"
  license "Apache-2.0"
  version "0.3.0"

  depends_on "python@3.14"

  def install
    libexec.install "sessh"
    (bin/"sessh").write <<~SH
      #!/bin/sh
      exec "#{Formula["python@3.14"].opt_libexec}/bin/python" "#{libexec}/sessh" "$@"
    SH
    chmod 0755, bin/"sessh"
  end

  test do
    assert_match "sessh #{version}", shell_output("#{bin}/sessh --version")
  end
end
