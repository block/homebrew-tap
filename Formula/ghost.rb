# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.
# Run: gh workflow run bump-formula.yaml -f repo=block/ghost -f formula=ghost -f tag=<tag> -f artifact_url=<artifact_url> [-f sha256=<sha256>]

class Ghost < Formula
  desc "Product-surface composition fingerprints, checks, review, and comparison"
  homepage "https://github.com/block/ghost"
  url "https://github.com/block/ghost/releases/download/anarchitecture-ghost@0.8.0/anarchitecture-ghost-0.8.0.tgz"
  sha256 "138649923373ed57feb47cb394784dde99295664ffb6a932c744f459a33b3bba"
  license "Apache-2.0"
  version "0.8.0"

  depends_on "node"

  def install
    # The release artifact is the published npm tarball, which extracts to a
    # `package/` directory containing the built `dist/` and `package.json`.
    # Ship those into libexec, install the (pure-JS) runtime deps, and link
    # the CLI entrypoint onto the PATH.
    libexec.install Dir["package/*"]

    cd libexec do
      system "npm", "install", "--omit=dev", "--ignore-scripts", "--no-audit", "--no-fund"
    end

    (libexec/"dist/bin.js").chmod 0755
    bin.install_symlink libexec/"dist/bin.js" => "ghost"
  end

  test do
    assert_path_exists bin/"ghost"
    assert_predicate bin/"ghost", :executable?
  end
end
