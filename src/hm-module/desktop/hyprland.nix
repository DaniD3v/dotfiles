{
  config,
  pkgs,
  lib,
  dLib,
  ...
}:
with lib;
let
  cfg = config.dotfiles.desktop.hyprland;
  inherit (dLib) mkBookmarkOption;
in
{
  options.dotfiles.desktop.hyprland = {
    enable = mkEnableOption "Hyprland window manager";

    screenshots.enable = mkOption {
      type = types.bool;
      default = true;

      description = "Whether to enable screenshots using hyprshot";
    };

    appLauncher.enable = mkOption {
      type = types.bool;
      default = true;

      description = "Whether to enable an application launcher using rofi";
    };

    mainMonitor = mkOption {
      type = types.str;
      default = "";

      example = "eDP-1, preferred, auto, 1";
    };

    input = mkOption {
      type = types.attrs;
      default = { };

      example = {
        kb_layout = "us,de";
        kb_options = "grp:win_space_toggle";
      };
    };

    monitors = mkOption {
      type = with types; listOf str;
      default = [ ];

      example = [
        "HDMI-A-1, preferred, auto, 1, mirror, eDP-1"
      ];
    };

    bindApp =
      let
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

        default = [ ];
        example = [ ];
      };

    browserBookmarks = mkBookmarkOption "Hyprland" {
      "Hyprland".bookmarks = {
        "Wiki".url = "https://wiki.hyprland.org/Configuring";
        "Github".url = "https://github.com/hyprwm/Hyprland";
      };
    };
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false; # for UWSM

      settings = {
        "$mainMod" = "SUPER";

        monitor = [ cfg.mainMonitor ] ++ cfg.monitors;

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
            "windows,          1, 4, overshoot, popin 80%"
            "workspaces,       1, 6, overshoot-light"
            "specialWorkspace, 1, 4, default, slidevert"
          ];
        };

        input = {
          touchpad = {
            natural_scroll = true;
            disable_while_typing = false;
          };
        } // cfg.input;

        gestures.workspace_swipe = true;

        bind =
          let
            windowMovementKeys = {
              "H" = "l";
              "J" = "d";
              "K" = "u";
              "L" = "r";
            };

            windowMovement = lib.flatten (
              lib.attrValues (
                lib.mapAttrs (key: direction: [
                  "$mainMod, ${key}, movefocus, ${direction}"
                  "$mainMod SHIFT, ${key}, swapwindow, ${direction}"
                ]) windowMovementKeys
              )
            );

            workSpaceMovement = lib.flatten (
              map (
                workspace:
                let
                  key = if workspace == 10 then "0" else toString workspace;
                in
                [
                  "$mainMod, ${key}, workspace, ${toString workspace}"
                  "$mainMod SHIFT, ${key}, movetoworkspace, ${toString workspace}"
                ]
              ) (lib.range 1 10)
            );

            uwsmApp = "${lib.getExe pkgs.uwsm} app --";
            amixer = lib.getExe' pkgs.alsa-utils "amixer";
            brightnessctl = lib.getExe pkgs.brightnessctl;
            playerctl = lib.getExe pkgs.playerctl;
          in
          mkMerge [
            [
              # kill
              "$mainMod, C, killactive"
              "$mainMod, F, forcekillactive"

              # floating windows -> see `extraConfig`
              "$mainMod, V, togglefloating"

              # other
              "$mainMod, W, togglespecialworkspace"
              "$mainMod SHIFT, W, movetoworkspacesilent, special"

              ", F11, fullscreen"
              "$mainMod SHIFT, M, execr, ${lib.getExe pkgs.uwsm} stop"

              # shortcut keys
              ", XF86AudioMute,        execr, ${amixer} set Master toggle"
              ", XF86AudioMicMute,     execr, ${amixer} set Capture toggle"
              ", XF86AudioRaiseVolume, execr, ${amixer} set Master 5%+"
              ", XF86AudioLowerVolume, execr, ${amixer} set Master 5%-"

              ", XF86MonBrightnessUp,   execr, ${brightnessctl} s 10%+"
              ", XF86MonBrightnessDown, execr, ${brightnessctl} s 10%-"

              ", XF86AudioPlay, execr, ${playerctl} play"
              ", XF86AudioStop, execr, ${playerctl} stop"
              ", XF86AudioNext, execr, ${playerctl} next"
              ", XF86AudioPrev, execr, ${playerctl} previous"
            ]
            windowMovement
            workSpaceMovement

            (
              let
                hyprshot = "${lib.getExe pkgs.hyprshot} -o ~/screenshots";
              in
              mkIf cfg.screenshots.enable [
                ",      PRINT, execr, ${hyprshot} -m output --current"
                "CTRL,  PRINT, execr, ${hyprshot} -m window"
                "SHIFT, PRINT, execr, ${hyprshot} -m region"
              ]
            )

            (
              let
                rofi = "${lib.getExe pkgs.rofi-wayland} -show-icons -run-command '${uwsmApp} {cmd}'";
              in
              mkIf cfg.appLauncher.enable [
                "$mainMod, R, execr, ${rofi} -show drun"
              ]
            )

            (map (bindApp: "${bindApp.bind}, execr, ${uwsmApp} ${bindApp.run}") cfg.bindApp)
          ];

        # mouse binds
        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
      };

      # These entries are order-dependent
      extraConfig = ''
        bind = $mainMod ALT, V, setfloating
        bind = $mainMod ALT, V, centerwindow

        bind = $mainMod SHIFT, V, setfloating
        bind = $mainMod SHIFT, V, pin
      '';
    };

    programs.uwsm.envVariables = config.dotfiles.desktop.envVariables;

    dotfiles.programs.librewolf.bookmarks."Toolbar".bookmarks."Ricing".bookmarks =
      mkIf cfg.browserBookmarks.enable cfg.browserBookmarks.export;
  };
}
