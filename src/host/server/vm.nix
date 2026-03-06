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
        networking.firewall = {
          allowedTCPPorts = [ 6443 ];
          allowedUDPPorts = [ 6443 ];
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
