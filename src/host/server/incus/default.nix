{ pkgs, ... }:
{
  virtualisation.incus = {
    enable = true;
    ui.enable = true;

    package = pkgs.incus-lts.overrideAttrs (old: {
      patches = old.patches ++ [ ./preseed-certificates.patch ];
    });

    preseed = {
      # the web ui is served on incusd's https listener
      config."core.https_address" = ":8443";

      storage_pools = [
        {
          name = "images";
          driver = "dir";
        }
        {
          name = "data";
          driver = "dir";
          config.source = "/data/incus";
        }
      ];

      networks = [
        {
          name = "vms";
          type = "bridge";
          config = {
            # TODO: hand gateway, NAT and DHCP over to OpenWrt once it runs
            "ipv4.address" = "10.30.0.1/16";
            "ipv4.nat" = "true";

            "ipv6.address" = "none";
          };
        }
      ];

      profiles = [
        {
          name = "default";
          devices = {
            root = {
              type = "disk";
              path = "/";
              pool = "images";
            };

            eth0 = {
              type = "nic";
              network = "vms";
            };
          };
        }
      ];

      certificates = [
        {
          name = "notyou-browser";
          type = "client";
          certificate = builtins.readFile ../../../user/notyou-minimal/incus_client.crt;
        }
      ];
    };
  };

  networking.firewall.interfaces = {
    management.allowedTCPPorts = [ 8443 ];

    # incus' dnsmasq
    vms = {
      allowedTCPPorts = [
        53 # dns
      ];
      allowedUDPPorts = [
        53 # dns
        67 # dhcp
      ];
    };
  };

  # HACK: the incus module loads br_netfilter, which runs bridged frames through
  # NAT on br-trunk instead of uplink and loses the replies to masqueraded traffic.
  # IncusOS doesn't load it either; we only lose hairpin to forwards and ipv6_filtering
  boot.kernel.sysctl = {
    "net.bridge.bridge-nf-call-iptables" = 0;
    "net.bridge.bridge-nf-call-ip6tables" = 0;
    "net.bridge.bridge-nf-call-arptables" = 0;
  };

  # HACK: the dir driver requires an existing source
  systemd.tmpfiles.settings."10-incus"."/data/incus".d.mode = "0711";
}
