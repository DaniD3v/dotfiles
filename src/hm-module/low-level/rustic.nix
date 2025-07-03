{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.services.rustic;
  tomlFormat = pkgs.formats.toml {};
in {
  options.services.rustic = {
    enable = mkEnableOption "Rustic backups";
    package = mkPackageOption pkgs "rustic" {};

    snapshots = mkOption {
      type = types.attrsOf (types.submodule ({name, ...}: {
        options = {
          source = mkOption {
            type = types.str;
            default = name;

            example = "/etc";
            description = "Directory to be backed up";
          };

          settings = mkOption {
            type = tomlFormat.type;
            default = {};

            example = {
              git-ignore = true;
            };
            description = "Settings for the snapshot";
          };
        };
      }));
      default = {};

      example = {
        "/home".git-ignore = true;
        "/etc" = {};
      };
      description = ''
        Configure the directories to be backup up.
        See `https://github.com/rustic-rs/rustic/tree/main/config#backup-snapshots-backupsnapshots`
      '';
    };

    settings = mkOption {
      type = tomlFormat.type;
      default = {};

      example = {
        repository = {
          repository = "/backup/rustic";
          password-file = "/home/user/.secrets/key-rustic";
          no-cache = true;
        };

        forget = {
          keep-daily = 14;
          keep-weekly = 5;
        };

        backup.exclude-if-present = [".nobackup" "CACHEDIR.TAG"];
      };
      description = ''
        Rustic configuration.
        More information at `https://rustic.cli.rs/docs/commands/init/configuration_file.html`
      '';
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile."rustic/rustic.toml".source = tomlFormat.generate "rustic.toml" (cfg.settings
      // {
        backup.snapshots = lib.mapAttrsToList (_: value:
          value.settings
          // {
            sources = [value.source];
          })
        cfg.snapshots;
      });

    home.packages = [
      cfg.package
    ];
  };
}
