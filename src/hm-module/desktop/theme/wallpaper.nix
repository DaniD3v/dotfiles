{
  config,
  lib,
  ...
} @ inputs:
with lib; let
  cfg = config.dotfiles.desktop.wallpaper;
in {
  options.dotfiles.desktop.wallpaper = {
    wallpapers = mkOption {
      type = with types; listOf path;
      default = [];

      description = "list of paths to wallpapers";
    };
  };

  config = {
    # TODO
  };
}
