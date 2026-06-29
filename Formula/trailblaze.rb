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
  # `ffmpeg-full` (not plain `ffmpeg`) so `trailblaze report --webp` has the `libwebp_anim`
  # encoder: homebrew-core's `ffmpeg` is NOT built against libwebp. ffmpeg-full is a
  # superset, so it also covers `--gif` and `--video` (libx264). It's keg-only, so the
  # wrapper below prepends its bin to PATH; see https://github.com/block/trailblaze/issues/174.
  depends_on "ffmpeg-full"

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

    env = Language::Java.overridable_java_home_env("17")
    # Prepend keg-only ffmpeg-full's bin so the wrapper finds the libwebp-capable ffmpeg
    # (see #174). write_env_script writes PATH="…:$PATH"; bash expands $PATH at runtime, so
    # the user's PATH is preserved, and prepending wins over a plain `ffmpeg` lacking libwebp.
    env["PATH"] = "#{Formula["ffmpeg-full"].opt_bin}:$PATH"

    (bin/"trailblaze").write_env_script libexec/"trailblaze", env
  end

  test do
    assert_match "Trailblaze v#{version}", shell_output("BLAZE_CDS=0 #{bin}/trailblaze --version")

    # The wrapper must carry ffmpeg-full's opt_bin on PATH so `report --webp/--gif/--video`
    # finds a libwebp_anim-capable ffmpeg (#174). Assert the generated launcher's PATH entry
    # and that the bundled ffmpeg actually exposes the libwebp_anim encoder.
    assert_match Formula["ffmpeg-full"].opt_bin.to_s, (bin/"trailblaze").read
    assert_match "libwebp_anim",
                 shell_output("#{Formula["ffmpeg-full"].opt_bin}/ffmpeg -hide_banner -encoders 2>&1")
  end
end
