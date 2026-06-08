{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  networking.nftables = {
    enable = true;
    tables."mac-dnat" = {
      family = "ip";
      content = ''
        chain prerouting {
          type nat hook prerouting priority dstnat; policy accept;
          tcp dport 11228 dnat to 192.168.0.11:22
        }

        chain postrouting {
          type nat hook postrouting priority srcnat; policy accept;
          ip daddr 192.168.0.11 masquerade
        }
      '';
    };
  };
}
