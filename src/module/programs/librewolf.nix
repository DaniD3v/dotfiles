{
  currentVersion,
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.dotfiles.programs.librewolf;
in {
  options.dotfiles.programs.librewolf = {
    enable = mkEnableOption "Librewolf Browser";

    package = mkOption {
      type = types.package;
      default = pkgs.librewolf;
    };

    search = {
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
    };
  };

  config = mkIf cfg.enable {
    programs.librewolf = {
      enable = true;
      package = cfg.package.override {
        extraPolicies = {
          NoDefaultBookmarks = false;
        };
      };

      profiles.default = {
        # icons are currently bugged upstream => no icons
        search = {
          force = true;
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
                      inherit name;
                      inherit value;
                    })
                    params;
                }
              ];

              definedAliases = ["@${alias}"];
            };
          in
            {
              "Packages" = mkSearchEngine "p" {
                url = "https://search.nixos.org/packages";
                params = {
                  "query" = "{searchTerms}";
                  "channel" = currentVersion;
                };
              };

              "Homemanager Options" = mkSearchEngine "ho" {
                url = "https://home-manager-options.extranix.com";
                params = {
                  "query" = "{searchTerms}";
                  "release" = "release-${currentVersion}";
                };
              };

              "NixOS Options" = mkSearchEngine "no" {
                url = "https://search.nixos.org/options";
                params = {
                  "query" = "{searchTerms}";
                  "channel" = currentVersion;
                };
              };

              "Github Repos" = mkSearchEngine "gh" {
                url = "https://github.com/search";
                params = {
                  "q" = "{searchTerms}";
                  "type" = "repositories";
                };
              };
            }
            // listToAttrs (
              map (engine: {
                name = engine;
                value = {metaData.hidden = true;};
              })
              cfg.search.disableSearchEngines
            );
        };

        bookmarks = [
          {
            name = "NixOS";
            toolbar = true;

            bookmarks = [
              {
                name = "Homemanager Options";
                url = "https://home-manager-options.extranix.com/";
              }
            ];
          }
        ];

        settings = {
          # enable darkmode at the cost of your privacy
          "privacy.resistFingerprinting" = false;

          # canva API is protected by an extension
          "webgl.disabled" = false;
        };
      };
    };

    dotfiles.hyprland.bindApp = [
      {
        bind = "$mainMod, Q";
        run = lib.getExe cfg.package;
      }
    ];
  };
}
