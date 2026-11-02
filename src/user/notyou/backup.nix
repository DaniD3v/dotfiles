{ config, ... }:
let
  homeDir = config.home.homeDirectory;
in
{
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
          endpoint = "home.danidev.vip";
          root = "/data/notyou/backup";
        };

        password = "";
      };
    };
  };
}
