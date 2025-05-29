{
  imports = [
    ./hardware.nix
    ./nvidia.nix
  ];

  hardware.nvidia.prime = {
    amdgpuBusId = "PCI:05:00:0";
    nvidiaBusId = "PCI:01:00:0";
  };

  dotfiles = {
    boot = {
      animation.enable = true;
      skipGenerationChooser = true;
    };

    desktop = {
      enable = true;
      default = "hyprland";
    };

    unfree.whiteList = [
      "nvidia-x11"
    ];

    location = {
      timezone = "Europe/Vienna";
      locale = "en_US.UTF-8";
    };
  };
}
