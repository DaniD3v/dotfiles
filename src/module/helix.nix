{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.dotfiles.helix;
in {
  imports = [];

  options.dotfiles.helix = {
    enable = mkEnableOption "Helix Editor";
  };

  config = mkIf cfg.enable {
    programs.helix = {
      enable = true;

      settings = {
        editor = {
          lsp.display-inlay-hints = true;
          inline-diagnostics = {
            cursor-line = "hint";
            other-lines = "info";
          };

          indent-guides.render = true;
          cursor-shape.insert = "bar";

          smart-tab.supersede-menu = true;
          auto-save.focus-lost = true;
        };
      };

      languages.language = let
        default_auto_pairs = {
          "(" = ")";
          "[" = "]";
          "{" = "}";

          "\"" = "\"";
          "'" = "'";
        };
      in [
        {
          name = "rust";
          auto-pairs =
            default_auto_pairs
            // {
              "|" = "|";
            };
        }
        {
          name = "html";
          auto-pairs =
            default_auto_pairs
            // {
              "<" = ">";
            };
        }
      ];
    };
  };
}
