{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.dotfiles.language.rust;

  toolchain = pkgs.fenix.complete.withComponents [
    "rust-std"
    "cargo"
    "rustc"

    "rust-analyzer"
    "rust-src"
    "rustfmt"
    "clippy"
  ];
in
{
  options.dotfiles.language.rust = {
    enable = mkEnableOption "rust developement tools";

    includeCommonDeps = mkOption {
      type = types.bool;
      default = true;

      description = "Whether to install packages commonly required by rust projects.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = mkMerge [
      [
        toolchain
      ]

      (mkIf cfg.includeCommonDeps (
        with pkgs;
        [
          clang
          pkg-config
        ]
      ))
    ];
  };
}
