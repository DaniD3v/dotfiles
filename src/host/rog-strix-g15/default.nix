{
  imports = [
    ./hardware.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    timeout = 0;
  };

  dotfiles = {
    location = {
      timezone = "Europe/Vienna";
      locale = "en_US.UTF-8";
    };

    desktop = {
      enable = true;
      default = "hyprland";
    };
  };
}
