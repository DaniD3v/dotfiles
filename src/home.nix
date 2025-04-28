{
  home-manager,
  pkgs,
  flakeInputs,
  currentVersion,
  stateVersion,
  nixFormatter,
  ...
} @ inputs:
builtins.mapAttrs (username: config:
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

            dotfiles = config;
          }
        ];

      extraSpecialArgs = {
        inherit flakeInputs currentVersion nixFormatter;
        dLib = import ./lib flakeInputs.nixpkgs.lib;
      };
    }) (import ./user inputs)
