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

    ./hyprland
    ./caelestia.nix
  ];

  options.dotfiles.desktop = {
    enable = mkOption {
      type = types.bool;
      default = false;

      description = "Whether to enable all components needed for a proper desktop experience.";
    };
  };

  config.dotfiles.desktop = mkIf cfg.enable {
    hyprland.enable = true;
    caelestia.enable = true;
  };
}
