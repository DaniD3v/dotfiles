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
  inherit (lib.generators) mkLuaInline;
in
{
  options.dotfiles.desktop.hyprland = {
    enable = mkEnableOption "Hyprland window manager";

    screenshots.enable = mkOption {
      type = types.bool;
      default = true;

      description = "Whether to enable screenshots using hyprshot";
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
      type = with types; listOf attrs;
      default = [ ];

      example = [
        {
          output = "HDMI-A-1";
          mode = "preferred";
          position = "auto";
          scale = 1;
          mirror = "eDP-1";
        }
      ];
    };

    bindApp =
      let
        bindAppModule.options = {
          bind = mkOption {
            type = types.str;

            description = "The bind to trigger the application launch";
            example = "SUPER + D";
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

    globalBind =
      let
        globalBindModule.options = {
          bind = mkOption {
            type = types.str;

            description = "The bind to trigger the global shortcut";
            example = "SUPER + R";
          };

          shortcut = mkOption {
            type = types.str;

            description = "The global shortcut to trigger, as `appid:name`";
            example = "caelestia:launcher";
          };
        };
      in
      mkOption {
        type = with types; listOf (submodule globalBindModule);

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
      configType = "lua";
      systemd.enable = false; # for UWSM

      settings = {
        monitor = cfg.monitors;

        config.input = cfg.input;

        bind =
          let
            uwsmApp = "${lib.getExe pkgs.uwsm} app --";
            amixer = lib.getExe' pkgs.alsa-utils "amixer";
            brightnessctl = lib.getExe pkgs.brightnessctl;
            playerctl = lib.getExe pkgs.playerctl;

            # Renders to `hl.bind(keys, hl.dsp.<dispatcher>(arg))`.
            # `_args` makes it a two-argument call; the dispatcher is a Lua
            # function call, not data, so it has to be inlined.
            dispatchBind = dispatcher: keys: arg: {
              _args = [
                keys
                (mkLuaInline "hl.dsp.${dispatcher}(${lib.generators.toLua { } arg})")
              ];
            };
            execBind = dispatchBind "exec_raw";
            globalBind = dispatchBind "global";
          in
          mkMerge [
            [
              # shortcut keys
              (execBind "XF86AudioMute" "${amixer} set Master toggle")
              (execBind "XF86AudioMicMute" "${amixer} set Capture toggle")
              (execBind "XF86AudioRaiseVolume" "${amixer} set Master 5%+")
              (execBind "XF86AudioLowerVolume" "${amixer} set Master 5%-")

              (execBind "XF86MonBrightnessUp" "${brightnessctl} s 10%+")
              (execBind "XF86MonBrightnessDown" "${brightnessctl} s 10%-")

              (execBind "XF86AudioPlay" "${playerctl} play")
              (execBind "XF86AudioStop" "${playerctl} stop")
              (execBind "XF86AudioNext" "${playerctl} next")
              (execBind "XF86AudioPrev" "${playerctl} previous")
            ]

            (
              let
                hyprshot = "${lib.getExe pkgs.hyprshot} -o ~/Pictures/screenshots";
              in
              mkIf cfg.screenshots.enable [
                (execBind "PRINT" "${hyprshot} -m output --current")
                (execBind "CTRL + PRINT" "${hyprshot} -m window")
                (execBind "SHIFT + PRINT" "${hyprshot} -m region")
              ]
            )

            (map (bindApp: execBind bindApp.bind "${uwsmApp} ${bindApp.run}") cfg.bindApp)
            (map (bind: globalBind bind.bind bind.shortcut) cfg.globalBind)
          ];
      };

      extraConfig = ''
        require("base")
      '';
    };

    xdg.configFile."hypr/base.lua".source = ./base.lua;

    programs.uwsm.envVariables = config.dotfiles.desktop.envVariables;

    dotfiles.programs.librewolf.bookmarks."Toolbar".bookmarks."Ricing".bookmarks =
      mkIf cfg.browserBookmarks.enable cfg.browserBookmarks.export;
  };
}
