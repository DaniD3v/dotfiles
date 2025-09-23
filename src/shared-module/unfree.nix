{
  originalPkgs,
  config,
  dLib,
  lib,

  # whether this is a nixOS/home-manager config
  configType,
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

  config =
    let
      nixpkgsConfig = {
        allowUnfree = cfg.allowAll;
        allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) cfg.whiteList;
      };
    in

    if configType == "home" then
      {
        nixpkgs.config = nixpkgsConfig;
      }
    else if (configType == "system") then
      {
        dotfiles.unfree =
          (dLib.recursiveMergeAttrsConcatLists (lib.attrValues config.home-manager.users)).dotfiles.unfree;

        # nixpkgs has a check that fails if `nixpkgs.pkgs`
        # and `nixpkgs.config` is set.
        nixpkgs.pkgs = originalPkgs.override {
          config = nixpkgsConfig;
        };
      }
    else
      { };
}
