{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.dotfiles.desktop.noctalia;
in
{
  options.dotfiles.desktop.noctalia = {
    enable = mkEnableOption "Noctalia desktop shell";

    hyprlandIntegration = mkOption {
      type = types.bool;
      default = true;

      description = "Whether to add hyprland keybinds for Noctalia.";
    };

    extraThemes = {
      librewolf = mkOption {
        type = types.bool;
        default = config.dotfiles.programs.librewolf.enable;

        description = "Whether to install pywalfox to theme librewolf.";
      };
    };
  };

  config = {
    programs.noctalia-shell = mkIf cfg.enable {
      enable = true;
      systemd.enable = true;
      package = pkgs.noctalia;

      plugins = {
        version = 2;
        sources = [
          {
            enabled = true;
            name = "Noctalia Plugins";
            url = "https://github.com/noctalia-dev/noctalia-plugins";
          }
        ];
        states = {
          kde-connect = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
          privacy-indicator = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
          translator = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
        };
      };
      pluginSettings.privacy-indicator.hideInactive = true;

      settings = {
        general = {
          scaleRatio = 0.7;
          radiusRatio = 0.4;
          iRadiusRatio = 0.3;
          animationSpeed = 1.3;

          lockOnSuspend = true;
          lockScreenBlur = 0.8;
          lockScreenTint = 0.2;

          dimmerOpacity = 0.6;
        };
        ui = {
          panelBackgroundOpacity = 0.65;
          translucentWidgets = true;
        };
        colorSchemes.useWallpaperColors = true;
        templates.activeTemplates = [
          {
            enabled = true;
            id = "alacritty";
          }
          {
            enabled = true;
            id = "btop";
          }
          {
            enabled = true;
            id = "discord";
          }
          {
            enabled = true;
            id = "gtk";
          }
          {
            enabled = true;
            id = "hyprland";
          }

          {
            enabled = true;
            id = "pywalfox";
          }
          # # TODO: work required
          # {
          #   enabled = true;
          #   id = "steam";
          # }
          # {
          #   enabled = true;
          #   id = "spicetify";
          # }
          # # TODO do I want to theme helix with this?
          # {
          #   enabled = true;
          #   id = "helix";
          # }
        ];

        notifications = {
          backgroundOpacity = 0.5;

          lowUrgencyDuration = 2;
          normalUrgencyDuration = 4;
          criticalUrgencyDuration = 10;
        };
        idle = {
          enabled = true;
          fadeDuration = 15;
        };
        nightLight = {
          enabled = true;
          dayTemp = "5000";
          nightTemp = "3000";
        };
        location = {
          # TODO: move this into a user-controlled option
          name = "Vienna";
          firstDayOfWeek = 1;

          weatherEnabled = false;
        };
        osd.autoHideMs = 2000;

        bar = {
          density = "mini";
          fontScale = 0.8;

          # move windows slightly downward
          enableExclusionZoneInset = true;

          widgets = {
            left = [
              { id = "Launcher"; }
              { id = "Workspace"; }
            ];
            center = [
              { id = "MediaMini"; }
              {
                id = "Clock";
                formatHorizontal = "HH:mm ddd, dd.MM.";
                tooltipFormat = "HH:mm:ss ddd, dd.MM.";
              }
              {
                id = "plugin:privacy-indicator";
                defaultSettings.hideInactive = true;
              }
            ];
            right = [
              { id = "NotificationHistory"; }
              { id = "plugin:kde-connect"; }
              {
                id = "SystemMonitor";
                showNetworkStats = true;
              }
              {
                id = "KeyboardLayout";
                displayMode = "forceOpen";
              }
              {
                id = "Battery";
                displayMode = "icon-always";
              }
              { id = "ControlCenter"; }
            ];
          };
        };

        controlCenter = {
          cards = [
            {
              id = "profile-card";
              enabled = true;
            }
            {
              id = "shortcuts-card";
              enabled = true;
            }
            {
              id = "audio-card";
              enabled = true;
            }
            {
              id = "brightness-card";
              enabled = true;
            }
          ];

          shortcuts = {
            left = [
              { id = "Network"; }
              { id = "Bluetooth"; }
              { id = "AirplaneMode"; }
            ];
            right = [
              { id = "KeepAwake"; }
              { id = "NightLight"; }
              { id = "WallpaperSelector"; }
            ];
          };

        };

        appLauncher = {
          enableClipboardHistory = true;

          density = "compact";
          enableSettingsSearch = false;
          showCategories = false;
        };
        sessionMenu = {
          largeButtonsStyle = false;
          powerOptions = [
            {
              action = "lock";
              enabled = true;
            }
            {
              action = "hibernate";
              enabled = true;
            }
            {
              action = "logout";
              enabled = true;
            }
            {
              action = "reboot";
              enabled = true;
            }
            {
              action = "shutdown";
              enabled = true;
            }
          ];
        };
        dock.enabled = false;
      };
    };

    dotfiles.desktop.hyprland.bindApp =
      let
        noctaliaExe = "${lib.getExe pkgs.noctalia} ipc call";
      in
      mkIf cfg.hyprlandIntegration [
        {
          bind = "$mainMod, R";
          run = "${noctaliaExe} launcher toggle";
        }
        {
          bind = "$mainMod, S";
          run = "${noctaliaExe} controlCenter toggle";
        }
        {
          bind = "$mainMod, N";
          run = "${noctaliaExe} lockScreen lock";
        }
        {
          bind = "$mainMod, P";
          run = "${noctaliaExe} wallpaper toggle";
        }
      ];

    home.packages = mkIf cfg.extraThemes.librewolf [
      pkgs.pywalfox-native
    ];
  };
}
