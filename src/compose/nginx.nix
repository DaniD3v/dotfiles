{ pkgs, ... }:
{
  project.name = "nginx";

  services.nginx = {
    image.tarball = pkgs.containers.nginx;

    service = {
      networks = [ "nginx-reverse" ];
      volumes = [

      ];

      ports = [
        "443:443/tcp"
        "443:443/udp" # http3
      ];
    };
  };

  networks.nginx-reverse.name = "nginx-reverse";
}
