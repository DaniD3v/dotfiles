{ config, pkgs, ... }:
{
  # socket-activate caddy
  # this improves performance and preserves source ips
  systemd = {
    sockets.podman-ingress-caddy = {
      listenStreams = [ "[::]:443" ];
      listenDatagrams = [ "[::]:443" ];
      wantedBy = [ "sockets.target" ];
    };
    services."podman-ingress-caddy" = {
      after = [ "podman-ingress-caddy.socket" ];
      requires = [ "podman-ingress-caddy.socket" ];
    };
  };

  virtualisation = {
    # allow containers to resolve each other using hostname
    podman.defaultNetwork.settings.dns_enabled = true;
    # HACK: port 53 is already taken due to dnsmasq
    containers.containersConf.settings.network.dns_bind_port = 1053;

    oci-containers.containers.ingress-caddy =
      let
        imageName = "caddy";
      in

      {
        # don't send impossible acme requests
        autoStart = config.virtualisation.isPhysicalHost;

        image = imageName;
        imageFile = pkgs.dockerTools.pullImage {
          inherit imageName;

          imageDigest = "sha256:fce4f15aad23222c0ac78a1220adf63bae7b94355d5ea28eee53910624acedfa";
          hash = "sha256-fVCVCtTNPyHoOUF04bqmuM6vw6G4fQICSohVnrdQ1sQ=";
        };

        # port 80 is only needed for redirects & acme => fine without socket activation
        ports = [ "80:80" ];

        volumes = [
          "${./Caddyfile}:/etc/caddy/Caddyfile"
          "caddy_data:/data"
        ];
      };
  };
}
