{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.dotfiles.programs.git;
in
{
  options.dotfiles.programs.git = {
    enable = mkEnableOption "configuration of the Git version control system";

    userName = mkOption {
      type = types.str;

      description = "git username";
      example = "DaniD3v";
    };

    userEmail = mkOption {
      type = types.str;

      description = "git email";
      example = "sch220233@spengergasse.at";
    };

    defaultBranchName = mkOption {
      type = types.str;
      default = "main";

      description = "The default git main branch in new repos";
      example = "master";
    };

    sshKey = {
      enable = mkEnableOption "Whether to use ssh keys for authentication";

      keyFile = mkOption {
        type = types.str;

        description = "The ssh key used";
        example = "${config.home.homeDir}/secrets/ssh/git";
      };

      identities = mkOption {
        type =
          with types;
          attrsOf (
            submodule (
              { name, ... }:
              {
                options = {
                  host = mkOption {
                    type = types.str;
                    default = name;

                    description = "The domain the ssh key can be used with";
                    example = "github.com";
                  };

                  user = mkOption {
                    type = types.str;

                    description = "The user the ssh key is valid for";
                    example = "git";
                  };
                };
              }
            )
          );
      };

      useForSigning = mkEnableOption "Whether to use the ssh key for signing git commits";
    };
  };

  config = {
    programs = mkIf cfg.enable {
      git = {
        inherit (cfg) enable userName userEmail;

        signing = mkIf (cfg.sshKey.enable && cfg.sshKey.useForSigning) {
          signByDefault = true;

          key = cfg.sshKey.keyFile;
          format = "ssh";
        };

        extraConfig.init.defaultBranch = cfg.defaultBranchName;
      };

      ssh = mkIf cfg.sshKey.enable {
        enable = true;

        matchBlocks = lib.mapAttrs (
          _: v:
          v
          // {
            identityFile = cfg.sshKey.keyFile;
          }
        ) (cfg.sshKey.identities);
      };
    };
  };
}
