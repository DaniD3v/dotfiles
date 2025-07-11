{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.dotfiles.desktop.theme;
in
  with lib; {
    imports = [
      ./wallpaper.nix
    ];

    options.dotfiles.desktop.theme = {
      mode = mkOption {
        type = types.enum ["light" "dark"];
        default = "dark";

        description = "Whether the colorscheme should be light or dark";
      };
    };

    config = {
      dconf = {
        enable = true;
        settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-${cfg.mode}";
          };
        };
      };

      # this is required to allow setting the xdg darkmode
      xdg.portal.extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  }
