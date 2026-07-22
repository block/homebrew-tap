# Release metadata is managed by .github/workflows/bump-cask.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.

cask "qrgo" do
  version "1.4.1"
  sha256 "2ed326019def1ac89c91ff23ea5b559248c2642004c13fc1894b9f48b7738b61"

  url "https://github.com/block/qrgo/releases/download/#{version}/qrgo-release.tar.gz"
  name "QRGo CLI"
  desc "Capture QR codes and launch them in an Android emulator or iOS simulator"
  homepage "https://github.com/block/qrgo"

  depends_on arch: :arm64
  depends_on :macos

  binary "qrgo"

  postflight do
    system_command "/usr/bin/xattr",
                   args:         ["-d", "com.apple.quarantine", "#{staged_path}/qrgo"],
                   must_succeed: false
  end
end
