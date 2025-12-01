{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.dotfiles.shell;
in
{
  imports = [
    ./nushell.nix
    ./starship.nix
  ];

  options.dotfiles.shell = {
    default = mkOption {
      type = types.enum [ "nushell" ];
      default = "nushell";

      description = "Default shell to use";
    };

    completions.enable = mkOption {
      type = types.bool;
      default = true;

      description = "Whether to enable completitions using carapace";
    };

    zoxide.enable = mkEnableOption "Zoxide";
  };

  config = {
    # enable the selected shell
    dotfiles.shells.${cfg.default}.enable = true;

    programs = {
      zoxide.enable = cfg.zoxide.enable;
      carapace.enable = cfg.completions.enable;
    };
  };
}
