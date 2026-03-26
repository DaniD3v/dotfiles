{
  services = {
    netbird = {
      clients."vpn-srino".port = 51820;
      ui.enable = false;
    };

    # use resolvd => resolve peers with hostnames.netbird.cloud
    resolved.enable = true;
  };
}
