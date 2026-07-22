# Release metadata is managed by .github/workflows/bump-cask.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.

cask "spirit" do
  version "0.12.0"
  sha256 "99c1d1b2c9e6332473dbf8325cca1ed622708f5826f457ac9c0f225806100fce"

  url "https://github.com/block/spirit/releases/download/v#{version}/spirit_#{version}_darwin_arm64.tar.gz"
  name "Spirit"
  desc "Online schema change and data operations for MySQL 8.0+"
  homepage "https://github.com/block/spirit"

  depends_on arch: :arm64
  depends_on :macos

  binary "spirit"

  postflight do
    system_command "/usr/bin/xattr",
                   args:         ["-d", "com.apple.quarantine", "#{staged_path}/spirit"],
                   must_succeed: false
  end
end
