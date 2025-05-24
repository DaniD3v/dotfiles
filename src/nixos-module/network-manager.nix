{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.dotfiles.networkManager;
in {
  options.dotfiles.networkManager = {
    enable = mkOption {
      type = types.bool;
      default = true;

      description = "Whether to use networkmanager";
    };

    # HACK
    fixStartupTime = mkOption {
      type = types.bool;
      default = true;

      description = ''
        Systemd usually waits for networkmanager to go online before starting user services.
        This option prevents that.
      '';
    };
  };

  config = mkIf cfg.enable {
    networking.networkmanager.enable = true;

    # massivly improve boot time
    systemd.services.NetworkManager-wait-online.enable = cfg.fixStartupTime;
  };
}
