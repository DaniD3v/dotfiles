{ pkgs, ... }:
{
  services.netbird = {
    package = pkgs.unstable.netbird;
    useRoutingFeatures = "both";

    clients."vpn-srino".port = 51820;
    ui.enable = false;
  };
}
