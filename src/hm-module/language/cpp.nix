{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.dotfiles.language.cpp;
in
{
  options.dotfiles.language.cpp = {
    enable = mkEnableOption "C++ developement tools";
  };

  config = mkIf cfg.enable {
    dotfiles.lsp.cpp.enable = true;

    home.packages = [
      pkgs.clang
    ];
  };
}
