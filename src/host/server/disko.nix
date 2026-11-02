{
  config,
  lib,
  pkgs,
  ...
}:
{
  disko.devices =
    let
      mkRaidDevice = number: id: {
        "hdd${toString number}" = {
          type = "disk";
          device = "/dev/disk/by-id/${id}";

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
          device = "/dev/disk/by-id/nvme-CT1000P5PSSD8_21364242C262";

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

              swap = lib.mkIf config.virtualisation.isPhysicalHost {
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
      // (mkRaidDevice 1 "ata-TOSHIBA_HDWT840_93C2S1G6SRZH")
      // (mkRaidDevice 2 "ata-TOSHIBA_HDWT840_73R3S1XDSRZH")
      // (mkRaidDevice 3 "ata-TOSHIBA_HDWT840_93C2S1EPSRZH")
      // (mkRaidDevice 4 "ata-TOSHIBA_HDWT840_73R3S1KGSRZH")
      // (mkRaidDevice 5 "ata-TOSHIBA_HDWT840_93C2S1FRSRZH")
      // (mkRaidDevice 6 "ata-TOSHIBA_HDWT840_93C2S1G4SRZH")
      // (mkRaidDevice 7 "ata-TOSHIBA_HDWT840_93C2S1G2SRZH")
      // (mkRaidDevice 8 "ata-TOSHIBA_HDWT840_93C2S1EQSRZH");

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

  # report array events (e.g. a failed disk) to the journal
  boot.swraid.mdadmConf = "PROGRAM ${lib.getExe' pkgs.util-linux "logger"}";
}
