{
  home-manager,
  pkgs,
  flakeInputs,
  currentVersion,
  stateVersion,
  nixFormatter,
  ...
}:
builtins.mapAttrs (username: userConfig:
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules =
        (import ./module).home-manager
        ++ [
          {
            programs.home-manager.enable = true;
            home = {
              inherit username stateVersion;
              homeDirectory = "/home/${username}";
            };
          }
          userConfig
        ];

      extraSpecialArgs = {
        inherit flakeInputs currentVersion nixFormatter;
        dLib = import ./lib flakeInputs.nixpkgs.lib;
      };
    }) (import ./user)
