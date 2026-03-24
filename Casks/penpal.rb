# Release metadata is managed by .github/workflows/bump-cask.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.

cask "penpal" do
  version "0.0.0"
  url "https://github.com/block/builderbot/releases/download/penpal-#{version}/Penpal-#{version}-arm64.zip"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

  name "Penpal"
  desc "Review markdown files and collaborate on them with agents using comment threads"
  homepage "https://github.com/block/builderbot/tree/main/apps/penpal"

  depends_on arch: :arm64

  app "Penpal.app"

  zap trash: [
    "~/Library/Application Support/com.penpal.app",
    "~/Library/Caches/com.penpal.app",
  ]
end
