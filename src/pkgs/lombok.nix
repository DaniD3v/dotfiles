{
  fetchurl,
  ...
}:
let
  version = "1.18.48";
in
fetchurl {
  url = "https://projectlombok.org/downloads/lombok-${version}.jar";
  hash = "sha256-hUd6RlXrssB0qQmc+3Sb5FREn+5WTUKCYQ3xuF98UIs=";
}
