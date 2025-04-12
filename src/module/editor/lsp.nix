{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.dotfiles.lsp;
  mkLspEnableOption = name: mkEnableOption "${name} LSP & Editor Integration";
in {
  options.dotfiles.lsp = {
    javascript.enable = mkLspEnableOption "Javascript";
    nix.enable = mkLspEnableOption "Nix";
    angular.enable = mkLspEnableOption "Angular";
  };

  config = lib.mkMerge [
    (
      mkIf cfg.javascript.enable {
        programs.helix.extraPackages = [
          pkgs.typescript-language-server
        ];
      }
    )
    (mkIf cfg.nix.enable {
      programs.helix
        .languages.language-server
        .nixd.command = "${pkgs.nixd}/bin/nixd";

      dotfiles.helix.language.nix = {
        language-servers = ["nixd"];
        # TODO
        # formatter.command = "${pkgs.nix}/bin/nix fmt";
      };
    })
    (mkIf cfg.angular.enable {
      programs.helix
        .languages.language-server
        .angular-lsp = {
        command = "${pkgs.angular-language-server}/bin/ngserver";
        args = ["--stdio"];

        roots = ["angular.json"];
      };

      dotfiles.helix.language = {
        html.language-servers = ["angular-lsp"];
        typescript.language-servers = ["angular-lsp"]; # for inline templates
      };
    })
    {
      # Re-add default LSPS.
      dotfiles.helix.language = {
        html.language-servers = ["vscode-html-language-server"];
        typescript.language-servers = ["typescript-language-server"];
      };
    }
  ];
}
