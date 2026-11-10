{
  callPackage,
  wrapFirefox,
  librewolf-unwrapped,
}:
wrapFirefox (callPackage ./. { } librewolf-unwrapped) {
  inherit (librewolf-unwrapped) extraPrefsFiles extraPoliciesFiles;
  libName = "librewolf";
}
