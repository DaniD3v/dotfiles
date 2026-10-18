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
    ./hyprland.nix
  ];

  options.dotfiles.desktop = {
    enable = mkEnableOption "requiring a desktop to be installed before building";

    default = mkOption {
      type = types.enum [ "hyprland" ];
      default = "hyprland";

      description = "Default desktop environment to use";
    };
  };

  config = mkIf cfg.enable {
    dotfiles.desktops.${cfg.default}.enable = true;
  };
}
