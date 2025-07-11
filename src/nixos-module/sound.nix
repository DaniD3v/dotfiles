{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.dotfiles.sound;
in
{
  options.dotfiles.sound = {
    enable = mkOption {
      type = types.bool;

      default = config.dotfiles.desktop.enable;
      description = "Whether to enable sound-support";
    };
  };

  config = mkIf cfg.enable {
    services.pipewire = {
      enable = true;

      pulse.enable = true;
      alsa.enable = true;
    };

    security.rtkit.enable = true;
  };
}
