# Release metadata is managed by .github/workflows/bump-cask.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.

cask "qrgo-app" do
  version "1.3.4"
  url "https://github.com/block/qrgo/releases/download/1.3.4/QRGo-1.3.4-arm64.zip"
  sha256 "00b0915f334294a74906273bd9a6486b9a8d92dcaee36dbe98cd7b1e10c2758c"

  name "QRGo"
  desc "Menu bar QR code scanner for iOS Simulator and Android Emulator"
  homepage "https://github.com/block/qrgo"

  depends_on arch: :arm64
  depends_on formula: "block/tap/qrgo"
  depends_on macos: ">= :monterey"

  app "QRGo.app"

  uninstall launchctl: "com.block.qrgo.menubar",
            quit:      "com.block.qrgo",
            delete:    "~/Library/LaunchAgents/com.block.qrgo.menubar.plist"

  zap trash: [
    "~/Library/Application Support/qrgo",
    "~/Library/Preferences/com.block.qrgo.plist",
    "~/Library/Preferences/qrgo.plist",
  ]
end
