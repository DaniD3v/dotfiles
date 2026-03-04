{ config, ... }:
{
  services.k3s = {
    enable = true;
    extraFlags = [ "--default-local-storage-path=/data/k3s" ];

    images = [ config.services.k3s.package.airgap-images ];
  };
}
