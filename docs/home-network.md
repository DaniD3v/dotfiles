# Home network

## Switch ports

| Port | Device       | `management` | `uplink` |
|------|--------------|--------------|----------|
| 1    | thinkpad-e14 | U            |          |
| 3, 4 | APs          | U            | T        |
| 7    | server       | T            | T        |
| 8    | ISP router   |              | U        |

## Hardware

| Device     | Model             |
|------------|-------------------|
| switch     | NETGEAR GS108PEv3 |
| APs        |                   |
| ISP router | ZTE MC888A        |

## VLANs

| VLAN | Network      | Subnet           |
|------|--------------|------------------|
| 10   | `management` | `10.10.0.0/16`   |
| 90   | `uplink`     | `10.90.0.0/16`   |

## Addresses

### `management`

| Device       | Address     |
|--------------|-------------|
| switch       | `10.10.0.2` |
| AP           | `10.10.0.3` |
| AP           | `10.10.0.4` |
| thinkpad-e14 | `10.10.0.7` |
| server       | `10.10.0.9` |

### `uplink`

| Device            | Address         |
|-------------------|-----------------|
| ISP router        | `10.90.0.1`     |
| thinkpad-e14      | `10.90.0.7`     |
| server            | `10.90.0.8`     |
| DHCP pool - start | `10.90.1.1`     |
| DHCP pool - end   | `10.90.255.253` |

## Break-glass access

Port 1 is untagged `management`,
so you reach the switch, the APs and the server.

Switch: 10.10.0.2
AP: 10.10.0.3 & 10.10.0.4
Server: 10.10.0.9

If the server is down, the backup Wi-Fi still has Internet through the ISP
router.
