{
  pkgs,
  flakeInputs,
  specialArgs,
  stateVersion,
  builder ? flakeInputs.home-manager.lib.homeManagerConfiguration,
  ...
}:
rec {
  buildUser =
    username: userConfig:
    builder {
      inherit pkgs;

      modules =
        (import ./hm-module)
        ++ (import ./shared-module)
        ++ [
          userConfig
          flakeInputs.noctalia.homeModules.default

          {
            programs.home-manager.enable = true;
            home = {
              inherit username stateVersion;
              homeDirectory = "/home/${username}";
            };
          }
        ];

      extraSpecialArgs = specialArgs // {
        configType = "home";
      };
    };

  users = builtins.mapAttrs buildUser (import ./user);
}
