{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.dotfiles.desktop.ashell;
in {
  options.dotfiles.desktop.ashell = {
    enable = mkEnableOption "Ashell desktop shell";

    truncateTitle = mkOption {
      type = types.bool;
      default = true;

      description = ''
        Whether to truncate window titles.
        This makes sure that the center item stay in the center.
      '';
    };
  };

  config = {
    programs.ashell = mkIf cfg.enable {
      enable = true;

      settings = {
        truncate_title_after_length = mkIf cfg.truncateTitle 75;

        modules = {
          left = ["Workspaces" "WindowTitle"];
          center = [["Clock" "MediaPlayer"]];
          right = [["SystemInfo" "KeyboardLayout" "Settings"]];
        };
      };
    };
  };
}
