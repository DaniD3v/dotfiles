{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.dotfiles.location;
in {
  options.dotfiles.location = {
    timezone = mkOption {
      type = types.string;
      description = "The time zone used when displaying times and dates.";
    };

    locale = mkOption {
      type = types.string;
      description = "The default locale. It determines the language for program messages.";
    };
  };

  config = {
    time.timeZone = cfg.timezone;
    i18n.defaultLocale = cfg.locale;
  };
}
