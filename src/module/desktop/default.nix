{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.dotfiles.desktop;
in {
  imports = [
    ./wallpaper.nix

    ./hyprland.nix
    ./ashell.nix
  ];

  options.dotfiles.desktop.enable = mkOption {
    type = types.bool;
    default = false;

    description = "Whether to enable all components needed for a proper desktop experience.";
  };

  config = mkIf cfg.enable {
    dotfiles.desktop = {
      hyprland.enable = true;
      ashell.enable = true;
    };
  };
}
