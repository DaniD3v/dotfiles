{
  dockerTools,
  ...
}:
dockerTools.pullImage {
  imageName = "nginx";

  hash = "sha256-c2EMr1Jdew5hmWwpPAxTNSu2sMY88kV0itBIsmqO5ew=";
  imageDigest = "sha256:4e272eef7ec6a7e76b9c521dcf14a3d397f7c370f48cbdbcfad22f041a1449cb";
}
