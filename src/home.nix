{
  pkgs,
  home-manager,
  currentVersion,
  stateVersion,
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
        inherit currentVersion;
      };
    }) (import ./user inputs)
