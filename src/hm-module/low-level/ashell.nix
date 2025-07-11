{
  config,
  pkgs,
  lib,
  dLib,
  ...
}:
with lib;
let
  cfg = config.programs.ashell;
  tomlFormat = pkgs.formats.toml { };
in
{
  options.programs.ashell = {
    enable = mkEnableOption "Ashell desktop shell";
    package = mkPackageOption pkgs.unstable "ashell" { };

    systemd = {
      enable = mkOption {
        type = types.bool;
        default = true;

        description = "Whether to start ashell with systemd";
      };

      target = mkOption {
        type = types.str;
        default = config.wayland.systemd.target;

        description = "Systemd target to start ashell with";
      };
    };

    settings = mkOption {
      type = tomlFormat.type;
      default = { };

      example = {
        clipboardCmd = "cliphist-rofi-img | wl-copy";
      };
    };
  };

  config =
    let
      configFile = if (cfg.settings != { }) then tomlFormat.generate "config.toml" cfg.settings else null;
    in
    mkIf cfg.enable {
      home.packages = [ cfg.package ];

      xdg.configFile."ashell/config.toml" = mkIf (configFile != null) { source = configFile; };

      systemd.user.services.ashell = mkIf cfg.systemd.enable (
        dLib.mkWaylandService
          {
            systemdTarget = cfg.systemd.target;
            providesTray = true;
          }
          {
            Unit = {
              Description = "Ashell desktop shell";
              Documentation = "https://github.com/MalpenZibo/ashell/blob/${cfg.package.version}/README.md#configuration";

              X-Restart-Triggers = mkIf (configFile != null) "${configFile}";
            };

            Service.ExecStart = lib.getExe cfg.package;
          }
      );
    };
}
