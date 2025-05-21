{
  description = "DaniD3v's corn-flakes V2";

  inputs = {
    nixpkgs.url = "github:DaniD3v/nixpkgs/librewolf-fix-backport";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-extensions = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    bash-env-json = {
      url = "github:tesujimath/bash-env-json";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix.inputs.nixpkgs.follows = "nixpkgs";
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
            _: prev:
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
          (_: prev: import src/pkgs prev)
          (_: _: {
            unstable = import nixpkgs-unstable {inherit system;};
          })
        ];
      };
    in rec {
      packages =
        import src/pkgs pkgs
        // {
          homeConfigurations = import src/home.nix {
            inherit home-manager pkgs currentVersion stateVersion;

            flakeInputs = inputs;
            nixFormatter = formatter;
          };
        };

      formatter = pkgs.alejandra;
    });
}
