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
