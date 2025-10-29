{
  lib,
  config,
  options,
  ...
}:
with lib;
let
  cfg = config.iphermal;
in
{
  options.iphermal = {
    enable = mkEnableOption "iphermal";
    enableDiskoSupport = mkEnableOption "iphermal disko support";

    persistantPath = mkOption {
      type = types.path;
      default = "/persistant";

      example = "/data/persistant";
    };

    keepOldRoots = {
      enable = mkEnableOption "Whether to keep old roots";

    };
  };

  config =
    let
      fileSystemsConfig = {
        "/" = {
          mountPoint = cfg.persistantPath;
        };

        "iphermal-root" = {
          mountPoint = "/";
        };
      };
    in
    mkIf cfg.enable {
      fileSystems = fileSystemsConfig;
      # virtualisation.fileSystems = fileSystemsConfig;

      # disko.devices._config.fileSystems =
      #   let
      #     diskoBaseConfig =
      #       (evalModules {
      #         modules = options.disko.devices.type.getSubModules ++ [
      #           (filterAttrsRecursive (k: _: !hasPrefix "_" k) config.disko.devices)
      #         ];
      #       }).config._config.fileSystems;
      #   in
      #   mkMerge [
      #     diskoBaseConfig
      #     fileSystemsConfig
      #   ];
    };
}
