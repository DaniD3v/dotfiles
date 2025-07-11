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
    enable = mkEnableOption "Whether to require a desktop to be installed before building";

    default = mkOption {
      type = types.enum [ "hyprland" ];
      default = "hyprland";

      description = "Default desktop environment to use";
    };
  };

  config = {
    dotfiles.desktops.${cfg.default}.enable = true;
  };
}
