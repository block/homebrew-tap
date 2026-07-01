# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.
# Run: gh workflow run bump-formula.yaml -f repo=block/trailblaze -f formula=trailblaze -f tag=<tag>

class Trailblaze < Formula
  desc "AI-powered UI testing framework for iOS, Android, and Web"
  homepage "https://github.com/block/trailblaze"
  url "https://github.com/block/trailblaze/releases/download/v2026.07.01.1/trailblaze.jar"
  sha256 "8fb6e76ef27a487f72db37ecad8dc1697047b00441440b21eaa5479483e93692"
  license "Apache-2.0"
  version "2026.07.01.1"

  depends_on "openjdk@21"
  # bun is the JS/TS runtime Trailblaze uses to type-check and analyze TypeScript scripted
  # tools; authoring typed scripted tools needs it on PATH. Non-keg-only, so no wiring needed.
  depends_on "bun"
  # esbuild bundles `.ts` trailmap scripted tools into QuickJS-compatible IIFEs at daemon-init
  # (the inProcess runtime path); without it on PATH those tools silently skip registration.
  depends_on "esbuild"
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
    url "https://github.com/block/trailblaze/releases/download/v2026.07.01.1/trailblaze"
    sha256 "40187d94748417e74f93eac8fc15afd56381d0c097c3e0dfda9589a08df2cdf1"
  end

  def install
    libexec.install cached_download => "trailblaze.jar"
    libexec.install resource("launcher").cached_download => "trailblaze"
    (libexec/"trailblaze").chmod 0755

    (bin/"trailblaze").write_env_script libexec/"trailblaze",
                                        Language::Java.overridable_java_home_env("21")
  end

  test do
    assert_match "Trailblaze v#{version}", shell_output("BLAZE_CDS=0 #{bin}/trailblaze --version")

    # The animated-export tools must actually be installed: img2webp (from `webp`) backs
    # --webp, ffmpeg backs --gif/--video. Both deps are non-keg-only, so they resolve on PATH.
    assert_predicate Formula["webp"].opt_bin/"img2webp", :exist?
    assert_predicate Formula["ffmpeg"].opt_bin/"ffmpeg", :exist?

    # bun (authoring/analyzing TS scripted tools) and esbuild (bundling .ts trailmap tools)
    # must both be on PATH. Non-keg-only.
    assert_predicate Formula["bun"].opt_bin/"bun", :exist?
    assert_predicate Formula["esbuild"].opt_bin/"esbuild", :exist?
  end
end
