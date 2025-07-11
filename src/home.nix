{
  pkgs,
  flakeInputs,
  currentVersion,
  stateVersion,
  nixFormatter,
  self,
  ...
}:
rec {
  buildUser =
    username: userConfig:
    flakeInputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules =
        (import ./hm-module)
        ++ (import ./shared-module)
        ++ [
          userConfig

          {
            programs.home-manager.enable = true;
            home = {
              inherit username stateVersion;
              homeDirectory = "/home/${username}";
            };
          }
        ];

      extraSpecialArgs = {
        inherit
          flakeInputs
          currentVersion
          nixFormatter
          self
          ;
        dLib = import ./lib flakeInputs.nixpkgs.lib;
      };
    };

  users = builtins.mapAttrs buildUser (import ./user);
}
