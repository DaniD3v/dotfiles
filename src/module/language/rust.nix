{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.dotfiles.language.rust;

  toolchain = pkgs.fenix.complete.withComponents [
    "rust-std"
    "cargo"
    "rustc"

    "rust-analyzer"
    "rustfmt"
    "clippy"
  ];
in {
  options.dotfiles.language.rust = {
    enable = mkEnableOption "rust developement tools";
  };

  config = mkIf cfg.enable {
    home.packages = [
      toolchain
    ];

    programs.nushell.extraConfig = ''
      def "cargo-missing-system-deps" [] {
        cargo b --keep-going | complete | get stderr | split row " "
          | parse -r "`(.*\\.pc)`" | get "capture0" | uniq
      }
    '';
  };
}
