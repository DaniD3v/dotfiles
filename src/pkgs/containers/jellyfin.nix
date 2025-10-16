{
  dockerTools,
  ...
}:
dockerTools.pullImage {
  imageName = "jellyfin/jellyfin";

  hash = "sha256-Bf4IKs2zcFIJISYUpiEl+A2Db1NIUDQYHua0o82D9Ac=";
  imageDigest = "sha256:52f406d1cee8f898128a1cf9b479bf7b3f10c954e72abbecdf682e68bed3cb76";
}
