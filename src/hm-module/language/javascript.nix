{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.dotfiles.language.javascript;
in
{
  options.dotfiles.language.javascript = {
    enable = mkEnableOption "js developement tools";
  };

  config = mkIf cfg.enable {
    dotfiles.lsp.javascript.enable = true;
    dotfiles.lsp.tailwind.enable = true;

    home.packages = with pkgs; [
      nodejs-slim
      bun
    ];
  };
}
