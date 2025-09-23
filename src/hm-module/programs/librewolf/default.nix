{
  config,
  pkgs,
  lib,
  ...
}@inputs:
with lib;
let
  cfg = config.dotfiles.programs.librewolf;
  inherit (import ./bookmark.nix inputs) bookmarkType;
in
{
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
        default = "ddg";

        # IDs can be fetched with
        # `mozlz4a -d ~/.librewolf/default/search.json.mozlz4 | from json`
        description = "Default search engine to use. Referenced by search engine id.";
      };

      disableSearchEngines = mkOption {
        type = with types; listOf str;
        default =
          [
            # "google"
            "wikipedia"
          ]
          ++ map (s: "policy-${s}") [
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
      default = { };

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
      default = [ ];

      description = "List of extensions to install";
    };
  };

  config = mkIf cfg.enable {
    programs.librewolf = {
      enable = true;
      inherit (cfg) package;

      profiles.default = {
        settings = {
          "privacy.resistFingerprinting" = false; # enable darkmode at the cost of your privacy
          "extensions.autoDisableScopes" = 0; # allow auto-installing extensions
          "webgl.disabled" = false; # canva API is protected by an extension

          # stay logged-in
          "privacy.clearOnShutdown_v2.cache" = false;
          "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
        };

        extensions = {
          force = true;
          packages = [ pkgs.firefox-extensions.canvasblocker ] ++ cfg.extensions;
        };

        # TODO: icons are currently bugged upstream => no icons
        search = {
          force = true;
          inherit (cfg.search) default;

          engines =
            let
              mkSearchEngine =
                alias:
                {
                  url,
                  params ? { },
                  ...
                }@searchEngineInputs:
                {
                  urls = [
                    (
                      filterAttrs (name: _: name != "url") searchEngineInputs
                      // {
                        template = url;
                        params = mapAttrsToList (name: value: {
                          inherit name value;
                        }) params;
                      }
                    )
                  ];

                  definedAliases = [ "@${alias}" ];
                };
            in
            (
              if cfg.search.includeCustom then
                {
                  "Github Repos" = mkSearchEngine "gh" {
                    url = "https://github.com/search";
                    params = {
                      "q" = "{searchTerms}";
                      "type" = "repositories";
                    };

                    icon = pkgs.fetchurl {
                      # TODO search engine icons broken upstream
                      url = "https://github.com/favicon.ico";
                      hash = "sha256-LuQyN9GWEAIQ8Xhue3O1fNFA9gE8Byxw29/9npvGlfg=";
                    };
                  };

                  "Noogle" = mkSearchEngine "ng" {
                    url = "https://noogle.dev/q";
                    params.term = "{searchTerms}";

                    icon = pkgs.fetchurl {
                      url = "https://noogle.dev/favicon.png";
                      hash = "sha256-5VjB+MeP1c25DQivVzZe77NRjKPkrJdYAd07Zm0nNVM=";
                    };
                  };
                }
              else
                { }
            )
            // listToAttrs (
              map (engine: {
                name = engine;
                value = {
                  metaData.hidden = true;
                };
              }) cfg.search.disableSearchEngines
            );
        };

        bookmarks =
          let
            mapBookmarks =
              bookmarks:
              lib.attrValues (
                lib.mapAttrs (
                  name: value:
                  {
                    inherit name;
                  }
                  // value
                  // (
                    if value ? bookmarks then
                      {
                        bookmarks = mapBookmarks value.bookmarks;
                      }
                    else
                      { }
                  )
                ) bookmarks
              );
          in
          {
            force = true;
            settings = mapBookmarks (lib.recursiveUpdate { Toolbar.toolbar = true; } cfg.bookmarks);
          };
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
