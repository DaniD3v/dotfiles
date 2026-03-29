{ pkgs, ... }:
{
  imports = [
    ./hardware.nix

    ./netbird.nix
    ./sddm.nix
  ];

  hardware.bluetooth.enable = true;

  environment.systemPackages = with pkgs; [
    gnome-text-editor
    alacritty
    librewolf
    nautilus

    fastfetch
    nushell
    helix
    btop
    git
  ];

  networking.firewall = {
    # allow KDE Connect
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
  };

  programs = {
    steam.enable = true;
    gnome-disks.enable = true;

    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        libgcc.lib
      ];
    };

    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };

  # HACK: k3d rootless
  systemd.services."user@".serviceConfig.Delegate = "cpuset";

  # enable podman on user accounts
  virtualisation = {
    podman.enable = true;
  };

  services = {
    fprintd.enable = true;

    gvfs.enable = true;
    udisks2.enable = true;

    upower.enable = true;
  };

  dotfiles = {
    unfree.whiteList = [
      "steam"
      "steam-unwrapped"
    ];

    users = {
      "notyou" = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
          "input"
          "dialout"
          "wireshark"
        ];
      };
    };

    boot = {
      animation.enable = true;
      skipGenerationChooser = true;
    };

    desktop = {
      enable = true;
      default = "hyprland";
    };

    location = {
      timezone = "Europe/Vienna";
      locale = "en_US.UTF-8";
    };
  };
}
