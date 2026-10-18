{
  config,
  lib,
  ...
}:
let
  cfg = config.dotfiles.desktop.theme;
in
with lib;
{
  options.dotfiles.desktop.theme = {
    mode = mkOption {
      type = types.enum [
        "light"
        "dark"
      ];
      default = "dark";

      description = "Whether the colorscheme should be light or dark";
    };
  };

  config = mkIf config.dotfiles.desktop.enable {
    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-${cfg.mode}";
        };
      };
    };
  };
}
