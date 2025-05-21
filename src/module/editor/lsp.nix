{
  config,
  pkgs,
  lib,
  nixFormatter,
  ...
}:
with lib; let
  cfg = config.dotfiles.lsp;
  mkLspEnableOption = name: mkEnableOption "${name} LSP & Editor Integration";
in {
  options.dotfiles.lsp = {
    javascript.enable = mkLspEnableOption "Javascript";
    angular.enable = mkLspEnableOption "Angular";
    python.enable = mkLspEnableOption "Python";
    csharp.enable = mkLspEnableOption "Csharp";
    rust.enable = mkEnableOption "Rust";
    nix.enable = mkLspEnableOption "Nix";
  };

  config = lib.mkMerge [
    (mkIf cfg.javascript.enable {
      programs.helix.extraPackages = with pkgs; [
        typescript-language-server
        vscode-langservers-extracted
      ];
    })

    (mkIf cfg.angular.enable {
      programs.helix.extraPackages = with pkgs; [
        angular-language-server
      ];

      programs.helix
        .languages.language-server
        .angular.roots = ["angular.json"];

      dotfiles.editors.helix.language = {
        html.language-servers = ["angular"];
        typescript.language-servers = ["angular"]; # for inline templates
      };
    })

    (mkIf cfg.python.enable {
      programs.helix.extraPackages = with pkgs; [
        basedpyright
        ruff
        ruff-lsp
      ];

      dotfiles.editors.helix.language.python.language-servers = ["basedpyright" "ruff"];
    })

    (mkIf cfg.csharp.enable {
      programs.helix.extraPackages = with pkgs; [
        omnisharp-roslyn
        csharpier
      ];
    })

    (mkIf cfg.nix.enable {
      programs.helix.extraPackages = with pkgs; [
        nixd
      ];

      dotfiles.editors.helix.language.nix = {
        language-servers = ["nixd"];
        formatter.command = lib.getExe nixFormatter;
      };
    })

    # Re-add default LSPS.
    {
      dotfiles.editors.helix.language = {
        html.language-servers = ["vscode-html-language-server"];
        typescript.language-servers = ["typescript-language-server"];
      };
    }
  ];
}
