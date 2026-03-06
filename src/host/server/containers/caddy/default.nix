{ config, pkgs, ... }:
{
  virtualisation.oci-containers.containers.ingress-caddy =
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

      ports = [
        "443:443/tcp"
        "443:443/udp"
        "80:80/tcp"
        "80:80/udp"

        # oci registry
        "5000:5000/tcp"
        "5000:5000/udp"
      ];

      volumes = [
        "${./Caddyfile}:/etc/caddy/Caddyfile"
        "caddy_data:/data"
      ];
    };
}
