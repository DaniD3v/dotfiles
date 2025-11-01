{
  fetchurl,
  ...
}:
let
  version = "1.18.42";
in
fetchurl {
  url = "projectlombok.org/downloads/lombok-${version}.jar";
  hash = "sha256-NIik6ZlMJllrqs7r7ljK02pQ472uxb5ytYNNPDtWAwY=";
}
