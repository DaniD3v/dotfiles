{
  config,
  pkgs,
  lib,
  dLib,
  ...
}:
with lib; let
  cfg = config.dotfiles.programs.alacritty;
  inherit (dLib) mkBookmarkOption;
in {
  options.dotfiles.programs.alacritty = {
    enable = mkEnableOption "Alacritty terminal emulator";

    browserBookmarks = mkBookmarkOption "Alacritty" {
      "Alacritty Wiki".url = "https://alacritty.org/config-alacritty.html";
    };
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;

      settings = {
        terminal.shell = getExe pkgs.nushell;

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

    dotfiles.programs.librewolf.bookmarks
    ."Toolbar".bookmarks."Ricing".bookmarks =
      mkIf cfg.browserBookmarks.enable cfg.browserBookmarks.export;

    dotfiles.desktop.hyprland.bindApp = [
      {
        bind = "$mainMod, D";
        run = "${pkgs.alacritty}/bin/alacritty";
      }
    ];

    # HACK: I should install this as a normal font/ only install it for alacritty.
    home.packages = with pkgs; [meslo-lgs-nf];
  };
}
