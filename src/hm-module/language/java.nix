{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.dotfiles.language.java;
in
{
  options.dotfiles.language.java = {
    enable = mkEnableOption "java developement tools";
    jdk = mkPackageOption pkgs "jdk" { };
  };

  config = mkIf cfg.enable {
    home.packages = [
      cfg.jdk
      (pkgs.maven.override {
        jdk_headless = cfg.jdk;
      })
    ];

    dotfiles.lsp.java.enable = true;
  };
}
