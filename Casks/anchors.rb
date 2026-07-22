# Release metadata is managed by .github/workflows/bump-cask.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.

cask "anchors" do
  version "0.2.0"
  sha256 "89f85b2079bc4458f4e097ccef9b69aa56d1879176d292ccfd2ecdf330e9d465"

  url "https://github.com/block/anchorsmd/releases/download/#{version}/anchors-release.tar.gz"
  name "Anchors"
  desc "CLI for the ANCHORS requirements-driven development framework"
  homepage "https://github.com/block/anchorsmd"

  binary "anchors"

  on_macos do
    postflight do
      system_command "/usr/bin/xattr",
                     args:         ["-d", "com.apple.quarantine", "#{staged_path}/anchors"],
                     must_succeed: false
    end
  end
end
