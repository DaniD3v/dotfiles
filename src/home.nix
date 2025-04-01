{
  home-manager,
  pkgs,
}:
builtins.mapAttrs (username: config:
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = import ./module ++ [{dotfiles = config;}];
    }) (import ./user)
