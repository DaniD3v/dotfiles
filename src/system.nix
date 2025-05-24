{
  system,
  flakeInputs,
  stateVersion,
  ...
}: rec {
  buildHost = (
    hostname: hostConfig:
      flakeInputs.nixpkgs.lib.nixosSystem {
        inherit system;

        modules =
          (import ./nixos-module)
          ++ [
            hostConfig

            {
              system = {inherit stateVersion;};
            }
          ];
      }
  );

  hosts = builtins.mapAttrs buildHost (import ./host);
}
