{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./backup.nix
  ];

  xdg.userDirs.enable = true;

  programs.git = {
    enable = true;

    extraConfig.user = {
      name = "DaniD3v";
      email = "sch220233@spengergasse.at";
    };
  };

  # TODO make this a wrapped dotfiles module
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

  wayland.windowManager.hyprland.settings = {
    misc.force_default_wallpaper = 0;
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
      # enable = true;

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

    lsp = {
      dot.enable = true;
    };

    language = {
      javascript.enable = true;
      python.enable = true;
      rust.enable = true;
      nix.enable = true;
    };

    desktop = {
      enable = true;
      theme.mode = "dark";

      hyprland = {
        # mainMonitor = "eDP-1";
        # HACK: Hyprland broken
        mainMonitor = "desc:Najing CEC Panda FPD Technology CO. ltd";

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
