# Release metadata is managed by .github/workflows/bump-cask.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.

cask "sessh" do
  version "0.6.0"
  sha256 "023faab46bae8aca5900d8688d86076d45a5ed87cc9b0d1581213433ac1b3af4"

  url "https://github.com/block/sessh/releases/download/v#{version}/sessh-#{version}.tar.gz"
  name "Sessh"
  desc "SSH with seamless connection recovery"
  homepage "https://github.com/block/sessh"

  binary "sessh-#{version}/bin/sessh"
  binary "sessh-#{version}/bin/sesshmux"

  on_macos do
    postflight do
      binaries = [
        staged_path/"sessh-#{version}/bin/sessh",
        staged_path/"sessh-#{version}/bin/sesshmux",
        *staged_path.glob("sessh-#{version}/libexec/sessh/sesshmux-macos-*"),
      ]
      binaries.each do |binary|
        system_command "/usr/bin/xattr",
                       args:         ["-d", "com.apple.quarantine", binary],
                       must_succeed: false
      end
    end
  end
end
