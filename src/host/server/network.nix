{
  networking = {
    useNetworkd = true;

    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
    ];
    useDHCP = false;
  };

  services.resolved.settings.Resolve.DNSOverTLS = true;

  systemd.network.netdevs = {
    br-trunk = {
      netdevConfig = {
        Kind = "bridge";
        Name = "br-trunk";
      };
      bridgeConfig = {
        VLANFiltering = true;
        DefaultPVID = "none";
      };
    };

    br-vms = {
      netdevConfig = {
        Kind = "bridge";
        Name = "br-vms";
      };
    };

    management = {
      netdevConfig = {
        Kind = "vlan";
        Name = "management";
      };
      vlanConfig.Id = 10;
    };

    uplink = {
      netdevConfig = {
        Kind = "vlan";
        Name = "uplink";
      };
      vlanConfig.Id = 90;
    };
  };

  systemd.network.networks = {
    enp15s0 = {
      name = "enp15s0";
      networkConfig.Bridge = "br-trunk";

      bridgeVLANs = [
        { VLAN = 10; }
        { VLAN = 20; }
        { VLAN = 40; }
        { VLAN = 90; }
      ];
    };

    # untagged untrusted
    enp1s0f0 = {
      name = "enp1s0f0";
      networkConfig.Bridge = "br-trunk";

      bridgeVLANs = [
        {
          VLAN = 40;
          PVID = 40;
          EgressUntagged = 40;
        }
      ];
      linkConfig.RequiredForOnline = "no";
    };

    br-trunk = {
      name = "br-trunk";
      networkConfig = {
        VLAN = [
          "management"
          "uplink"
        ];
        LinkLocalAddressing = "no";
      };

      bridgeVLANs = [
        { VLAN = 10; }
        { VLAN = 90; }
      ];
    };

    # no host address
    br-vms = {
      name = "br-vms";
      networkConfig.LinkLocalAddressing = "no";
      linkConfig.RequiredForOnline = "no";
    };

    management = {
      name = "management";
      address = [ "10.10.0.8/16" ];
    };

    # TODO: IPv6 doesn't work due to ISP
    uplink = {
      name = "uplink";
      address = [ "10.90.0.8/16" ];
      gateway = [ "10.90.0.1" ];
    };
  };
}
