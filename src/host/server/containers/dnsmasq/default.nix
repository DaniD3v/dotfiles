{ pkgs, ... }:
{
  virtualisation.oci-containers.containers.dnsmasq =
    let
      imageName = "dockurr/dnsmasq";
    in
    {
      image = imageName;
      imageFile = pkgs.dockerTools.pullImage {
        inherit imageName;

        imageDigest = "sha256:e84feecd6551b586cf86f830f111ef36c399b0ca26a9bb6dae4a8ceb11626373";
        hash = "sha256-mRIzECMxX7khBqpgQNA2p5JYfW5TPn0FJEHz8M01Tmc=";
      };

      ports = [
        "53:53/tcp"
        "53:53/udp"
      ];
      capabilities = {
        NET_ADMIN = true;
        NET_RAW = true;
      };

      volumes = [
        "${./dnsmasq.conf}:/etc/dnsmasq.conf"
      ];
    };
}
