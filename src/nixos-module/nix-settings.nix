{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.dotfiles.nix;
in {
  options.dotfiles.nix = {
    scheduledMaintenanceTasks = mkOption {
      type = types.bool;

      default = true;
      description = ''
        Whether to automatically run system maintenance tasks.
        This includes nix-store optimizations and automatic garbage collection runs.
      '';
    };

    developSetup = mkOption {
      type = types.bool;

      default = true;
      description = "Whether to set nix settings for developing convenience.";
    };
  };

  config.nix = mkMerge [
    {
      settings = {
        experimental-features = ["nix-command" "flakes"];

        # This is good for development.
        # `false` is a bad default.
        keep-going = cfg.developSetup;
        warn-dirty = !cfg.developSetup;
      };
    }
    (mkIf cfg.scheduledMaintenanceTasks {
      optimise.automatic = true;
      gc.automatic = true;
    })
  ];
}
