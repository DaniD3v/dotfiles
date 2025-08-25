{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.dotfiles.desktop;
in
{
  imports = [
    ./theme

    ./hyprland.nix
    ./ashell.nix
  ];

  options.dotfiles.desktop = {
    enable = mkOption {
      type = types.bool;
      default = false;

      description = "Whether to enable all components needed for a proper desktop experience.";
    };

    # This is set in each individual backend
    envVariables = mkOption {
      type = with types; attrsOf str;
      default = { };

      description = "Environment variables set in a graphical session.";
    };

    forceWayland = mkOption {
      type = types.bool;
      default = true;

      description = "Whether to force the wayland backend of most apps";
    };
  };

  config.dotfiles.desktop = mkMerge [
    (mkIf cfg.enable {
      hyprland.enable = true;
      ashell.enable = true;
    })

    (mkIf cfg.forceWayland {
      envVariables = {
        "ELECTRON_OZONE_PLATFORM_HINT" = "auto";
      };
    })
  ];
}
