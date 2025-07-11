prev:
(builtins.mapAttrs (_: p: prev.callPackage p { }) {
  inherit (import ./firefox-extension.nix) buildFirefoxExtension;

  ccnace = import ./ccnace;
  pkg-shell = import ./pkg-shell;
  packetTracer = import ./packetTracer.nix;
})
// {
  dLib = import ../lib prev.lib;
}
