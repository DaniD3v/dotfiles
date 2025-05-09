{
  config,
  pkgs,
  lib,
  dLib,
  ...
}:
with lib; let
  cfg = config.dotfiles.work.school;
in {
  options.dotfiles.work.school = {
    enable = mkEnableOption "Tools required for school";

    nscs.enable = mkEnableOption "Tools required for the NSCS lecture";
    wmc.enable = mkEnableOption "Tools required for the WMC lecture";

    browserBookmarks = dLib.mkBookmarkOption "School" {
      "Untis".url = "https://neilo.webuntis.com/timetable-students-my";

      "School".bookmarks = {
        "Moodle".bookmarks = let
          moodleUrl = courseId: "https://moodle.spengergasse.at/course/view.php?id=${courseId}";
        in {
          "DBI Michel".url = moodleUrl "9993";
          "DBI Sommer".url = moodleUrl "9919";
          "NSCS".url = moodleUrl "9621";
          "WMC".url = moodleUrl "9813";
          "POS".url = moodleUrl "9618";
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      dotfiles.programs.librewolf.bookmarks."Toolbar".bookmarks =
        mkIf cfg.browserBookmarks.enable cfg.browserBookmarks.export;
    }

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
  ]);
}
