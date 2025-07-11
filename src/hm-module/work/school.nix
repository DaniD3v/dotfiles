{
  config,
  pkgs,
  lib,
  dLib,
  ...
}:
with lib;
let
  cfg = config.dotfiles.work.school;
in
{
  options.dotfiles.work.school =
    let
      mkLectureEnableOption = name: mkEnableOption "Tools required for the ${name} lecture";
    in
    {
      enable = mkEnableOption "Tools required for school";

      nscs.enable = mkLectureEnableOption "NSCS";
      pos.enable = mkLectureEnableOption "POS";
      wmc.enable = mkLectureEnableOption "WMC";
      dbi.enable = mkLectureEnableOption "DBI";

      browserBookmarks = dLib.mkBookmarkOption "School" {
        "Untis".url = "https://neilo.webuntis.com/timetable-students-my";

        "School".bookmarks = {
          "Moodle".bookmarks =
            let
              moodleUrl = courseId: "https://moodle.spengergasse.at/course/view.php?id=${courseId}";
            in
            optionalAttrs cfg.dbi.enable {
              "DBI Michel".url = moodleUrl "9993";
              "DBI Sommer".url = moodleUrl "9919";
            }
            // optionalAttrs cfg.nscs.enable {
              "NSCS".url = moodleUrl "9621";
            }
            // optionalAttrs cfg.pos.enable {
              "POS".url = moodleUrl "9618";
            }
            // optionalAttrs cfg.wmc.enable {
              "WMC".url = moodleUrl "9813";
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
      programs.librewolf.profiles.nscs = {
        # TODO handle automatic id generation properly
        id = 1;

        settings = {
          "xpinstall.signatures.required" = false;

          "ui.highlight" = "white";
          "ui.highlighttext" = "#404040";
        };

        extensions = {
          force = true;
          packages = [
            pkgs.firefox-extensions.re-enable-right-click
            (pkgs.ccnace.override {
              overrideManifest = {
                name = "Dark Reader";
                version = "4.9.106";

                description = "Dark mode for every website. Take care of your eyes, use dark theme for night and daily browsing";
              };
            })
          ];
        };
      };

      home.packages = with pkgs; [
        packetTracer
        screen
      ];
    })

    (mkIf cfg.pos.enable {
      dotfiles.language.csharp.enable = true;
    })

    (mkIf cfg.wmc.enable {
      dotfiles.lsp.angular.enable = true;

      services.podman = {
        enable = true;
        enableTypeChecks = true;

        # TODO add assert that the system config enables podman
        containers.bookshop-mysql = {
          autoStart = false;
          volumes = [ "${./bookshop-mysql.sql}:/docker-entrypoint-initdb.d/bookshop-mysql.sql" ];

          image = "docker.io/mysql:latest";
          ports = [ "3306:3306" ];
        };
      };

      home.packages = with pkgs; [
        nodePackages."@angular/cli"
        podman
      ];
    })
  ]);
}
