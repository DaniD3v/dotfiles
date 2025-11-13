{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.dotfiles.shells.nushell;
in
{
  imports = [ ];

  options.dotfiles.shells.nushell = {
    enable = mkEnableOption "Nushell";

    fixHomeSessionVariables = mkOption {
      type = types.bool;
      default = true;

      description = "Whether to fix the `home.sessionVariables` option for nushell";
    };

    nixIntegration.enable = mkOption {
      type = types.bool;
      default = true;

      description = ''
        Makes nix integrate nicely with nushell.

        Command `ns`: Search for nixpkgs packages
        Command `ni`: Temporarily install packages from nixpkgs
      '';
    };

    commandNotFound.enable = mkOption {
      type = types.bool;
      default = true;

      description = "Whether to print which packages provide a not installed command";
    };
  };

  config = mkIf cfg.enable {
    programs.nushell = {
      enable = true;

      extraEnv = mkIf cfg.fixHomeSessionVariables ''
        ${lib.getExe pkgs.bash-env-json} ${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh
                    | from json
                    | get env
                    | load-env
      '';

      extraConfig = mkMerge [
        ''
          $env.config.show_banner = false

          $env.config.history.file_format = "sqlite"
          $env.config.history.isolation = true

          $env.SHELL = "${lib.getExe config.programs.nushell.package}"

          alias docker = podman
          alias tmp = cd (mktemp -d -t tmp-XXXXXXXXXX)
        ''

        (mkIf cfg.commandNotFound.enable ''
          $env.config.hooks.command_not_found = { |command_name|
            print (
              command-not-found $command_name | complete | get stderr
                | str trim | str replace -a "nix-shell -p" "ni"
            )
          }
        '')

        (mkIf cfg.nixIntegration.enable ''
          def ni [pkg: string, --allow-unfree (-a), --unstable (-u)] {
              with-env {
                NIXPKGS_ALLOW_UNFREE: ($allow_unfree | into int)
              } {
                nix shell --impure (
                  (if $unstable {"github:NixOS/nixpkgs#"} else "nixpkgs#")
                  + $pkg
                )
              }
          }

          def ns [pkg_regex: string, --unstable (-u)] {
            nix search (
              if $unstable {"github:NixOS/nixpkgs#"} else "nixpkgs#"
            ) --json $pkg_regex | from json
              | transpose package data | par-each {|p|
                $p | update package {$in | str replace -r "legacyPackages\\..*?\\." ""}
              }
          }
        '')

        ''
          sleep 30ms # make sure alacritty resizes before running the prompt
                     # nushell is too damn fasttttt
        ''
      ];
    };
  };
}
