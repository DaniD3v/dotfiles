{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.dotfiles.shells.nushell;
in {
  imports = [];

  options.dotfiles.shells.nushell = {
    enable = mkEnableOption "Nushell";
  };

  config = mkIf cfg.enable {
    programs.nushell = {
      enable = true;

      extraConfig = ''
        $env.config.show_banner = false

        $env.config.history.file_format = "sqlite"
        $env.config.history.isolation = true

        def --env ni [pkg: string, --unfree (-u)] {
          $env.PATH = ($env.PATH | append (
            with-env {
              NIXPKGS_ALLOW_UNFREE: ($unfree | into int)
            } {
              nix build ("nixpkgs#" + $pkg) --impure --no-link --print-out-paths
                | split row "\n" | each {|p| [$p bin] | path join}
            }
          ))
        }

        def ns [pkg_regex: string] {
          nix search nixpkgs --json $pkg_regex | from json
            | transpose package data | each {|p|
              $p | update package {$in | str replace -r "legacyPackages\\..*?\\." ""}
            }
        }

        def --env tmp [] {
          cd (mktemp -d -t tmp-XXXXXXXXXX)
        }

        sleep 30ms # make sure alacritty resizes before running the prompt
                   # nushell is too damn fasttttt
      '';
    };
  };
}
