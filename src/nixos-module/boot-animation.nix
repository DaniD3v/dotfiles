{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.dotfiles.boot;
in
{
  options.dotfiles.boot = {
    skipGenerationChooser = mkOption {
      type = types.bool;
      default = false;

      description = ''
        Whether to immeditely select the latest generation on boot.
        Another generation can still be picked when holding the space key on boot.
      ''; # TODO verify it actually is space
    };

    animation.enable = mkEnableOption "Plymouth boot animation";
  };

  config = {
    boot.loader = {
      systemd-boot.enable = true;
      timeout = if cfg.skipGenerationChooser then 0 else 5;
    };

    boot.plymouth.enable = cfg.animation.enable;
  };
}
