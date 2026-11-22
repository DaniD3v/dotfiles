{
  config,
  lib,
  ...
}:
{
  # Secret Service, unlocked by PAM at login
  config = lib.mkIf config.dotfiles.desktop.enable {
    services.gnome.gnome-keyring.enable = true;

    # the keyring needs the login password to unlock
    security.pam.services.login.fprintAuth = false;
  };
}
