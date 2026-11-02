{
  lib,
  stdenv,
  fetchurl,

  autoPatchelfHook,
  dpkg,
  makeWrapper,
  wrapGAppsHook3,

  alsa-lib,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libgbm,
  libxkbcommon,
  nspr,
  nss,
  pango,
  systemdLibs,

  libcap_ng,
  libseccomp,
  pipewire,

  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,

  libGL,
  libnotify,
  libpulseaudio,
  libsecret,

  xdg-utils,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "claude-desktop";
  version = "4.4212.0";

  # versions are listed in https://downloads.claude.ai/claude-desktop/apt/stable/dists/stable/main/binary-amd64/Packages
  src = fetchurl {
    url = "https://downloads.claude.ai/claude-desktop/apt/stable/pool/main/c/claude-desktop/claude-desktop_${finalAttrs.version}_amd64.deb";
    hash = "sha256-T89ljg/IlTkKuCWTKHKB37ziYbDsPqkAYOgti/v9eoQ=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libgbm
    libxkbcommon
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    systemdLibs

    libcap_ng
    libseccomp
    pipewire

    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
  ];

  runtimeDependencies = [
    libGL
    libnotify
    libpulseaudio
    libsecret
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/lib usr/share $out

    # the setuid sandbox can't work from the store, Chromium falls back to user namespaces
    rm $out/lib/claude-desktop/chrome-sandbox

    runHook postInstall
  '';

  dontWrapGApps = true;

  postFixup = ''
    makeWrapper $out/lib/claude-desktop/claude-desktop $out/bin/claude-desktop \
      "''${gappsWrapperArgs[@]}" \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]}
  '';

  meta = {
    description = "Desktop application for Claude";
    homepage = "https://claude.com/download";

    mainProgram = "claude-desktop";
    platforms = [ "x86_64-linux" ];

    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
