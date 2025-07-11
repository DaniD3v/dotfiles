{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.dotfiles.unfree;
in
{
  options.dotfiles.unfree = {
    whiteList = mkOption {
      type = with types; listOf str;
      default = [ ];

      description = "Whitelist of unfree package names";
    };

    allowAll = mkOption {
      type = types.bool;
      default = false;

      description = "Allow all unfree packages instead of having to list them explicitely";
    };
  };

  config.nixpkgs.config = {
    allowUnfree = cfg.allowAll;
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) cfg.whiteList;
  };
}
