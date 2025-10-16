{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./backup.nix
  ];

  xdg.userDirs.enable = true;

  wayland.windowManager.hyprland.settings = {
    misc.force_default_wallpaper = 0;
  };

  programs.nushell = {
    shellAliases = {
      "c" = "with-env {\"SHLVL\": 0} {job spawn {alacritty --working-directory .}}";
    };
  };

  dotfiles = {
    programs = {
      alacritty.enable = true;

      git = {
        enable = true;

        userName = "DaniD3v";
        userEmail = "sch220233@spengergasse.at";

        sshKey = {
          enable = true;
          useForSigning = true;

          keyFile = "~/secrets/git.key";
          identities = {
            "github.com".user = "git";
          };
        };
      };

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

    unfree.whiteList = [
      "packetTracer"
      "datagrip"
      "spotify"

      "binaryninja-free"
      "geogebra"
      "obsidian"
    ];

    lsp = {
      dot.enable = true;
      csharp.enable = true;
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
  };

  home.packages = with pkgs; [
    podman-compose
    podman

    nix-index
    nh

    man-pages
    man-pages-posix

    wl-clipboard-rs
    distrobox
    pkg-shell
    ripgrep
    tokei
    tlrc
    unp

    # ctfs
    binaryninja-free
    snicat
    nmap
    gdb

    libreoffice
    dolphin-emu
    nautilus
    baobab
    totem
    warp
    gimp
    eog

    teams-for-linux
    obsidian
    spotify

    jetbrains.datagrip
    geogebra
    vesktop

    adwaita-icon-theme
  ];
}
