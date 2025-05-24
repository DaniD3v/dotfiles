{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.dotfiles.desktop.ashell;
in {
  options.dotfiles.desktop.ashell = {
    enable = mkEnableOption "Ashell desktop shell";
  };

  config = {
  };
}
