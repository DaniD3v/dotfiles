lib:
with lib; {
  recursiveMergeAttrs = attrs:
    builtins.foldl' (acc: elem: lib.recursiveUpdate acc elem) {} attrs;

  inherit (import ../hm-module/programs/librewolf/bookmark.nix {inherit lib;}) mkBookmarkOption;

  mkWaylandService = {
    systemdTarget,
    # this does not do anything yet. It is a banket implementation for the future.
    providesTray ? false, # Whether this service provides a tray
    ...
  }: service: let
    trayTarget = optional providesTray "tray.target";
  in
    lib.recursiveUpdate {
      Unit = {
        PartOf = [systemdTarget] ++ trayTarget;
        After = [systemdTarget];

        ConditionEnvironment = "WAYLAND_DISPLAY";
      };

      Install.WantedBy = [systemdTarget] ++ trayTarget;
    }
    service;
}
