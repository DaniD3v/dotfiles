{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.dotfiles.hyprland;
in {
  options.dotfiles.hyprland = {
    enable = mkEnableOption "Hyprland window manager";

    mainMonitor = mkOption {
      type = types.str;
      default = "";

      example = "eDP-1";
    };

    input = mkOption {
      type = types.attrs;
      default = {};

      example = {
        kb_layout = "us,de";
        kb_options = "grp:win_space_toggle";
      };
    };

    monitors = mkOption {
      type = with types; listOf str;
      default = [];

      example = [
        "HDMI-A-1, preferred, auto, 1, mirror, eDP-1"
      ];
    };

    bindApp = let
      bindAppModule.options = {
        bind = mkOption {
          type = types.str;

          description = "The bind to trigger the application launch";
          example = "$mainMod, D";
        };

        run = mkOption {
          type = types.str;

          description = "Path to binary/.desktop file to run";
          example = "${pkgs.alacritty}/bin/alacritty";
        };
      };
    in
      mkOption {
        type = with types; listOf (submodule bindAppModule);

        default = [];
        example = [];
      };
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false; # for UWSM

      settings = {
        "$mainMod" = "SUPER";

        monitor =
          [
            "${cfg.mainMonitor}, preferred, 0x0, 1"
          ]
          ++ cfg.monitors;

        general = {
          border_size = 2;

          gaps_out = 5;
          gaps_in = 3;

          snap.enabled = true;
        };

        decoration = {
          rounding = 5;

          blur = {
            size = 7;
            passes = 4;

            brightness = 0.78;
          };
        };

        animation = {
          bezier = [
            "overshoot, 0.21, 0.82, 0.39, 1.3"
            "overshoot-light, 0.21, 0.82, 0.39, 1.11"
          ];

          animation = [
            "windows,    1, 4, overshoot, popin 80%"
            "workspaces, 1, 6, overshoot-light"
          ];
        };

        input =
          {
            touchpad = {
              natural_scroll = true;
              disable_while_typing = false;
            };
          }
          // cfg.input;

        gestures.workspace_swipe = true;

        bind = let
          windowMovementKeys = {
            "H" = "l";
            "J" = "d";
            "K" = "u";
            "L" = "r";
          };

          windowMovement =
            lib.flatten
            (lib.attrValues (lib.mapAttrs (key: direction: [
                "$mainMod, ${key}, movefocus, ${direction}"
                "$mainMod SHIFT, ${key}, swapwindow, ${direction}"
              ])
              windowMovementKeys));

          workSpaceMovement = lib.flatten (
            map (
              workspace: let
                key =
                  if workspace == 10
                  then "0"
                  else toString workspace;
              in [
                "$mainMod, ${key}, workspace, ${toString workspace}"
                "$mainMod SHIFT, ${key}, movetoworkspace, ${toString workspace}"
              ]
            )
            (lib.range 1 10)
          );
        in
          [
            "$mainMod, C, killactive"
            # "$mainMod, F, forcekillactive"

            ", XF86AudioMute,        execr, ${pkgs.alsa-utils}/bin/amixer set Master toggle"
            ", XF86AudioMicMute,     execr, ${pkgs.alsa-utils}/bin/amixer set Capture toggle"
            ", XF86AudioRaiseVolume, execr, ${pkgs.alsa-utils}/bin/amixer set Master 5%+"
            ", XF86AudioLowerVolume, execr, ${pkgs.alsa-utils}/bin/amixer set Master 5%-"

            ", XF86MonBrightnessUp,   execr, ${pkgs.brightnessctl}/bin/brightnessctl s 10%+"
            ", XF86MonBrightnessDown, execr, ${pkgs.brightnessctl}/bin/brightnessctl s 10%-"

            ", XF86AudioPlay, execr, ${pkgs.playerctl}/bin/playerctl play"
            ", XF86AudioStop, execr, ${pkgs.playerctl}/bin/playerctl stop"
            ", XF86AudioNext, execr, ${pkgs.playerctl}/bin/playerctl next"
            ", XF86AudioPrev, execr, ${pkgs.playerctl}/bin/playerctl previous"

            "$mainMod SHIFT, M, execr, ${pkgs.uwsm}/bin/uwsm stop"
          ]
          ++ windowMovement
          ++ workSpaceMovement
          ++ map (
            bindApp: "${bindApp.bind}, execr, ${pkgs.uwsm}/bin/uwsm app -- ${bindApp.run}"
          )
          cfg.bindApp;

        # mouse binds
        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
      };
    };
  };
}
