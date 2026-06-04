# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.
# Run: gh workflow run bump-formula.yaml -f repo=block/trailblaze -f formula=trailblaze -f tag=<tag>

class Trailblaze < Formula
  desc "AI-powered UI testing framework for iOS, Android, and Web"
  homepage "https://github.com/block/trailblaze"
  url "https://github.com/block/trailblaze/releases/download/v2026.06.01/trailblaze.jar"
  sha256 "75e21087b6d9ef3fe5d26cc78c0e4dbf49bd532476bf2ca50f7567fa22d0e11e"
  license "Apache-2.0"
  version "2026.06.01"

  depends_on "openjdk@17"

  on_macos do
    depends_on arch: :arm64
  end

  resource "launcher" do
    url "https://github.com/block/trailblaze/releases/download/v2026.06.01/trailblaze"
    sha256 "29bb0ceb9dbba885b0661d675ec200547cd04d08f68c7c0805f383d7dfc07bb7"
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
