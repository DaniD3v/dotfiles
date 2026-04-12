{ config, ... }:
let
  homeDir = config.home.homeDirectory;
in
{
  programs.rclone =
    let
      secretDir = "${homeDir}/secrets/rclone";
    in
    {
      enable = true;

      remotes =
        let
          mountDir = "${homeDir}/mounts";
        in
        {
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

    snapshots.${homeDir}.settings = {
      one-file-system = true;

      git-ignore = true;
      no-require-git = true;

      globs = [
        "!${homeDir}/.kube"
        "!${homeDir}/secrets"
        "!${homeDir}/mounts"

        "!${homeDir}/.cache"
        "!${homeDir}/.config" # .config unneeded redundant thanks to nix
        "!${homeDir}/.local/share/containers"
        "!${homeDir}/.local/share/docker"
        "!${homeDir}/.local/share/Steam"
        "!${homeDir}/.local/share/Trash"
        "!${homeDir}/.local/share/JetBrains"

        "!${homeDir}/.rancher"
        "!${homeDir}/.vscode"
        "!${homeDir}/.gradle"
        "!${homeDir}/.cargo"
        "!${homeDir}/.nuget"
        "!${homeDir}/.npm"
        "!${homeDir}/.m2"
        "!${homeDir}/go"
      ];
    };

    settings = {
      repository = {
        repository = "opendal:sftp";
        options = {
          endpoint = "danidev.vip";
          root = "/data/notyou/backup";
        };

        password = "";
      };
    };
  };
}
