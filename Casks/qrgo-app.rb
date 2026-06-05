# Release metadata is managed by .github/workflows/bump-cask.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.

cask "qrgo-app" do
  version "1.3.8"
  url "https://github.com/block/qrgo/releases/download/1.3.8/QRGo-1.3.8-arm64.zip"
  sha256 "28cd40a2db309c3c868e0f11252a037840979afcdad473feea8d4698ba76ffa9"

  name "QRGo"
  desc "Menu bar QR code scanner for iOS Simulator and Android Emulator"
  homepage "https://github.com/block/qrgo"

  depends_on arch: :arm64
  depends_on formula: "block/tap/qrgo"
  depends_on macos: ">= :monterey"

  app "QRGo.app"

  postflight do
    system_command "/usr/bin/perl",
                   args:         [
                     "-e",
                     "alarm 10; exec @ARGV",
                     "#{appdir}/QRGo.app/Contents/MacOS/QRGo",
                     "--reconcile-login-item",
                   ],
                   must_succeed: false
  end

  uninstall launchctl: "com.block.qrgo.menubar",
            quit:      "com.block.qrgo",
            delete:    "~/Library/LaunchAgents/com.block.qrgo.menubar.plist"

  zap trash: [
    "~/Library/Application Support/qrgo",
    "~/Library/Preferences/com.block.qrgo.plist",
    "~/Library/Preferences/qrgo.plist",
  ]
end
