{lib, ...}:
with lib; let
  bookmarkFileSubmodule = types.submodule ({name, ...}: {
    options = {
      name = mkOption {
        type = types.str;
        default = name;

        description = "The displayed name of your bookmark";
      };

      tags = mkOption {
        type = with types; listOf str;
        default = [];

        example = ["nix" "packages"];
        description = "Bookmark tags to better organize your bookmarks";
      };

      keyword = mkOption {
        type = with types; nullOr str;
        default = null;

        example = "@pkgs";
        description = "Keyword to type into your address bar to jump to the bookmark immediately";
      };

      url = mkOption {
        type = types.str;

        example = "https://search.nixos.org/packages?query=%s";
        description = ''
          Bookmark url. Use %s to substitute search terms

          If the bookmark is accessed via a keyword over the address bar additional text can be entered.
          This text can be used to make a bookmark act like a search engine.

          See https://support.mozilla.org/en-US/kb/how-search-from-address-bar for more information.
        '';
      };
    };
  });

  bookmarkFile = types.addCheck bookmarkFileSubmodule (x: x ? "url");

  bookmarkDirectory = types.submodule ({name, ...}: {
    options = {
      name = mkOption {
        type = types.str;
        default = name;

        description = "The displayed name of your bookmark directory";
      };

      bookmarks = mkOption {
        type = types.attrsOf bookmarkType;
        default = {};
      };
    };
  });

  bookmarkType = types.either bookmarkFile bookmarkDirectory;
in {
  inherit bookmarkType;

  mkBookmarkOption = name: bookmarks: {
    enable = mkOption {
      type = types.bool;
      default = true;

      example = false;
      description = "Whether to enable browser bookmarks related to ${name}";
    };

    export = mkOption {
      type = types.attrsOf bookmarkType;
      readOnly = true;

      default = bookmarks;

      description = "Read-only option that exports all defined bookmarks of this module.";
      example = {
        "Helix".bookmarks = {
          "Editor - Config".url = "https://docs.helix-editor.com/editor.html";
          "LSP - Config".url = "https://github.com/helix-editor/helix/wiki/Language-Server-Configurations";
        };
      };
    };
  };
}
