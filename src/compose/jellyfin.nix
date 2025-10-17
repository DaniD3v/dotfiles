{ pkgs, ... }:
{
  project.name = "jellyfin";

  services.jellyfin = {
    image.tarball = pkgs.containers.jellyfin;

    service.networks = [ "nginx-reverse" ];
  };

  networks.nginx-reverse.name = "nginx-reverse";
}
