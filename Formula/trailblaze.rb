# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.
# Run: gh workflow run bump-formula.yaml -f repo=block/trailblaze -f formula=trailblaze -f tag=<tag>

class Trailblaze < Formula
  desc "AI-powered UI testing framework for iOS, Android, and Web"
  homepage "https://github.com/block/trailblaze"
  url "https://github.com/block/trailblaze/releases/download/v2026.06.24/trailblaze.jar"
  sha256 "42df02e7bcddded51070dcf9dddc5cc6a9e1baf8c84c6c419bc9cf737015fd38"
  license "Apache-2.0"
  version "2026.06.24"

  depends_on "openjdk@17"
  # `trailblaze report` shells out to these for its animated exports: ffmpeg for --gif/--video,
  # and libwebp's img2webp/cwebp/webpmux (the `webp` formula) for --webp, since plain ffmpeg
  # isn't built against libwebp. Both are non-keg-only, so the launcher needs no PATH wiring.
  # See https://github.com/block/trailblaze/issues/174
  depends_on "ffmpeg"
  depends_on "webp"

  on_macos do
    depends_on arch: :arm64
  end

  resource "launcher" do
    url "https://github.com/block/trailblaze/releases/download/v2026.06.24/trailblaze"
    sha256 "40187d94748417e74f93eac8fc15afd56381d0c097c3e0dfda9589a08df2cdf1"
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

    # The animated-export tools must actually be installed: img2webp (from `webp`) backs
    # --webp, ffmpeg backs --gif/--video. Both deps are non-keg-only, so they resolve on PATH.
    assert_predicate Formula["webp"].opt_bin/"img2webp", :exist?
    assert_predicate Formula["ffmpeg"].opt_bin/"ffmpeg", :exist?
  end
end
