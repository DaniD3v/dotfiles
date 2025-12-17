{
  config,
  pkgs,
  lib,
  dLib,
  ...
}:
with lib;
let
  cfg = config.dotfiles.editors.helix;

  tomlFormat = pkgs.formats.toml { };
  inherit (dLib) mkBookmarkOption;
in
{
  options.dotfiles.editors.helix = {
    enable = mkEnableOption "Helix Editor";

    settings = {
      alternativeXSelection = mkOption {
        type = types.bool;
        default = true;

        description = "Force the first x selection to stay on the same line.";
      };

      workingDirFilePickerByDefault = mkOption {
        type = types.bool;
        default = true;

        description = "Use `f` to open the fuzzy file picker in the cwd instead of the project root.";
      };

      autoFormat = mkOption {
        type = types.bool;
        default = true;

        description = "Whether to enable formatting on save for all languages by default";
      };
    };

    language = mkOption {
      inherit (tomlFormat) type;
      default = { };

      example = {
        "nix".auto-pairs = {
          "{" = "}";
        };
      };
      description = "Pass-through of the helix language config";
    };

    browserBookmarks = mkBookmarkOption "Helix" {
      "Helix".bookmarks = {
        "Config - Editor".url = "https://docs.helix-editor.com/editor.html";
        "Config - Lsp".url = "https://github.com/helix-editor/helix/wiki/Language-Server-Configurations";
        "Shortcut Quiz".url = "https://tomgroenwoldt.github.io/helix-shortcut-quiz/";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.helix = {
      enable = true;
      package = pkgs.helix;

      settings = {
        theme = "gruvbox";

        editor = {
          lsp.display-inlay-hints = true;
          inline-diagnostics = {
            cursor-line = "hint";
            other-lines = "error";
          };

          indent-guides.render = true;
          cursor-shape.insert = "bar";
        };

        keys =
          let
            workingDirFilePickerRebinds = {
              f = "file_picker_in_current_directory";
              F = "file_picker";
            };
          in
          mkMerge [
            (mkIf cfg.settings.alternativeXSelection {
              # Make `x` not skip an empty newline
              normal.x = [
                "extend_to_line_bounds"
                "select_mode"
              ];
              select.x = [ "extend_line" ];

              # Automatically go into normal mode in order
              # to make x behavior consistent with original
              select.";" = [
                "collapse_selection"
                "normal_mode"
              ];
            })
            (mkIf cfg.settings.workingDirFilePickerByDefault {
              normal.space = workingDirFilePickerRebinds;
              select.space = workingDirFilePickerRebinds;
            })
          ];
      };

      languages.language =
        let
          default-auto-pairs = {
            "(" = ")";
            "[" = "]";
            "{" = "}";

            "\"" = "\"";
          };
        in
        lib.attrValues (
          lib.mapAttrs
            (
              name: value:
              {
                inherit name;
                auto-format = cfg.settings.autoFormat;
              }
              // value
            )
            (
              {
                rust.auto-pairs = default-auto-pairs // {
                  "|" = "|";
                };

                html.auto-pairs = default-auto-pairs // {
                  "<" = ">";
                };
              }
              // cfg.language
            )
        );
    };

    dotfiles.programs.librewolf.bookmarks."Toolbar".bookmarks."Ricing".bookmarks =
      mkIf cfg.browserBookmarks.enable cfg.browserBookmarks.export;
  };
}
