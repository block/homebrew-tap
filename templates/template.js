function sha256(assets, pattern) {
  for (const asset of assets) {
    if (asset.name.includes(pattern)) {
      return asset.sha256;
    }
  }
  throw new Error("no asset matching: " + pattern);
}
