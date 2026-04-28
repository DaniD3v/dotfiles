{ pkgs, ... }:
pkgs.k3d.overrideAttrs (prev: {
  nativeBuildInputs = prev.nativeBuildInputs ++ [ pkgs.makeWrapper ];

  postFixup = ''
    wrapProgram $out/bin/k3d \
      --run 'export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/podman/podman.sock"' \
      --run 'export DOCKER_SOCK="$XDG_RUNTIME_DIR/podman/podman.sock"'
  '';
})
