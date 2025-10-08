{
  disko.devices =
    let
      mkRaidDevice = number: device: {
        "hdd${toString number}" = {
          type = "disk";
          inherit device;

          content = {
            type = "mdraid";
            name = "data_raid";
          };
        };
      };
    in
    {
      disk = {
        nvme = {
          type = "disk";
          device = "/dev/nvme0n1"; # TODO

          content = {
            type = "gpt";

            partitions = {
              ESP = {
                size = "512M";
                type = "EF00";

                content = {
                  type = "filesystem";
                  format = "vfat";

                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };

              swap = {
                size = "32G";
                content.type = "swap";
              };

              root = {
                size = "100%";

                content = {
                  type = "filesystem";

                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      }
      // (mkRaidDevice 1 "/dev/sda") # TODO
      // (mkRaidDevice 2 "/dev/sdb") # TODO
      // (mkRaidDevice 3 "/dev/sdc") # TODO
      // (mkRaidDevice 4 "/dev/sdd") # TODO
      // (mkRaidDevice 5 "/dev/sde") # TODO
      // (mkRaidDevice 6 "/dev/sdf") # TODO
      // (mkRaidDevice 7 "/dev/sdg") # TODO
      // (mkRaidDevice 8 "/dev/sdh"); # TODO

      mdadm = {
        data_raid = {
          type = "mdadm";
          level = 6;

          content = {
            type = "filesystem";
            format = "ext4";

            mountpoint = "/data";
          };
        };
      };
    };
}
