{ pkgs, ... }:
{
  services = {
    netbird = {
      package = pkgs.netbird;
      useRoutingFeatures = "both";

      clients."vpn-srino".port = 51820;
      ui.enable = false;
    };

    resolved.enable = true;
  };
}
