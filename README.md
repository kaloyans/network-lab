# network-lab

A collection of network configuration templates, topology diagrams, and documentation covering DNS, DHCP, VPN, and firewall setups — built for real-world infrastructure environments.

## Structure

```
network-lab/
├── dns/
│   ├── named.conf
│   └── zone-example.com.conf
├── dhcp/
│   └── dhcpd.conf
├── vpn/
│   └── wireguard-server.conf
├── firewall/
│   └── iptables-rules.sh
└── docs/
    ├── network-topology.md
    └── troubleshooting-guide.md
```

## Topics Covered

| Area | Description |
|------|-------------|
| **DNS** | BIND9 configuration with forward and reverse zones |
| **DHCP** | ISC DHCP server config with static leases and pools |
| **VPN** | WireGuard server setup for secure remote access |
| **Firewall** | iptables rules for a production Linux server |
| **Docs** | Network topology reference and troubleshooting guide |

## Purpose

These configurations are tested templates used as reference for setting up and maintaining network infrastructure in Linux environments. Each file is heavily commented for clarity and reusability.
