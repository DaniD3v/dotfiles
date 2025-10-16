prev:
(builtins.mapAttrs (_: p: prev.callPackage p { }) {
  inherit (import ./firefox-extension.nix) buildFirefoxExtension;
  containers = import ./containers;

  ccnace = import ./ccnace;
  pkg-shell = import ./pkg-shell;
  packetTracer = import ./packetTracer.nix;
})
// {
  dLib = import ../lib prev.lib;
}
