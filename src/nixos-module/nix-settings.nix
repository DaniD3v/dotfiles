{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # This is good for development.
      # `false` is a bad default.
      keep-going = true;
      warn-dirty = false;
    };

    optimise.automatic = true;
    gc.automatic = true;
  };
}
