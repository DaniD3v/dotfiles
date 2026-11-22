{
  networking.hostId = "a502bc6e";

  # HACK: stateVersion 23.11 defaults to force-importing pools past ZFS's safeguards
  boot.zfs.forceImportRoot = false;

  services.zfs.autoScrub.enable = true;
}
