{
  # join once with `sudo tailscale up --login-server https://vpn.srinohosting.com`
  services = {
    tailscale.enable = true;

    # use resolved => MagicDNS resolves tailnet peers by hostname
    resolved.enable = true;
  };
}
