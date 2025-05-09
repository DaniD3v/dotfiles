{
  pkgs,
  lib,
  ...
}: {
  dotfiles = {
    programs = {
      alacritty.enable = true;

      librewolf = {
        enable = true;

        extensions = with pkgs.firefox-extensions; [
          bitwarden
        ];
      };
    };

    work.school = {
      enable = true;

      nscs.enable = true;
      wmc.enable = true;
    };

    unfree.whiteList = [
      "packetTracer"
      "datagrip"
      "obsidian"
    ];

    helix.enable = true;

    language = {
      javascript.enable = true;
      rust.enable = true;
      nix.enable = true;
    };

    desktop = {
      enable = true;

      hyprland = {
        mainMonitor = "eDP-1";

        monitors = [
          "HDMI-A-1, preferred, auto, 1, mirror, eDP-1"
        ];

        input = {
          kb_layout = "us,de";
          kb_options = "grp:win_space_toggle";
        };

        bindApp = let
          rofi = "${lib.getExe pkgs.rofi-wayland} -show-icons";
        in [
          {
            bind = "$mainMod, E";
            run = "${lib.getExe pkgs.nautilus} --new-window";
          }

          {
            bind = "$mainMod, R";
            run = "${rofi} -show drun";
          }
        ];
      };
    };
  };

  home.packages = with pkgs; [
    docker

    nix-index
    ripgrep
    tokei

    nautilus
    obsidian
    gimp
    eog

    adwaita-icon-theme
  ];
}
