{
  buildFirefoxExtension,
  overrideManifest ? {},
}:
buildFirefoxExtension {
  srcDir = ./.;
  inherit overrideManifest;
}
