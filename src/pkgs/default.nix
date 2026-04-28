prev:
(builtins.mapAttrs (_: p: prev.callPackage p { }) {
  inherit (import ./firefox-extension.nix) buildFirefoxExtension;

  ccnace = import ./ccnace;
  lombok = import ./lombok.nix;
  pkg-shell = import ./pkg-shell;
  k3d-podman = import ./k3d-podman.nix;
  patchedCiscoPacketTracer8 = import ./packetTracer.nix;
})
// {
  dLib = import ../lib prev.lib;
}
