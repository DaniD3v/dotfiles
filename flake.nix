{
  description = "DaniD3v's corn-flakes V2";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      currentVersion = "24.11";
      stateVersion = "23.11";

      pkgs = import nixpkgs {
        inherit system;

        overlays = [
          (
            # expose flake packages directly
            final: prev:
              builtins.mapAttrs (
                name: value:
                  if value ? packages
                  then
                    (
                      let
                        packages = value.packages.${system};
                      in
                        # if there's only a default package expose it directly
                        if builtins.all (name: name == "default") (builtins.attrNames packages)
                        then packages.default
                        else packages
                    )
                  else prev.${name} or throw "package '${name}' not found"
              )
              inputs
          )
          (final: prev: import src/pkgs prev)
          (final: prev: {
            unstable = import nixpkgs-unstable {inherit system;};
          })
        ];
      };
    in {
      packages.homeConfigurations = import src/home.nix {
        inherit home-manager currentVersion stateVersion pkgs;
      };

      formatter = pkgs.alejandra;
    });
}
