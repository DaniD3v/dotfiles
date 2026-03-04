{ lib, ... }:
{
  imports = [
    ./hardware.nix
    ./disko.nix

    ./k3s.nix
  ];

  virtualisation =
    let
      vmCommon = {
        virtualisation = {
          memorySize = 8 * 1024; # k3s needs a decent amount of memory

          # forward k3s
          forwardPorts = [
            {
              from = "host";
              host.port = 30022;
              guest.port = 22;
            }
            {
              from = "host";
              host.port = 36443;
              guest.port = 6443;
            }
          ];
        };

        networking = {
          firewall = {
            allowedTCPPorts = [ 6443 ];
            allowedUDPPorts = [ 6443 ];
          };

          interfaces = lib.mkForce { };
        };

        users.users.notyou-minimal.hashedPassword = "";
        security.sudo.wheelNeedsPassword = false;
      };
    in
    {
      vmVariant = vmCommon;
      vmVariantWithDisko = vmCommon // {
        # Remove 32G swap for VMs
        disko.devices.disk.nvme = {
          content.partitions.swap.size = lib.mkForce "10M";
          imageSize = "10G";
        };

        # HACK: a bug in disko causes
        # 2 fstab entries to be generated
        swapDevices = lib.mkForce [ ];
      };

      docker.enable = true;
    };

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

    openssh.authorizedKeys.keyFiles = [
      ../../user/eschb/ssh_key.pub
    ];
  };

  networking = {
    nameservers = [ "192.168.0.1" ];

    firewall.interfaces."enp15s0".allowedTCPPorts = [
      80
      443
    ];

    firewall.interfaces."enp15s0".allowedUDPPorts = [
      80
      443
    ];

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
