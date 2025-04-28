lib: {
  inherit (import ../module/programs/librewolf/bookmark.nix {inherit lib;}) mkBookmarkOption;
}
