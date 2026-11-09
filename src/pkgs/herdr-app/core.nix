{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "herdr-core";
  version = "0.1.19";

  src = fetchurl {
    url = "https://releases.herdr.dev/core/${finalAttrs.version}/herdr-core-linux-x86_64.tar.gz";
    hash = "sha256-Stz7Qj1S8kxcxKHizS/K0fYtKLt3h2rEcsKQgqPqpCQ=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm755 herdr-core $out/bin/herdr-core
    ln -s herdr-core $out/bin/hc

    runHook postInstall
  '';

  meta = {
    homepage = "https://herdr.dev";

    mainProgram = "hc";
    platforms = [ "x86_64-linux" ];

    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
