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

  xdg.userDirs = {
    enable = true;
    setSessionVariables = false;
  };

  programs = {
    # HACK: Leaving this at the default is deprecated
    ssh.enableDefaultConfig = false;

    nushell = {
      shellAliases = {
        "c" = "with-env {\"SHLVL\": 0} {job spawn {alacritty --working-directory .}}";
      };
    };
  };

  dotfiles = {
    programs = {
      git = {
        enable = true;

        user = {
          name = "DaniD3v";
          email = "sch220233@spengergasse.at";
        };

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

    shell.zoxide.enable = true;
  };

  home.packages = with pkgs; [
    docker-compose
    podman
    k3d-podman
    tilt

    kubernetes-helm
    helmfile
    kubectl
    fluxcd
    talosctl
    opentofu

    nix-index
    nh

    man-pages
    man-pages-posix
    ripgrep
    difftastic
    jujutsu
    jq
    tokei
    btop
    tlrc
    unp

    wl-clipboard-rs
    distrobox
    lldb
    just
  ];
}
