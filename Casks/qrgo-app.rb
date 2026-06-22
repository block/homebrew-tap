# Release metadata is managed by .github/workflows/bump-cask.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.

cask "qrgo-app" do
  version "1.4.1"
  url "https://github.com/block/qrgo/releases/download/1.4.1/QRGo-1.4.1-arm64.zip"
  sha256 "7e8c8cb4023839f9c80136d0d773c3aec43f2de7a4ae3785bd80755ade804e53"

  name "QRGo"
  desc "Menu bar QR code scanner for iOS Simulator and Android Emulator"
  homepage "https://github.com/block/qrgo"

  depends_on arch: :arm64
  depends_on formula: "block/tap/qrgo"
  depends_on macos: :monterey

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
