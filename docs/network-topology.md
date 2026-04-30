# Network Topology Reference

## Overview

This document describes a typical small-to-medium infrastructure network layout used as reference for this lab.

## Network Diagram

```
                        INTERNET
                            |
                      [Router/FW]
                      192.168.1.1
                            |
              +-------------+-------------+
              |                           |
        [Switch L2/L3]              [WireGuard VPN]
              |                      192.168.1.40
    +---------+---------+                |
    |         |         |           Remote Peers
    |         |         |           10.0.0.2-10
    |         |         |
[server-01] [server-02] [monitoring]
192.168.1.10 192.168.1.11 192.168.1.50
  DNS/DHCP    App Server   Grafana
  BIND9                    Prometheus
```

## IP Address Plan

| Host | IP Address | Role |
|------|-----------|------|
| Router / Firewall | 192.168.1.1 | Default gateway, NAT |
| server-01 | 192.168.1.10 | DNS primary, DHCP server |
| server-02 | 192.168.1.11 | DNS secondary, App server |
| vpn-gateway | 192.168.1.40 | WireGuard VPN endpoint |
| monitoring | 192.168.1.50 | Grafana, Prometheus, Alertmanager |
| DHCP Pool | 192.168.1.100 – 192.168.1.200 | Dynamic clients |

## Services Map

| Service | Host | Port | Protocol |
|---------|------|------|----------|
| DNS | server-01 | 53 | TCP/UDP |
| DHCP | server-01 | 67/68 | UDP |
| SSH | All servers | 22 | TCP |
| HTTP | server-02 | 80 | TCP |
| HTTPS | server-02 | 443 | TCP |
| WireGuard VPN | vpn-gateway | 51820 | UDP |
| Prometheus | monitoring | 9090 | TCP |
| Grafana | monitoring | 3000 | TCP |
| Alertmanager | monitoring | 9093 | TCP |

## VPN Address Plan

| Peer | VPN IP | Description |
|------|--------|-------------|
| VPN Server | 10.0.0.1 | WireGuard server interface |
| Peer 1 | 10.0.0.2 | Remote laptop |
| Peer 2 | 10.0.0.3 | Remote office |
| Peer 3 | 10.0.0.4 | Mobile device |

## Firewall Policy

| Direction | Source | Destination | Port | Action |
|-----------|--------|-------------|------|--------|
| Inbound | Any | Server | 80, 443 | ACCEPT |
| Inbound | 192.168.1.0/24 | Server | 22 | ACCEPT |
| Inbound | 192.168.1.0/24 | Monitoring | 9090, 3000 | ACCEPT |
| Inbound | Any | VPN Gateway | 51820/UDP | ACCEPT |
| Inbound | Any | Any | * | DROP |
| Forward | wg0 | eth0 | * | ACCEPT |
