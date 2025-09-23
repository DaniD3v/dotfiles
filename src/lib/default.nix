lib: with lib; {
  recursiveMergeAttrs = attrs: builtins.foldl' (acc: elem: lib.recursiveUpdate acc elem) { } attrs;

  # example:
  # recursiveMergeAttrsConcatLists [{test=[1];} {test=[2];}] =>
  # {test=[1 2];}
  #
  # copied from `https://stackoverflow.com/a/54505212`
  recursiveMergeAttrsConcatLists =
    attrList:
    let
      f =
        attrPath:
        zipAttrsWith (
          n: values:
          if tail values == [ ] then
            head values
          else if all isList values then
            unique (concatLists values)
          else if all isAttrs values then
            f (attrPath ++ [ n ]) values
          else
            last values
        );
    in
    f [ ] attrList;

  inherit (import ../hm-module/programs/librewolf/bookmark.nix { inherit lib; }) mkBookmarkOption;

  mkWaylandService =
    {
      systemdTarget,
      # this does not do anything yet. It is a banket implementation for the future.
      providesTray ? false, # Whether this service provides a tray
      ...
    }:
    service:
    let
      trayTarget = optional providesTray "tray.target";
    in
    lib.recursiveUpdate {
      Unit = {
        PartOf = [ systemdTarget ] ++ trayTarget;
        After = [ systemdTarget ];

        ConditionEnvironment = "WAYLAND_DISPLAY";
      };

      Install.WantedBy = [ systemdTarget ] ++ trayTarget;
    } service;
}
