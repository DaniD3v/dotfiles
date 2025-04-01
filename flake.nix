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
    home-manager,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      homeConfigurations = {
        "notyou" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = import ./src/module ++ [{dotfiles = ./src/user/notyou.nix;}];
        };
      };

      # import src/home.nix {
      #   inherit home-manager;
      #   inherit pkgs;
      # };

      formatter = pkgs.alejandra;
    });
}
