{
  callPackage,
  wrapFirefox,
  firefox-unwrapped,
  ...
}:
wrapFirefox (callPackage ./. { } firefox-unwrapped) { }
