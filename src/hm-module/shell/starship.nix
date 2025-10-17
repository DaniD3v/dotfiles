{
  config,
  lib,
  dLib,
  ...
}:
with lib;
let
  cfg = config.dotfiles.starship;
  mkColorOption =
    default: description:
    mkOption {
      type = types.str;
      inherit default;

      example = "#512bd4";
      inherit description;
    };
in
{
  options.dotfiles.starship = {
    enable = mkOption {
      type = types.bool;
      default = true;

      description = "Whether to enable the starship shell prompt";
    };

    # HACK: this should be fixed upstream
    fixNuVirtualenvPrompt.enable = mkOption {
      type = types.bool;
      default = config.dotfiles.shells.nushell.enable;

      description = "Whether to fix a duplicate prompt when in a virtualenv";
    };

    theme = {
      fg = mkColorOption "#87875F" "foreground color";
      bg = mkColorOption "#303030" "background color";

      frame = mkColorOption "#6C6C6C" "color of the frame connecting the prompt components";
      dir = mkColorOption "#00AFFF" "color used to display directories";

      success_character = mkColorOption "#5FD700" "color of the ❯ arrow if the last command executed successfully";
      failure = mkColorOption "#FF0000" "color indicating the last command failed";

      os = mkColorOption "#EEEEEE" "color of the NixOS logo";
      os_bg = mkColorOption "#484848" "color of the NixOS logo background";

      sudo = mkColorOption "fg" "color of the sudo-unlock indicator";
      jobs = mkColorOption "#7c7c7c" "color to use for the number of background jobs";
      shlvl = mkColorOption "#088167" "color to use to display depth of nested shells";
      package = mkColorOption "#AC7647" "color used to display version of a package";

      git_branch = mkColorOption "#5FD700" null;
      git_remote_branch = mkColorOption "#d78e00" null;
      git_status = mkColorOption "#D7AF00" null;
      git_state = mkColorOption "#FF0000" "color for git operations like cherry-picking/rebasing";
    };

    browserBookmarks = dLib.mkBookmarkOption "Starship" {
      "Starship Wiki".url = "https://starship.rs/config";
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables = mkIf cfg.fixNuVirtualenvPrompt.enable {
      VIRTUAL_ENV_DISABLE_PROMPT = 1;
    };

    programs.starship = {
      enable = true;

      settings = {
        format =
          "[╭─](fg:frame)"
          + "["
          + (
            # Left prompt
            "[](fg:os_bg)"
            + "[](fg:os bg:os_bg)"
            + "[](fg:os_bg bg:bg) "
            + "$directory"
            + "( | $custom)( $git_branch)( $git_status)( $git_state)"
            + "[](fg:bg)"
            # Right prompt
            + (
              "$fill("
              + "[](fg:bg)"
              + "( $status|)"
              + "( $shlvl |)"
              + "( $cmd_duration |)"
              + "( $sudo |)"
              + "( $jobs |)"
              + "( $package |)"
              + ("( $rust |)" + "( $python |)" + "( $dotnet |)")
              + "" # this is a \b not a whitespace!
              + "[](fg:bg)"
              + ")"
            )
          )
          + "](fg:fg bg:bg)\n"
          + "[╰─](fg:frame)$character";

        palette = "home-manager";
        palettes.home-manager = {
          rust = "#F74C00";
          python = "#00AFAF";
          dotnet = "#512bd4";
        }
        // cfg.theme;

        fill.symbol = " "; # filler between left & right prompt

        character = {
          success_symbol = "[❯](success_character)";
          error_symbol = "[❯](failure)";
        };

        status = {
          disabled = false;
          style = "fg:failure bg:bg";
        };
        cmd_duration.format = "[󱎫 $duration](fg:duration bg:bg)";

        directory = {
          format = "[ﱮ $path( $read_only)](fg:dir bg:bg)";
          read_only = "";

          truncation_length = 5;
          truncation_symbol = "…/";
          truncate_to_repo = false; # disable forced truncation if in a git repo
        };

        sudo = {
          # HACK disable sudo module because it spams journald
          disabled = true;

          format = "[$symbol](fg:sudo bg:bg)";
          symbol = "";
        };

        jobs = {
          format = "[$symbol $number](fg:jobs bg:bg)";
          symbol = "";
        };

        shlvl = {
          disabled = false;

          format = "[$symbol $shlvl](fg:shlvl bg:bg)";
          symbol = "";
        };

        custom.git_icon = {
          format = "[$symbol](fg:git_branch bg:bg)";
          symbol = "";

          when = true;
          require_repo = true;

          description = "Displays a git icon when in a git repository";
        };

        git_branch = {
          format = "[$branch[(:$remote_branch)](fg:git_branch_remote)](fg:git_branch bg:bg)";
          ignore_branches = [
            "main"
            "master"
          ];
        };

        git_status = {
          format = "[($all_status$ahead_behind)](fg:git_status bg:bg)";
          stashed = "~";
        };

        package.format = "[󰏗 $version](fg:package bg:bg)";

        rust.format = "[ $version](fg:rust bg:bg)";
        python = {
          format = "[ $version(via $pyenv_prefix)](fg:python bg:bg)";
          pyenv_prefix = "venv";
        };
        dotnet.format = "[ $version](fg:dotnet bg:bg)";
      };
    };

    dotfiles.programs.librewolf.bookmarks."Toolbar".bookmarks."Ricing".bookmarks =
      mkIf cfg.browserBookmarks.enable cfg.browserBookmarks.export;
  };
}
