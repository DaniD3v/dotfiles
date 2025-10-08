{ lib, ... }:
{
  imports = [
    ./hardware.nix
    ./disko.nix
  ];

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
