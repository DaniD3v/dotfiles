{
  config,
  pkgs,
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

    # HACK
    fixPortals = mkOption {
      type = types.bool;
      default = true;

      description = ''
        Whether to enable `xdg-desktop-portal-gtk`.

        - Adds a file-picker
        - Fixes gnome darkmode
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    xdg.portal.extraPortals = mkIf cfg.fixPortals [
      pkgs.xdg-desktop-portal-gtk
    ];
  };
}
