{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.dotfiles.shells.nushell;
in {
  imports = [];

  options.dotfiles.shells.nushell = {
    enable = mkEnableOption "Nushell";

    nixIntegration.enable = mkOption {
      default = true;
      description = ''
        Makes nix integrate nicely with nushell.

        Command `ns`: Search for nixpkgs packages
        Command `ni`: Temporarily install packages from nixpkgs
      '';
    };

    commandNotFound.enable = mkOption {
      default = true;
      description = "Whether to print which packages provide a not installed command.";
    };
  };

  config = mkIf cfg.enable {
    programs.nushell = {
      enable = true;

      extraConfig = mkMerge [
        ''
          $env.config.show_banner = false

          $env.config.history.file_format = "sqlite"
          $env.config.history.isolation = true

          $env.SHELL = "${lib.getExe config.programs.nushell.package}"

          def "input opt-list" [list: list, msg?: string = ""] {
            if (($list | length) == 1) {$list | get 0}
              else ($list | input list $msg)
          }

          def --env tmp [] {
            cd (mktemp -d -t tmp-XXXXXXXXXX)
          }
        ''

        (mkIf cfg.commandNotFound.enable ''
          $env.config.hooks.command_not_found = {
            |command_name|
            print (command-not-found $command_name | str trim)
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

          def "ns pkg-config" [lib_filename, --include-deps (-i)] {
            ${lib.getExe' pkgs.nix-index "nix-locate"} -w "/lib/pkgconfig/$lib_filename"
              | lines | each {$in | split row " " | first}
              | filter {$include_deps or not ($in | str starts-with "(")}
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
