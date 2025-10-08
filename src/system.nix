{
  pkgs,
  flakeInputs,
  specialArgs,
  stateVersion,
  ...
}:
rec {
  buildHost = (
    hostname: hostConfig:
    flakeInputs.nixpkgs.lib.nixosSystem {
      system = pkgs.system;

      modules =
        (import ./nixos-module)
        ++ (import ./shared-module)
        ++ [
          hostConfig
          flakeInputs.disko.nixosModules.default
          flakeInputs.arion.nixosModules.arion

          {
            system = { inherit stateVersion; };
            networking.hostName = hostname;
          }
        ];

      specialArgs = specialArgs // {
        configType = "system";
      };
    }
  );

  hosts = builtins.mapAttrs buildHost (import ./host);
}
