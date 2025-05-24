{
  pkgs,
  lib,
  ...
}: {
  xdg.userDirs.enable = true;

  programs.ashell = {
    enable = true;

    settings = {
      modules = {
        left = [["Workspaces" "WindowTitle"]];
        center = ["Clock"];
        right = [["SystemInfo" "Settings"]];
      };
    };
  };

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
      pos.enable = true;
      wmc.enable = true;
    };

    unfree.whiteList = [
      "packetTracer"
      "datagrip"
      "spotify"

      "geogebra"
      "obsidian"
    ];

    language = {
      javascript.enable = true;
      python.enable = true;
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

        bindApp = [
          {
            bind = "$mainMod, E";
            run = "${lib.getExe pkgs.nautilus} --new-window";
          }
        ];
      };
    };
  };

  home.packages = with pkgs; [
    docker

    nix-index
    nh

    wl-clipboard-rs
    pkg-shell
    ripgrep
    tokei
    tldr

    libreoffice
    nautilus
    geogebra6
    baobab
    warp
    gimp
    eog

    jetbrains.datagrip
    obsidian
    spotify

    whatsapp-for-linux
    vesktop

    adwaita-icon-theme
  ];
}
