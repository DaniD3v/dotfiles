{
  description = "DaniD3v's corn-flakes V2";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-extensions = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    monique = {
      url = "github:ToRvaLDz/monique";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hostcolor = {
      url = "github:DaniD3v/hostcolor";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    disko.inputs.nixpkgs.follows = "nixpkgs";
    fenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      flake-utils,
      ...
    }@flakeInputs:
    let
      overlays = [
        (
          # expose flake packages directly, unwrapping a lone default package
          _: prev:
          builtins.mapAttrs (
            _: input:
            let
              packages = input.packages.${prev.stdenv.hostPlatform.system};
            in
            if builtins.attrNames packages == [ "default" ] then packages.default else packages
          ) (nixpkgs.lib.filterAttrs (_: input: input ? packages) flakeInputs)
        )
        (_: prev: {
          unstable = import nixpkgs-unstable {
            inherit (prev) config;
            inherit (prev.stdenv.hostPlatform) system;
          };
        })
        (_: prev: import src/pkgs prev)
      ];
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        currentVersion = "26.05";
        stateVersion = "23.11";

        pkgs = import nixpkgs { inherit system overlays; };

        # generic attrs to pass to system & host-config
        configAttrs = {
          inherit system flakeInputs stateVersion;

          specialArgs = {
            inherit flakeInputs currentVersion configAttrs;
            flakeOverlays = overlays;

            dLib = import ./src/lib nixpkgs.lib;
            nixFormatter = formatter;
            self = ./.;
          };
        };

        systemConfig = import src/system.nix configAttrs;
        homeConfig = import src/home.nix configAttrs;

        formatter = pkgs.nixfmt-tree;
      in
      {
        packages = builtins.intersectAttrs (import src/pkgs pkgs) pkgs // {
          homeConfigurations = homeConfig.users;
          nixosConfigurations = systemConfig.hosts;
        };

        nixdOptions = {
          home-manager = (homeConfig.buildUser "module-export" { }).options;
          nixos = (systemConfig.buildHost "module-export" { nixpkgs.hostPlatform = system; }).options;
        };

        inherit formatter;
      }
    );
}
