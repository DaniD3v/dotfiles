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
    podman

    nix-index
    nh

    man-pages
    man-pages-posix

    wl-clipboard-rs
    pkg-shell
    ripgrep
    tokei
    nmap
    tlrc
    unp

    libreoffice
    dolphin-emu
    nautilus
    baobab
    totem
    warp
    gimp
    eog

    obsidian
    spotify

    jetbrains.datagrip
    geogebra6
    vesktop

    adwaita-icon-theme
  ];
}
