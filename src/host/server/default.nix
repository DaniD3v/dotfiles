{ lib, ... }:
{
  imports = [
    ./hardware.nix
    ./disko.nix
  ];

  # Remove 32G swap for VMs
  virtualisation.vmVariantWithDisko = {
    disko.devices.disk.nvme = {
      content.partitions.swap.size = lib.mkForce "512M";
      imageSize = "10G";
    };

    users.users.notyou-minimal.hashedPassword = "";
    security.sudo.wheelNeedsPassword = false;
  };

  services.openssh = {
    enable = true;

    settings = {
      PasswordAuthentication = false;
      AllowUsers = [ "notyou" ];
    };
  };
  users.users.notyou-minimal.openssh.authorizedKeys.keyFiles = [
    ../../user/notyou-minimal/ssh_key.pub
  ];

  networking = {
    nameservers = [ "192.168.0.1" ];

    interfaces."enp15s0" = {
      # TODO talk with ISP...
      # ipv6.addresses = [
      #   {
      #     address = "2001:4bb8:140:f194::10";
      #     prefixLength = 64;
      #   }
      # ];
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
    # TODO talk to ISP ):
    # defaultGateway6 = {
    #   address = "2001:4bb8:140:f194::";
    #   interface = "enp15s0";
    # };
  };

  dotfiles = {
    users = {
      "notyou-minimal" = {
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
