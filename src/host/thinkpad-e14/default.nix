{
  imports = [
    ./hardware.nix
    ./sddm.nix
  ];

  dotfiles = {
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
