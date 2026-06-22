# Release metadata is managed by .github/workflows/bump-cask.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.

cask "qrgo-app" do
  version "1.4.0"
  url "https://github.com/block/qrgo/releases/download/1.4.0/QRGo-1.4.0-arm64.zip"
  sha256 "4915dff1f4512cf8256e1ba313d0433d7212fad808f29e6244fa28b8db1f41f6"

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
