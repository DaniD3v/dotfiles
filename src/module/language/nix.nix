{
  config,
  pkgs,
  lib,
  dLib,
  nixFormatter,
  currentVersion,
  ...
}:
with lib; let
  cfg = config.dotfiles.language.nix;
in {
  options.dotfiles.language.nix = {
    enable = mkEnableOption "nix developement tools";

    browserBookmarks = let
      nixOSSearch = type:
        "https://search.nixos.org/${type}"
        + "?query=%s&channel=${currentVersion}";
    in
      dLib.mkBookmarkOption "Nix" {
        "Nix".bookmarks = {
          "NixOS Packages" = {
            url = nixOSSearch "packages";
            keyword = "@np";
          };
          "Homemanager Options" = {
            url =
              "https://home-manager-options.extranix.com"
              + "?query=%s&release=release-${currentVersion}";
            keyword = "@ho";
          };
          "NixOS Options" = {
            url = nixOSSearch "options";
            keyword = "@no";
          };

          "Nixpkgs" = {
            url = "https://github.com/NixOS/nixpkgs";
            keyword = "home-manager";
          };
          "Home manager" = {
            url = "https://github.com/nix-community/home-manager";
            keyword = "nixpkgs";
          };
        };
      };
  };

  config = mkIf cfg.enable {
    dotfiles.lsp.nix.enable = true;

    home.packages =
      (with pkgs; [
        deadnix
        statix
      ])
      ++ [nixFormatter];

    dotfiles.programs.librewolf.bookmarks
    ."Toolbar".bookmarks."Languages".bookmarks =
      mkIf cfg.browserBookmarks.enable cfg.browserBookmarks.export;
  };
}
