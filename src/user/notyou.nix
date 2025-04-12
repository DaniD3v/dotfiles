{pkgs, ...}: {
  programs = {
    alacritty.enable = true;
    librewolf.enable = true;
  };

  work = {
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
  };

  # TODO replace with languages.nix.enable
  lsp.nix.enable = true;

  hyprland = {
    enable = true;

    mainMonitor = "eDP-1";

    monitors = [
      "HDMI-A-1, preferred, auto, 1, mirror, eDP-1"
    ];

    input = {
      kb_layout = "us,de";
      kb_options = "grp:win_space_toggle";
    };
  };
}
