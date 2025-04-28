{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.dotfiles.work.school;
in {
  options.dotfiles.work.school = {
    nscs.enable = mkEnableOption "Tools required for the NSCS lecture";
    wmc.enable = mkEnableOption "Tools required for the WMC lecture";
  };

  config = lib.mkMerge [
    (mkIf cfg.nscs.enable {
      home.packages = with pkgs; [
        packetTracer
      ];
    })
    (mkIf cfg.wmc.enable {
      dotfiles.lsp.angular.enable = true;

      services.podman = {
        enable = true;
        enableTypeChecks = true;

        # TODO add assert that the system config enables podman
        containers.bookshop-mysql = {
          autoStart = false;
          volumes = ["${./bookshop-mysql.sql}:/docker-entrypoint-initdb.d/bookshop-mysql.sql"];

          image = "docker.io/mysql:latest";
          ports = ["3306:3306"];
        };
      };

      home.packages = with pkgs; [
        nodePackages."@angular/cli"
        podman
      ];
    })
  ];
}
