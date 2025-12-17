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

  # enable podman on user accounts
  virtualisation = {
    podman.enable = true;
  };

  services = {
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
