# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.
# Run: gh workflow run bump-formula.yaml -f repo=block/trailblaze -f formula=trailblaze -f tag=<tag>

class Trailblaze < Formula
  desc "AI-powered UI testing framework for iOS, Android, and Web"
  homepage "https://github.com/block/trailblaze"
  url "https://github.com/block/trailblaze/releases/download/v2026.06.15/trailblaze.jar"
  sha256 "46b443621c92573144b4fcc57c3012d2375cfc95d7357429a796063361253edc"
  license "Apache-2.0"
  version "2026.06.15"

  depends_on "openjdk@17"

  on_macos do
    depends_on arch: :arm64
  end

  resource "launcher" do
    url "https://github.com/block/trailblaze/releases/download/v2026.06.15/trailblaze"
    sha256 "24aafc7429497cdbe957133a07378aa8024773ea8ee8c86f040f92371c4cd5d2"
  end

  def install
    libexec.install cached_download => "trailblaze.jar"
    libexec.install resource("launcher").cached_download => "trailblaze"
    (libexec/"trailblaze").chmod 0755

    (bin/"trailblaze").write_env_script libexec/"trailblaze",
                                        Language::Java.overridable_java_home_env("17")
  end

  test do
    assert_match "Trailblaze v#{version}", shell_output("BLAZE_CDS=0 #{bin}/trailblaze --version")
  end
end
