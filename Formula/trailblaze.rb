# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Avoid manual edits to `url` and `sha256`; the bump workflow rewrites them.
# Run: gh workflow run bump-formula.yaml -f repo=block/trailblaze -f formula=trailblaze -f tag=<tag>

class Trailblaze < Formula
  desc "AI-powered UI testing framework for iOS, Android, and Web"
  homepage "https://github.com/block/trailblaze"
  url "https://github.com/block/trailblaze/releases/download/v2026.07.21/trailblaze.jar"
  sha256 "95d9454f981b166ecbe292f903f5453d52d1808448d10d7f625a7547dcbc3cc7"
  license "Apache-2.0"

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
    # baguette powers live iOS Simulator H.264 streaming in the /devices viewer and Trail Runner
    # mirror; it's Apple-Silicon + macOS 26 (Tahoe)-only. Gate it to where it can install — on
    # older macOS the iOS stream falls back to JPEG polling, and it's optional at runtime anyway.
    on_tahoe :or_newer do
      depends_on "baguette"
    end
  end

  resource "launcher" do
    url "https://github.com/block/trailblaze/releases/download/v2026.07.21/trailblaze"
    sha256 "444242ef4273cffa27beb9ad472031167f714344600679796f8e0431034e29b9"
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
