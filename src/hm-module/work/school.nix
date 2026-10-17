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
      dsai.enable = mkLectureEnableOption "DSAI";
      pos.enable = mkLectureEnableOption "POS";

      browserBookmarks = dLib.mkBookmarkOption "School" {
        "Untis".url = "https://neilo.webuntis.com/timetable-students-my";
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

      nixpkgs.config.allowUnfreePackages = [ "ciscoPacketTracer8" ];

      home.packages = with pkgs; [
        patchedCiscoPacketTracer8
        screen
      ];
    })

    (mkIf cfg.dsai.enable {
      dotfiles.language.R.enable = true;
    })

    (mkIf cfg.pos.enable {
      dotfiles.language.java.enable = true;
    })
  ]);
}
