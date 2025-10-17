{
  pkgs,
  config,
  lib,

  ...
}:
{
  # override the automatically assigned username 'notyou-minimal'
  home.username = lib.mkForce "notyou";
  home.homeDirectory = lib.mkForce "/home/${config.home.username}";

  xdg.userDirs.enable = true;

  programs.nushell = {
    shellAliases = {
      "c" = "with-env {\"SHLVL\": 0} {job spawn {alacritty --working-directory .}}";
    };
  };

  dotfiles = {
    programs = {
      git = {
        enable = true;

        userName = "DaniD3v";
        userEmail = "sch220233@spengergasse.at";

        sshKey = {
          enable = true;
          useForSigning = true;

          keyFile = "~/secrets/git.key";
          identities = {
            "github.com".user = "git";
          };
        };
      };

    };
  };

  home.packages = with pkgs; [
    podman-compose
    podman

    arion.arion
    nix-index
    nh

    man-pages
    man-pages-posix

    ripgrep
    tokei
    tlrc
    unp
  ];
}
