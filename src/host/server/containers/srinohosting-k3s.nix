{ pkgs, ... }:
{
  virtualisation.oci-containers.containers.srinohosting-k3s =
    let
      imageName = "rancher/k3s";
    in
    {
      image = imageName;
      imageFile = pkgs.dockerTools.pullImage {
        inherit imageName;

        imageDigest = "sha256:c3184157c3048112bab0c3e17405991da486cb3413511eba23f7650efd70776b";
        hash = "sha256-QiCCGlN51oISupBSMB58dNXedLTk85i6giTUwUyHg3Y=";
      };

      privileged = true;

      cmd = [
        "server"
        "--default-local-storage-path=/data"
        "--kubelet-arg=feature-gates=KubeletInUserNamespace=true"
      ];
      volumes = [
        "/data/srinohosting-k3s:/data"
      ];
    };

  systemd.tmpfiles.rules = [
    "d /data/srinohosting-k3s 0700 root root -"
  ];
}
