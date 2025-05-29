{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.dotfiles.language.csharp;
in {
  options.dotfiles.language.csharp = {
    enable = mkEnableOption "csharp developement tools";
    enableTelemetry = mkEnableOption ".NET tools telemetry";
  };

  config = mkIf cfg.enable {
    dotfiles.lsp.csharp.enable = true;

    home.sessionVariables = mkIf (!cfg.enableTelemetry) {
      DOTNET_CLI_TELEMETRY_OPTOUT = 1;
    };

    home.packages = with pkgs; [
      dotnet-sdk
      dotnet-ef
    ];
  };
}
