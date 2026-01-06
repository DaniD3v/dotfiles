{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.dotfiles.language.python;
in
{
  options.dotfiles.language.python = {
    enable = mkEnableOption "python developement tools";
  };

  config = mkIf cfg.enable {
    dotfiles.lsp.python.enable = true;

    home.packages = [
      (pkgs.python3.withPackages (
        pythonPackages: with pythonPackages; [
          virtualenv
          requests

          pycryptodome
          pwntools
        ]
      ))

      pkgs.uv
      pkgs.ruff
    ];
  };
}
