{config, ...}: let
  homeDir = config.home.homeDirectory;
in {
  programs.rclone = let
    secretDir = "${homeDir}/secrets/rclone";
  in {
    enable = true;

    remotes = let
      mountDir = "${homeDir}/mounts";
    in {
      "crypt" = {
        mounts = {
          "/".mountPoint = "${mountDir}/onedrive";
          # mounted seperately if my backup remote ever changes
          "/backup".mountPoint = "${mountDir}/backup";
        };

        secrets.password = "${secretDir}/crypt.key";
        config = {
          type = "crypt";
          remote = "onedrive:data";

          timeout = "10s";
        };
      };

      "onedrive" = {
        # TODO rm
        mounts."/" = {
          mountPoint = "${mountDir}/raw";
        };

        secrets.token = "${secretDir}/onedrive.json";
        config = {
          type = "onedrive";
          drive_id = "b!3v3JoZBmB0S3DNLH3Uff82OTLxLSEGFKtwqB22NWVx0YL_R5F8AOSInnCITBk9zt";
          drive_type = "business";

          vfs_cache_mode = "full";
        };
      };
    };
  };

  services.rustic = {
    enable = true;

    snapshots."/home/notyou".settings = {
      git-ignore = true;
      one-file-system = true;
    };

    settings = {
      repository = {
        repository = "${homeDir}/backup";
        password = "";
      };

      backup.globs = [
        ".cache"
      ];
    };
  };
}
