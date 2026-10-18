{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.dotfiles.desktop.sound.enable {
    services.pipewire = {
      enable = true;

      pulse.enable = true;
      alsa.enable = true;
    };

    security.rtkit.enable = true;
  };
}
