# Release metadata is managed by .github/workflows/bump-formula.yaml.
# Avoid manual edits to `url`, `sha256`, and `version`; the bump workflow rewrites them.
# Run: gh workflow run bump-formula.yaml -f repo=block/ghost -f formula=ghost -f tag=<tag> -f artifact_url=<artifact_url> [-f sha256=<sha256>]

class Ghost < Formula
  desc "Product-surface composition fingerprints, checks, review, and comparison"
  homepage "https://github.com/block/ghost"
  url "https://github.com/block/ghost/releases/download/anarchitecture-ghost@0.12.1/anarchitecture-ghost-0.12.1.tgz"
  sha256 "336a91d356c04c0d462f2640c3e4191d6f64d87f1b1d611c78d1bb752fadff0e"
  license "Apache-2.0"
  version "0.12.1"

  depends_on "node"

  def install
    # The release artifact is the published npm tarball, which extracts to a
    # `package/` directory containing the built `dist/` and `package.json`.
    # Ship those into libexec, install the (pure-JS) runtime deps, and link
    # the CLI entrypoint onto the PATH.
    libexec.install Dir["package/*"]

    cd libexec do
      system "npm", "install", *std_npm_args(prefix: false), "--omit=dev", "--no-audit", "--no-fund"
    end

    (libexec/"dist/bin.js").chmod 0755
    bin.install_symlink libexec/"dist/bin.js" => "ghost"
  end

  test do
    assert_path_exists bin/"ghost"
    assert_predicate bin/"ghost", :executable?
    assert_match "ghost/#{version}", shell_output("#{bin}/ghost --version")
  end
end
