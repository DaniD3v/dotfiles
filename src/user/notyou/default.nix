{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../notyou-minimal
    ./backup.nix
  ];

  wayland.windowManager.hyprland.settings = {
    misc.force_default_wallpaper = 0;
  };

  dotfiles = {
    desktop = {
      enable = true;
      theme.mode = "dark";

      envVariables = {
        "GDK_SCALE" = "1.8";
        "QT_SCALE_FACTOR" = "1.8";
      };

      hyprland = {
        mainMonitor = "eDP-1, highrr, 0x0, 1.8";

        monitors = [
          ", preferred, auto, 1, mirror, eDP-1"
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

    programs = {
      alacritty.enable = true;

      librewolf = {
        enable = true;

        extensions = with pkgs.firefox-extensions; [
          bitwarden
        ];

        bookmarks = {
          "Docker Hub" = {
            url = "https://hub.docker.com/search?q=%s";
            keyword = "@dh";
          };
        };
      };
    };

    work.school = {
      enable = true;

      nscs.enable = true;
      dsai.enable = true;
      pos.enable = true;
      wmc.enable = true;
    };

    lsp = {
      dot.enable = true;
      csharp.enable = true;
    };

    language = {
      javascript.enable = true;
      python.enable = true;
      rust.enable = true;
      nix.enable = true;
      cpp.enable = true;
    };

    unfree.whiteList = [
      "ciscoPacketTracer8"
      "datagrip"
      "spotify"

      "binaryninja-free"
      "geogebra"
      "obsidian"
    ];
  };

  home.packages = with pkgs; [
    pkg-shell

    # ctfs
    binaryninja-free
    snicat
    nmap
    gdb

    libreoffice
    unstable.dolphin-emu # HACK: dolphin-emu doesn't build on the stable channel
    nautilus
    baobab
    totem
    warp
    gimp
    eog

    teams-for-linux
    jetbrains.datagrip

    geogebra
    obsidian
    vesktop
    spotify

    adwaita-icon-theme
  ];
}
