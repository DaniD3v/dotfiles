# Home network

## Switch ports

| Port | Device       | `management` | `uplink` |
|------|--------------|--------------|----------|
| 1    | thinkpad-e14 | U            |          |
| 3, 4 | APs          | U            | T        |
| 7    | server       | T            | T        |
| 8    | ISP router   |              | U        |

## Addresses

| Address        | Device                     |
|----------------|----------------------------|
| `192.168.0.1`  | ISP router                 |
| `192.168.0.7`  | thinkpad-e14               |
| `192.168.0.10` | server                     |
| `10.10.0.2`    | switch (NETGEAR GS108PEv3) |
| `10.10.0.3`    | AP                         |
| `10.10.0.4`    | AP                         |
| `10.10.0.7`    | thinkpad-e14               |
| `10.10.0.9`    | server                     |

## VLANs

| VLAN | Network      | Subnet           |
|------|--------------|------------------|
| 10   | `management` | `10.10.0.0/16`   |
| 90   | `uplink`     | `192.168.0.0/24` |

## Break-glass access

Port 1 is untagged `management`,
so you reach the switch, the APs and the server.

Switch: 10.10.0.2
AP: 10.10.0.3 & 10.10.0.4
Server: 10.10.0.9

If the server is down, the backup Wi-Fi still has Internet through the ISP
router.
