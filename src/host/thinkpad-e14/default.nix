{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
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

  networking = {
    # These make sure k3s has a static dns server
    # HACK
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];

    extraHosts = ''
      127.0.0.1 gitea.pse-cicd
      127.0.0.1 jenkins.pse-cicd
    '';
  };

  # HACK: k3d rootless
  systemd.services."user@".serviceConfig.Delegate = "cpuset";

  # enable podman on user accounts
  virtualisation = {
    podman.enable = true;
    docker.enable = true;
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
