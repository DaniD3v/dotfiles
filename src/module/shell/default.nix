{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.dotfiles.shell;
in {
  imports = [
    ./nushell.nix
    ./starship.nix
  ];

  options.dotfiles.shell = {
    default = mkOption {
      type = types.enum ["nushell"];
      default = "nushell";
    };

    defaultPackage = mkOption {
      type = types.package;
      readOnly = true;

      default = config.programs.${cfg.default}.package;
    };
  };

  config = {
    # enable the selected shell
    dotfiles.shells.${cfg.default}.enable = true;

    programs = {
      zoxide.enable = true;
      carapace.enable = true;
    };
  };
}
