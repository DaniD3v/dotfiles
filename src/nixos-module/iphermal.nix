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

    path = {
      persistantMount = mkOption {
        type = types.path;
        default = "/persistant";

        example = "/data/persistant";
        description = "Where to mount the persistant storage.";
      };

      rootsDirectory = mkOption {
        type = types.path;
        default = "/roots";

        example = "/old-roots";
        description = "path in `persistantMount` where all of the roots should be stored.";
      };

      newRootCommand = mkOption {
        type = types.str;
        default = "root-$(date -u +%F-%H%M%S)";

        description = "Bash command that generates the name for the root bindmount.";
      };

      currentRootSymlink = mkOption {
        type = types.str;
        default = "current";

        description = "A symlink to the current root.";
      };
    };

    keepOldRoots = {
      # TODO
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
          # The partition is thus manually mounted in a initrd script.
          mountPoint = "//${cfg.path.persistantMount}";
        };

        "iphermal-root" = {
          mountPoint = "/";
          device = "${cfg.path.persistantMount}/${cfg.path.rootsDirectory}/${cfg.path.currentRootSymlink}";
          fsType = "none";
          options = [ "bind" ];
        };
      };

      initrdScript =
        let
          persistantMount = "$targetRoot/${cfg.path.persistantMount}";
        in
        partition: ''
          # manually mount the persistant partition
          #
          # This has to be under `$targetRoot` because otherwise
          # it would get destroyed by `switch_root` (see man)
          mkdir -p "${persistantMount}"
          mount -t ${partition.fsType} \
           "${partition.device}" \
           "${persistantMount}"

          # Create the folder the `$targetRoot` will be bind mounted to
          ROOT="${cfg.path.newRootCommand}"
          mkdir -p "${persistantMount}/${cfg.path.rootsDirectory}/$ROOT"

          # Symlink root directory to `currentRootSymlink`
          # A relative symlink is required due to pivot_root
          ln -sf "./$ROOT" "${persistantMount}/${cfg.path.rootsDirectory}/${cfg.path.currentRootSymlink}"
        '';

      vmVariant = vmVariantPath: {
        ${vmVariantPath} = {
          virtualisation.fileSystems = fileSystemsConfig;

          # lib.mkForce to avoid duplicate entries
          boot.initrd.postResumeCommands = lib.mkForce (
            initrdScript config.virtualisation.${vmVariantPath}.virtualisation.fileSystems."/"
          );
        };
      };
    in
    mkIf cfg.enable {
      fileSystems = fileSystemsConfig;
      boot.initrd.postResumeCommands = initrdScript config.fileSystems."/";

      virtualisation =
        vmVariant "vmVariant"
        // (if options.virtualisation ? vmVariantWithDisko then vmVariant "vmVariantWithDisko" else { });
    };
}
