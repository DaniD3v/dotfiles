{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.dotfiles.programs.alacritty;
in {
  options.dotfiles.programs.alacritty = {
    enable = mkEnableOption "alacritty terminal emulator";
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;

      settings = {
        terminal = {
          shell = "${pkgs.nushell}/bin/nu";
        };

        window = {
          dynamic_padding = true;
          opacity = 0.5;
        };

        font.normal = {
          family = "MesloLGSNF";
          style = "Regular";
        };
      };
    };

    dotfiles.hyprland.bindApp = [
      {
        bind = "$mainMod, D";
        run = "${pkgs.alacritty}/bin/alacritty";
      }
    ];

    home.packages = with pkgs; [meslo-lgs-nf];
  };
}
