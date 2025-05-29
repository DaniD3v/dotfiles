{
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    open = true;
    dynamicBoost.enable = true;

    nvidiaSettings = false;

    powerManagement = {
      enable = true;
      finegrained = true; # TODO check if this is still needed
    };

    prime.offload = {
      enable = true;
      enableOffloadCmd = true;
    };
  };
}
