{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.dotfiles.desktops.hyprland;
in
{
  options.dotfiles.desktops.hyprland = {
    enable = mkEnableOption "Hyprland desktop environment";
  };

  config = mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };
  };
}
