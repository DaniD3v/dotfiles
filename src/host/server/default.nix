{ config, lib, ... }:
{
  imports = [
    ./hardware.nix
    ./disko.nix

    ./containers
    ./vm.nix
  ];

  services.openssh = {
    enable = true;

    settings = {
      PasswordAuthentication = false;
      AllowUsers = [
        "notyou"
        "eschb"
      ];
    };
  };
  users.users.notyou-minimal.openssh.authorizedKeys.keyFiles = [
    ../../user/notyou-minimal/ssh_key.pub
  ];
  users.users.eschb = {
    isNormalUser = true;
    openssh.authorizedKeys.keyFiles = [ ../../user/eschb/ssh_key.pub ];
  };

  networking = lib.mkMerge [
    {
      resolvconf.useLocalResolver = true;

      # make containers use the local dns server, too.
      useHostResolvConf = true;
    }
    (lib.mkIf config.virtualisation.isPhysicalHost {
      firewall.interfaces."enp15s0" = {
        allowedTCPPorts = [
          53 # dns

          # web
          80
          443
        ];
        allowedUDPPorts = [
          53 # dns
          67 # dhcp

          # web
          80
          443
        ];
      };

      # TODO IPv6 doesn't work due to ISP
      interfaces."enp15s0" = {
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
    })
  ];

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
