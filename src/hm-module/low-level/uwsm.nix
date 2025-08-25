{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.programs.uwsm;
in
{
  options.programs.uwsm = {
    envVariables = mkOption {
      type = with types; attrsOf str;
      default = { };

      description = "Environment variables set by uwsm.";
    };
  };

  config = {
    xdg.configFile."uwsm/env".text = concatLines (
      lib.mapAttrsToList (key: val: "export ${key}=${val}") cfg.envVariables
    );
  };
}
