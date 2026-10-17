{
  services = {
    netbird = {
      useRoutingFeatures = "both";

      clients."vpn-srino".port = 51820;
    };

    resolved.enable = true;
  };
}
