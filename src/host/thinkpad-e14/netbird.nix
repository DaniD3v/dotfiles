{
  # join once with `sudo netbird-homelab up`
  services.netbird = {
    clients."homelab" = {
      port = 51820;
      environment.NB_MANAGEMENT_URL = "https://vpn.danidev.vip";
    };

    ui.enable = false;
  };
}
