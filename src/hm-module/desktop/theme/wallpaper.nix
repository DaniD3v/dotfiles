{
  lib,
  ...
}:
with lib;
{
  options.dotfiles.desktop.wallpaper = {
    wallpapers = mkOption {
      type = with types; listOf path;
      default = [ ];

      description = "list of paths to wallpapers";
    };
  };

  config = {
    # TODO
  };
}
