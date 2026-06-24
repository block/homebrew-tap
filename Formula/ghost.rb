# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.
# Run: gh workflow run bump-formula.yaml -f repo=block/ghost -f formula=ghost -f tag=<tag> -f artifact_url=<artifact_url> [-f sha256=<sha256>]

class Ghost < Formula
  desc "Product-surface composition fingerprints, checks, review, and comparison"
  homepage "https://github.com/block/ghost"
  url "https://github.com/block/ghost/releases/download/anarchitecture-ghost@0.16.0/anarchitecture-ghost-0.16.0.tgz"
  sha256 "09ee885edba2cd8fd054885161a08c5be5b88cb2e61bf14090472ff353ed711e"
  license "Apache-2.0"
  version "0.16.0"

  depends_on "node"

  def install
    # The GitHub release tarball already includes dist/ and node_modules/.
    # Homebrew may run install from either the archive root or the package/
    # directory, so copy whichever directory contains the package contents.
    package_root = Dir.exist?("package") ? "package" : "."
    libexec.install Dir["#{package_root}/*"]

    (libexec/"dist/bin.js").chmod 0755
    bin.install_symlink libexec/"dist/bin.js" => "ghost"
  end

  test do
    assert_path_exists bin/"ghost"
    assert_predicate bin/"ghost", :executable?
    assert_match "ghost/#{version}", shell_output("#{bin}/ghost --version")
  end
end
