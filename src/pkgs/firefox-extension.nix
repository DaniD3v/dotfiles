rec {
  # Note that this creates an unsigned addon.
  #
  # This means that the browser has to enable `xpinstall.signatures.required`.
  # The addon also needs a id. (browser_specific_settings.gecko.id)
  buildFirefoxExtension =
    {
      lib,
      dLib,
      stdenvNoCC,
      web-ext,
      ...
    }@inputs:
    {
      srcDir,
      overrideManifest ? { },
    }:
    let
      manifest = lib.importJSON "${srcDir}/manifest.json";
      manifestFile = builtins.toJSON (
        dLib.recursiveMergeAttrs [
          {
            browser_specific_settings.gecko.id = "no_id_provided@dotfiles.org";
          }
          manifest
          overrideManifest
        ]
      );
    in
    packageXpiExtension inputs rec {
      pname = manifest.name;
      version = manifest.version;

      src =
        let
          filename = builtins.replaceStrings [ " " ] [ "_" ] (lib.toLower "${pname}-${version}.xpi");

          xpiFile = stdenvNoCC.mkDerivation {
            pname = "${pname}-raw";
            inherit version;

            src = srcDir;
            nativeBuildInputs = [ web-ext ];

            passAsFile = [ "manifestFile" ];
            inherit manifestFile;

            patchPhase = ''
              cat $manifestFilePath > manifest.json
            '';

            buildPhase = ''
              web-ext build \
                --artifacts-dir $out \
                --filename "${filename}"
            '';
          };
        in
        "${xpiFile}/${filename}";
    };

  packageXpiExtension =
    { stdenvNoCC, ... }:
    {
      pname,
      version,
      src,
      meta ? { },
    }:
    stdenvNoCC.mkDerivation {
      inherit
        pname
        version
        src
        meta
        ;

      preferLocalBuild = true;

      buildCommand =
        let
          # Afaik {ec803...84} is a legacy path (used by nix)
          # and could be changed if the hm-module and all extension packages were fixed
          dst = "$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}";
        in
        ''
          install -D "$src" "${dst}/${pname}-${version}.xpi"
        '';
    };
}
