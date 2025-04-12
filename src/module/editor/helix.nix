{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.dotfiles.helix;
  tomlFormat = pkgs.formats.toml {};
in {
  options.dotfiles.helix = {
    enable = mkEnableOption "Helix Editor";

    alternativeXSelection = mkOption {
      type = types.bool;
      default = true;

      description = "Force the first x selection to stay on the same line.";
    };

    language = mkOption {
      type = tomlFormat.type;
      default = {};

      example = {
        "nix".auto-pairs = {
          "{" = "}";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    programs.helix = {
      enable = true;
      package = pkgs.unstable.helix;

      settings = {
        theme = "gruvbox";

        editor = {
          lsp.display-inlay-hints = true;
          inline-diagnostics = {
            cursor-line = "hint";
            other-lines = "info";
          };

          indent-guides.render = true;
          cursor-shape.insert = "bar";

          auto-save.focus-lost = true;
        };

        keys = mkIf cfg.alternativeXSelection {
          # Make `x` not skip an empty newline
          normal.x = ["extend_to_line_bounds" "select_mode"];
          select.x = ["extend_line"];

          # Automatically go into normal mode in order
          # to make x behavior consistent with original
          select.";" = ["collapse_selection" "normal_mode"];
        };
      };

      languages.language = let
        default-auto-pairs = {
          "(" = ")";
          "[" = "]";
          "{" = "}";

          "\"" = "\"";
          "'" = "'";
        };
      in
        lib.attrValues (lib.mapAttrs (name: value:
          {
            inherit name;
          }
          // value) ({
            rust.auto-pairs =
              default-auto-pairs
              // {
                "|" = "|";
              };

            html.auto-pairs =
              default-auto-pairs
              // {
                "<" = ">";
              };
          }
          // cfg.language));
    };
  };
}
