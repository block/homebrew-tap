# Release metadata is managed by .github/workflows/bump-cask.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.

cask "lhm" do
  arch arm: "aarch64", intel: "x86_64"
  os macos: "apple-darwin", linux: "unknown-linux-gnu"

  version "0.14.0"
  sha256 arm:          "4ddb8bb0d708f17d788bb5b9119c3973860fa47ad413b17a24ef3edaaab341ab",
         intel:        "aceb27952cd8da973d28aa12831a9efb8cc383ee0881fd33b1864edf98ed74b7",
         arm64_linux:  "b19da8cf42f3b9999549b5bae5fd4cd8fba4de495a9091e49c3b4db4ab3b97f6",
         x86_64_linux: "605003835ee69b449cf11106be441a9e3fb1db1a94103f785583159a64f93948"

  url "https://github.com/block/lhm/releases/download/v#{version}/lhm-#{arch}-#{os}.bz2"

  name "lhm"
  desc "Merges global and repo lefthook configs"
  homepage "https://github.com/block/lhm"

  binary "lhm-#{arch}-#{os}", target: "lhm"

  # On macOS, Homebrew sets the flag `com.apple.quarantine` on the downloaded binaries.
  # This step clears the flag.
  on_macos do
    postflight do
      staged_path.glob("lhm-*").each do |binary|
        system_command "/usr/bin/xattr", args: ["-d", "com.apple.quarantine", binary.to_s], must_succeed: false
      end
    end
  end
end
