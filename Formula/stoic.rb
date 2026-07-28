# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Avoid manual edits to `url` and `sha256`; the bump workflow rewrites them.
# Run: gh workflow run bump-formula.yaml -f repo=block/stoic -f formula=stoic -f tag=<tag> -f artifact_url=<artifact_url> [-f sha256=<sha256>]

class Stoic < Formula
  desc "CLI tool for Android investigations"
  homepage "https://github.com/block/stoic"
  url "https://github.com/block/stoic/releases/download/v0.9.1/stoic-release.tar.gz"
  sha256 "d5e3b99bfed472acd0b474d4e447b326c4c3e039712375b8b986c2887fac3871"
  license "Apache-2.0"

  # Only macOS ARM64 uses the native binary; every JVM target needs OpenJDK.
  on_macos do
    on_intel do
      depends_on "openjdk"
    end
  end

  on_linux do
    depends_on "openjdk"
  end

  def install
    libexec.install Dir["*"]

    # Only macOS ARM64 uses the native binary; all other targets use the JVM artifact.
    if OS.mac? && Hardware::CPU.arm?
      bin.install_symlink libexec/"bin/darwin-arm64/stoic"
    else
      bin.write_jar_script libexec/"jar/stoic-host-main.jar", "stoic"
    end
  end

  test do
    system bin/"stoic", "--help"
  end
end
