{
  networking = {
    useNetworkd = true;

    nameservers = [ "127.0.0.1" ];
    useDHCP = false;

    firewall.interfaces.uplink = {
      allowedTCPPorts = [
        53 # dns

        # web
        80
        443

        25565 # minecraft
      ];
      allowedUDPPorts = [
        53 # dns

        # web
        80
        443

        3478 # stun server (netbird)
      ];
    };
  };

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
        { VLAN = 90; }
      ];
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

    management = {
      name = "management";
      address = [ "10.10.0.9/16" ];
    };

    # TODO: IPv6 doesn't work due to ISP
    uplink = {
      name = "uplink";
      address = [ "10.90.0.8/16" ];
      gateway = [ "10.90.0.1" ];
    };
  };
}
