{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.dotfiles.language.R;
in
{
  options.dotfiles.language.R = {
    enable = mkEnableOption "java developement tools";
    rRuntime = mkPackageOption pkgs "rWrapper" { };
  };

  config = mkIf cfg.enable {
    home.packages = [
      (cfg.rRuntime.override {
        packages = [ pkgs.rPackages.languageserver ];
      })
    ];
  };
}
