{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.dotfiles.desktop.caelestia;
in
{
  options.dotfiles.desktop.caelestia = {
    enable = mkEnableOption "Caelestia desktop shell";

    hyprlandIntegration = mkOption {
      type = types.bool;
      default = true;

      description = "Whether to add hyprland keybinds and UWSM logout for Caelestia.";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.caelestia = {
        enable = true;

        settings = {
          bar = {
            entries = [
              { id = "logo"; }
              { id = "workspaces"; }
              { id = "spacer"; }
              { id = "tray"; }
              { id = "clock"; }
              { id = "statusIcons"; }
              { id = "power"; }
            ];
            clock.showDate = true;
            workspaces = {
              showWindows = false;
              showWindowsOnSpecialWorkspaces = false;
            };
          };

          services = {
            useTwelveHourClock = false;
            weatherUnits = "Celsius";
          };
        };

        cli = {
          enable = true;

          # gtk theming sets the dconf icon theme, defaulting to the uninstalled Papirus
          settings.theme.iconTheme = "Adwaita";
        };
      };

      # HACK: caelestia-cli hardcodes adw-gtk3-dark as the gtk-theme,
      # so GTK3 apps only get its colours with adw-gtk3 installed
      home.packages = [ pkgs.adw-gtk3 ];
    }

    (mkIf cfg.hyprlandIntegration {
      programs.caelestia.settings.session.commands.logout = [
        (getExe pkgs.uwsm)
        "stop"
      ];

      dotfiles.desktop.hyprland.globalBind = [
        {
          bind = "SUPER + R";
          shortcut = "caelestia:launcher";
        }
        {
          bind = "SUPER + N";
          shortcut = "caelestia:lock";
        }
        {
          bind = "SUPER + Delete";
          shortcut = "caelestia:session";
        }
      ];
    })
  ]);
}
