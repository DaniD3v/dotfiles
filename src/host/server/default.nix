{ lib, ... }:
{
  imports = [
    ./hardware.nix
    ./disko.nix
  ];

  virtualisation.arion = {
    backend = "podman-socket";

    projects = {
      nginx.settings = {
        project.name = "nginx";

        services.nginx.service = {
          image = "nginx";
          networks = [ "nginx-reverse" ];
        };

        networks.nginx-reverse = { };
      };

      jellyfin.settings = {
        project.name = "jellyfin";

        services.jellyfin.service = {
          image = "jellyfin/jellyfin";
          networks = [ "nginx-reverse" ];

          ports = [
            # "8096:8096/tcp"
            # "7359:7359/udp"
          ];
        };

        networks.nginx-reverse.external = true;
      };
    };
  };

  # Remove 32G swap for VMs
  virtualisation.vmVariantWithDisko = {
    disko.devices.disk.nvme.content.partitions.swap.size = lib.mkForce "512M";

    users.users.notyou.hashedPassword = "";
    security.sudo.wheelNeedsPassword = false;
  };

  dotfiles = {
    users = {
      "notyou" = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "input"
        ];
      };
    };

    location = {
      timezone = "Europe/Vienna";
      locale = "en_US.UTF-8";
    };
  };
}
