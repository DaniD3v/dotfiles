{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.dotfiles.editor;
in
{
  imports = [
    ./helix.nix
    ./lsp.nix
  ];

  options.dotfiles.editor = {
    default = mkOption {
      type = types.enum [ "helix" ];
      default = "helix";
    };
  };

  config = {
    # enable the selected editor
    dotfiles.editors.${cfg.default}.enable = true;
    programs.${cfg.default}.defaultEditor = true;
  };
}
