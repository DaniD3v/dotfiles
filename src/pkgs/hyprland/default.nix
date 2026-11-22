{ unstable, ... }:
unstable.hyprland.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    ./image-capture-source-removed-outputs.patch
    ./session-lock-inert-surfaces.patch
  ];
})
