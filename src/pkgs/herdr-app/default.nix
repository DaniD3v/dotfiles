{
  lib,
  stdenv,
  callPackage,
  fetchurl,
  makeDesktopItem,

  autoPatchelfHook,
  makeWrapper,

  libgcc,
  libxcb,
  libxkbcommon,

  libGL,
  vulkan-loader,
  wayland,
}:

let
  herdr-core = callPackage ./core.nix { };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "herdr-app";
  version = "0.1.13";

  src = fetchurl {
    url = "https://releases.herdr.dev/app/${finalAttrs.version}/herdr-app-linux-x86_64.tar.gz";
    hash = "sha256-d7C+cqRsoUuzZzZaBBZGQfkUs6aXErrDkdOcVqlZvvQ=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    libgcc
    libxcb
    libxkbcommon
  ];

  # dlopened by gpui at runtime
  runtimeDependencies = [
    libGL
    vulkan-loader
    wayland
  ];

  desktopItem = makeDesktopItem {
    name = "herdr-app";
    desktopName = "Herdr";
    comment = "Terminals and coding agents that keep running";
    exec = "herdr-app";
    icon = "herdr-app";
    categories = [ "Development" ];
    startupWMClass = "herdr-app";
  };

  # the svg stays out of libexec: next to the binary it marks a
  # self-updating install, which the read-only store can't be
  installPhase = ''
    runHook preInstall

    install -Dm755 herdr-app $out/libexec/herdr-app/herdr-app
    install -Dm644 herdr-app.svg $out/share/icons/hicolor/scalable/apps/herdr-app.svg
    install -Dm644 ${finalAttrs.desktopItem}/share/applications/*.desktop -t $out/share/applications

    makeWrapper $out/libexec/herdr-app/herdr-app $out/bin/herdr-app \
      --prefix PATH : ${lib.makeBinPath [ herdr-core ]} \
      --set-default HERDR_TELEMETRY 0

    runHook postInstall
  '';

  meta = {
    description = "Terminals and coding agents that keep running";
    homepage = "https://herdr.dev";

    mainProgram = "herdr-app";
    platforms = [ "x86_64-linux" ];

    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
