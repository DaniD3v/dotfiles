{
  flakeInputs,
  config,
  lib,

  # attrs to pass to `home.nix`
  configAttrs,
  ...
}:
with lib;
let
  cfgUsers = config.dotfiles.users;
in
{
  options.dotfiles.users = mkOption {
    type = types.attrsOf (
      types.submodule (
        { name, ... }:
        {
          options = {
            name = mkOption {
              type = types.str;
              default = name;

              example = "notyou";
            };

            home = mkOption {
              type = types.str;
              default = "/home/${name}";

              example = "/home/notyou";
            };

            isNormalUser = mkEnableOption "Whether the user has a uid in range >-1000";
            isSystemUser = mkEnableOption "Whether the user is a system user and has a uid <1000";

            extraGroups = mkOption {
              type = types.listOf types.str;
              default = [ ];

              example = [
                "wheel"
                "dialout"
              ];
            };
          };
        }
      )
    );
    default = { };

    example = {
      "notyou".groups = [
        "wheel"
      ];
    };
  };

  imports = [
    flakeInputs.home-manager.nixosModules.home-manager
  ];

  config = {
    home-manager = {
      useGlobalPkgs = true;
      extraSpecialArgs = configAttrs.specialArgs // {
        configType = "home-system";
      };

      users =
        let
          # wraps the args `home-manager.lib.homeManagerConfiguration` expects into
          # a normal home-manager module.
          homeBuildWrapper =
            {
              modules,
              ...
            }:
            {
              imports = modules;
            };

          hmUsers =
            (import ../home.nix (
              configAttrs
              // {
                builder = homeBuildWrapper;
              }
            )).users;
        in
        lib.mapAttrs (k: v: hmUsers.${k}) cfgUsers;
    };
    users.users = cfgUsers;
  };
}
