{ lib, ... }:
{
  imports = [
    ./hardware.nix
    ./disko.nix
  ];

  # Remove 32G swap for VMs
  virtualisation.vmVariantWithDisko = {
    disko.devices.disk.nvme.content.partitions.swap.size = lib.mkForce "512M";
    disko.devices.disk.nvme.imageSize = "10G";

    users.users.notyou.hashedPassword = "";
    security.sudo.wheelNeedsPassword = false;
  };

  services.openssh = {
    enable = true;

    settings = {
      PasswordAuthentication = false;
      AllowUsers = [ "notyou" ];
    };
  };
  users.users."notyou".openssh.authorizedKeys.keyFiles = [ ../../user/notyou/ssh_key.pub ];

  networking = {
    nameservers = [ "2001:4bb8:140:f194::10" ];

    interfaces."enp15s0" = {
      ipv6.addresses = [
        {
          address = "2001:4bb8:140:f194::10";
          prefixLength = 64;
        }
      ];
      ipv4.addresses = [
        {
          address = "192.168.0.10";
          prefixLength = 24;
        }
      ];
    };

    defaultGateway = {
      address = "192.168.0.1";
      interface = "enp15s0";
    };
    defaultGateway6 = {
      address = "2001:4bb8:140:f194::";
      interface = "enp15s0";
    };
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
