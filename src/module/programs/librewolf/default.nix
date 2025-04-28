{
  currentVersion,
  config,
  pkgs,
  lib,
  ...
} @ inputs:
with lib; let
  cfg = config.dotfiles.programs.librewolf;
  inherit (import ./bookmark.nix inputs) bookmarkType;
in {
  options.dotfiles.programs.librewolf = {
    enable = mkEnableOption "Librewolf Browser";

    package = mkOption {
      type = types.package;
      default = pkgs.librewolf;
    };

    finalPackage = mkOption {
      type = types.package;
      default = config.programs.librewolf.finalPackage;

      readOnly = true;
    };

    search = {
      default = mkOption {
        type = types.str;
        default = "DuckDuckGo";
      };

      disableSearchEngines = mkOption {
        type = with types; listOf str;
        default = [
          "Bing"
          "DuckDuckGo Lite"
          "MetaGer"
          "Mojeek"
          "SearXNG - searx.be"
          "StartPage"
        ];
      };

      includeCustom = mkOption {
        type = types.bool;
        default = true;

        description = "include custom search engines such as the Github Repo search";
      };
    };

    bookmarks = mkOption {
      type = types.attrsOf bookmarkType;
      default = {};

      example = {
        "Helix".bookmarks = {
          "Editor - Config".url = "https://docs.helix-editor.com/editor.html";
          "LSP - Config".url = "https://github.com/helix-editor/helix/wiki/Language-Server-Configurations";
          "Shortcut Quiz".url = "https://tomgroenwoldt.github.io/helix-shortcut-quiz/";
        };
      };
    };

    extensions = mkOption {
      type = with types; listOf package;
      default = [];

      description = "List of extensions to install";
    };
  };

  config = mkIf cfg.enable {
    programs.librewolf = {
      enable = true;
      inherit (cfg) package;

      # HACK: make bookmarks work
      policies.NoDefaultBookmarks = false;

      profiles.default = {
        settings = {
          "privacy.resistFingerprinting" = false; # enable darkmode at the cost of your privacy
          "extensions.autoDisableScopes" = 0; # allow auto-installing extensions
          "webgl.disabled" = false; # canva API is protected by an extension

          # stay logged-in
          "privacy.clearOnShutdown_v2.cache" = false;
          "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
        };

        extensions =
          [
            pkgs.firefox-extensions.canvasblocker
          ]
          ++ cfg.extensions;

        # TODO: icons are currently bugged upstream => no icons
        search = {
          force = true;
          inherit (cfg.search) default;

          engines = let
            mkSearchEngine = alias: {
              url,
              params ? {},
            }: {
              urls = [
                {
                  template = url;
                  params =
                    mapAttrsToList (name: value: {
                      inherit name value;
                    })
                    params;
                }
              ];

              definedAliases = ["@${alias}"];
            };
          in
            (
              if cfg.search.includeCustom
              then {
                "Github Repos" = mkSearchEngine "gh" {
                  url = "https://github.com/search";
                  params = {
                    "q" = "{searchTerms}";
                    "type" = "repositories";
                  };
                };
              }
              else {}
            )
            // listToAttrs (
              map (engine: {
                name = engine;
                value = {metaData.hidden = true;};
              })
              cfg.search.disableSearchEngines
            );
        };

        bookmarks = let
          mapBookmarks = bookmarks:
            lib.attrValues
            (lib.mapAttrs (name: value:
              {
                inherit name;
              }
              // value
              // (
                if value ? bookmarks
                then {
                  bookmarks = mapBookmarks value.bookmarks;
                }
                else {}
              ))
            bookmarks);
        in
          mapBookmarks (
            lib.recursiveUpdate {Toolbar.toolbar = true;} cfg.bookmarks
          );
      };
    };

    dotfiles.desktop.hyprland.bindApp = [
      {
        bind = "$mainMod, Q";
        run = lib.getExe cfg.finalPackage;
      }
    ];
  };
}
