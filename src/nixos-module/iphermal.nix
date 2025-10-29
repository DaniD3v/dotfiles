{
  lib,
  config,
  modulesPath,
  ...
}:
with lib;
let
  cfg = config.iphermal;
in
{
  imports = [ (modulesPath + "/virtualisation/qemu-vm.nix") ];

  options.iphermal = {
    enable = mkEnableOption "iphermal";

    paths = {
      persistantMount = mkOption {
        type = types.path;
        default = "/persistant";

        example = "/data/persistant";
        description = "Where to mount the persistant storage.";
      };

      rootsDirectory = mkOption {
        type = types.path;
        default = "${cfg.paths.persistantMount}/roots";

        example = "/data/persistant/old-roots";
        description = "Absolute path where all of the roots should be stored.";
      };
    };

    keepOldRoots = {
      enable = mkEnableOption "Whether to keep old roots";
    };
  };

  config =
    let
      fileSystemsConfig = {
        "/" = {
          # HACK: nix tries to topologically sort the filesystems.
          #
          # Because /persistant requires / and / requires /persistant
          # this results in a loop.
          #
          # The partition is manually mounted in a initrd script.
          # It is then re-mounted by nix in a later boot stage.
          mountPoint = "/./${cfg.paths.persistantMount}";
          neededForBoot = true;
        };

        "iphermal-root" = {
          mountPoint = "/";
          device = "${cfg.paths.rootsDirectory}/current";

          fsType = "none";
          options = [ "bind" ];
        };
      };
    in
    mkIf cfg.enable {
      fileSystems = fileSystemsConfig;
      virtualisation.fileSystems = fileSystemsConfig;

      boot.initrd.postResumeCommands = ''
        echo HERE
        set -x

        #       device 
        # mountFs "${cfg.fileSystems}" "${cfg.paths.persistantMount}"
        mkdir -p "$targetRoot/${cfg.paths.rootsDirectory}/current"
        ls "$targetRoot"
        sleep 10

        echo DONE
      '';
    };
}
