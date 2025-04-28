{pkgs, ...}: {
  programs = {
    alacritty.enable = true;

    librewolf = {
      enable = true;

      extensions = with pkgs.firefox-extensions; [
        bitwarden
      ];
    };
  };

  work.school = {
    nscs.enable = true;
    wmc.enable = true;
  };

  unfree.whiteList = [
    "packetTracer"
    "datagrip"
  ];

  helix.enable = true;

  language = {
    javascript.enable = true;
    nix.enable = true;
  };

  desktop = {
    enable = true;

    hyprland = {
      mainMonitor = "eDP-1";

      monitors = [
        "HDMI-A-1, preferred, auto, 1, mirror, eDP-1"
      ];

      input = {
        kb_layout = "us,de";
        kb_options = "grp:win_space_toggle";
      };
    };
  };
}
