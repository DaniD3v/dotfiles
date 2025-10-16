{ callPackage, ... }:
{
  jellyfin = callPackage ./jellyfin.nix { };
  nginx = callPackage ./nginx.nix { };
}
