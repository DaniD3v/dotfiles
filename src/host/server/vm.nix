{
  lib,
  ...
}:
{
  options.virtualisation.isPhysicalHost =
    with lib;
    mkOption {
      type = types.bool;
      default = true;

      description = "Whether to enable config that doesn't make sense in a VM.";
    };

  config.virtualisation =
    let
      vmCommon = {
        virtualisation = {
          isPhysicalHost = false;

          forwardPorts = [
            {
              from = "host";
              host.port = 30022;
              guest.port = 22;
            }
            {
              from = "host";
              host.port = 38443;
              guest.port = 8443;
            }
          ];
        };
        networking.firewall.allowedTCPPorts = [ 8443 ]; # incus

        systemd.network = {
          # rename QEMU's NIC to the server's
          links."10-enp15s0" = {
            matchConfig.OriginalName = "eth0";
            linkConfig.Name = "enp15s0";
          };

          # QEMU's user network drops tagged frames, so uplink stays untagged
          networks.enp15s0.bridgeVLANs = [
            {
              PVID = 90;
              EgressUntagged = 90;
            }
          ];

          # QEMU's user network: guest 10.0.2.15, gateway 10.0.2.2
          networks.uplink = {
            address = lib.mkForce [ "10.0.2.15/24" ];
            gateway = lib.mkForce [ "10.0.2.2" ];
          };
        };

        users.users.notyou-minimal.hashedPassword = "";
        security.sudo.wheelNeedsPassword = false;
      };
    in
    {
      vmVariant = vmCommon;
      vmVariantWithDisko = vmCommon;
    };
}
