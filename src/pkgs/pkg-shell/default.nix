{ writeScriptBin }: writeScriptBin "pkg-shell" (builtins.readFile ./pkg-shell.nu)
