{ pkgs, ... }:
{
  services = {
    netbird = {
      package = pkgs.netbird;

      clients."vpn-srino".port = 51820;
      ui.enable = false;
    };

    # use resolvd => resolve peers with hostnames.netbird.selfhosted
    resolved.enable = true;
  };
}
