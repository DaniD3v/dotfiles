{
  config,
  pkgs,
  lib,
  nixFormatter,
  ...
}:
with lib;
let
  cfg = config.dotfiles.lsp;
  mkLspEnableOption = name: mkEnableOption "${name} LSP & Editor Integration";
in
{
  options.dotfiles.lsp = {
    javascript.enable = mkLspEnableOption "Javascript";
    tailwind.enable = mkLspEnableOption "Tailwind CSS";
    angular.enable = mkLspEnableOption "Angular";
    python.enable = mkLspEnableOption "Python";
    csharp.enable = mkLspEnableOption "Csharp";
    java.enable = mkLspEnableOption "Java";
    dot.enable = mkLspEnableOption "Graphviz dot";
    nix.enable = mkLspEnableOption "Nix";
    cpp.enable = mkLspEnableOption "C++";
  };

  config = lib.mkMerge [
    (mkIf cfg.javascript.enable {
      programs.helix.extraPackages = with pkgs; [
        typescript-language-server
        vscode-langservers-extracted
      ];
    })

    (mkIf cfg.tailwind.enable {
      programs.helix.extraPackages = with pkgs; [
        tailwindcss-language-server
      ];

      programs.helix.languages.language-server.tailwindcss = {
        command = lib.getExe pkgs.tailwindcss-language-server;
        args = [ "--stdio" ];
      };

      dotfiles.editors.helix.language = {
        html.language-servers = [ "tailwindcss" ];
        css.language-servers = [ "tailwindcss" ];
      };
    })

    (mkIf cfg.angular.enable {
      programs.helix.extraPackages = with pkgs; [
        angular-language-server
      ];

      programs.helix.languages.language-server.angular.roots = [ "angular.json" ];

      dotfiles.editors.helix.language = {
        html.language-servers = [ "angular" ];
        typescript.language-servers = [ "angular" ]; # for inline templates
      };
    })

    (mkIf cfg.python.enable {
      programs.helix.extraPackages = with pkgs; [
        basedpyright
        ruff
      ];

      dotfiles.editors.helix.language.python.language-servers = [
        "basedpyright"
        "ruff"
      ];
    })

    (mkIf cfg.csharp.enable {
      programs.helix.extraPackages = with pkgs; [
        omnisharp-roslyn
        dotnet-sdk

        csharpier
      ];
    })

    (mkIf cfg.java.enable {
      programs.helix.extraPackages = [
        (pkgs.jdt-language-server.override {
          inherit (config.dotfiles.language.java) jdk;
        })
      ];

      programs.helix.languages.language-server.jdtls.args = [ "--jvm-arg=-javaagent:${pkgs.lombok}" ];
    })

    (mkIf cfg.dot.enable {
      programs.helix.extraPackages = with pkgs; [
        dot-language-server
      ];
    })

    (mkIf cfg.nix.enable {
      programs.helix.extraPackages = with pkgs; [
        nixd
      ];

      dotfiles.editors.helix.language.nix = {
        language-servers = [ "nixd" ];
        formatter.command = lib.getExe (
          if (nixFormatter == pkgs.nixfmt-tree) then pkgs.nixfmt else nixFormatter
        );
      };
    })

    (mkIf cfg.cpp.enable {
      programs.helix.extraPackages = with pkgs; [
        clang-tools
      ];
    })

    # Re-add default LSPS.
    {
      dotfiles.editors.helix.language = {
        typescript.language-servers = [ "typescript-language-server" ];
        html.language-servers = [ "vscode-html-language-server" ];
        css.language-servers = [ "vscode-css-language-server" ];
      };
    }
  ];
}
