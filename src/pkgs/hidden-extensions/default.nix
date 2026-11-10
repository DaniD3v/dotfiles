# Honors manifest `hidden` for every add-on by repacking
# a prebuilt browser's omni.ja, so no rebuild.
{
  runCommand,
  unzip,
  zip,
}:
unwrapped:
let
  name = unwrapped.binaryName;
in
# Same name as the original: the launcher rewrite below needs equally long store paths.
runCommand unwrapped.name
  {
    nativeBuildInputs = [
      unzip
      zip
    ];

    inherit (unwrapped) passthru meta version;
  }
  ''
    cp -rs --no-preserve=mode ${unwrapped} $out
    libDir=$out/lib/${name}

    # The launcher execs this link, so it must stay inside this package.
    ln -sfT ../lib/${name}/${name} $out/bin/.${name}-wrapped

    # Firefox resolves omni.ja relative to the executable's real path, so the
    # executables must be copies, not links into the unpatched package.
    cp --remove-destination ${unwrapped}/lib/${name}/{${name},${name}-bin} $libDir/

    # The launcher sets GTK env vars and execs the original package. Its store
    # path has the same length as ours, so rewriting it keeps the binary valid.
    rm $out/bin/${name}
    sed "s|${unwrapped}|$out|g" ${unwrapped}/bin/${name} > $out/bin/${name}
    chmod +x $out/bin/${name}

    mkdir omni
    # unzip exits 2 on the jar's preload header while still extracting everything.
    unzip -qo ${unwrapped}/lib/${name}/omni.ja -d omni || [ $? -eq 2 ]

    # Drop the privileged-only and no-temporary-install gates on manifest.hidden.
    substituteInPlace omni/modules/Extension.sys.mjs --replace-fail \
      '(this.isPrivileged && this.manifest.hidden)' '!!this.manifest.hidden'
    substituteInPlace omni/modules/addons/XPIDatabase.sys.mjs --replace-fail \
      '(this._hidden && this.isPrivileged && !this.location.isTemporary)' 'this._hidden'
    substituteInPlace omni/modules/addons/XPIInstall.sys.mjs --replace-fail \
      'extension.isPrivileged && manifest.hidden' '!!manifest.hidden'

    rm $libDir/omni.ja
    (cd omni && zip -qr0XD $libDir/omni.ja .)
  ''
