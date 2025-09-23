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

          {
            system = { inherit stateVersion; };
          }
        ];

      specialArgs = specialArgs // {
        configType = "system";
      };
    }
  );

  hosts = builtins.mapAttrs buildHost (import ./host);
}
