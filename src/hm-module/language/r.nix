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
    home.packages =
      let
        packages = with pkgs.rPackages; [
          languageserver
          tidyverse
          rmarkdown
        ];
      in
      [
        (cfg.rRuntime.override {
          inherit packages;
        })
        (pkgs.rstudioWrapper.override {
          R = cfg.rRuntime;
          inherit packages;
        })
      ];
  };
}
