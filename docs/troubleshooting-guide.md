# Network Troubleshooting Guide

A structured approach to diagnosing and resolving common network infrastructure issues.

---

## Methodology — OSI Layer Approach

Always troubleshoot from bottom to top:

```
Layer 7 — Application   →  Is the service running? Correct config?
Layer 4 — Transport     →  Is the port open? Firewall blocking?
Layer 3 — Network       →  Can we ping? Correct routing?
Layer 2 — Data Link     →  Is the interface up? Correct VLAN?
Layer 1 — Physical      →  Is the cable connected? Link light on?
```

---

## DNS Issues

### Symptom: Cannot resolve hostnames

```bash
# Check if DNS is responding
dig @192.168.1.10 example.com

# Test with system resolver
nslookup example.com

# Check BIND9 service status
systemctl status named

# Check BIND9 logs
journalctl -u named -n 50

# Verify zone file syntax
named-checkzone example.com /etc/bind/zones/zone-example.com.conf

# Verify named.conf syntax
named-checkconf /etc/named.conf

# Flush DNS cache
systemd-resolve --flush-caches
```

### Symptom: Slow DNS resolution

```bash
# Measure query time
dig @192.168.1.10 example.com | grep "Query time"

# Check forwarders are reachable
ping -c 3 8.8.8.8
ping -c 3 1.1.1.1
```

---

## DHCP Issues

### Symptom: Client not receiving IP address

```bash
# Check DHCP service status
systemctl status isc-dhcp-server

# Check DHCP leases
cat /var/lib/dhcpd/dhcpd.leases

# Monitor DHCP traffic in real time
tcpdump -i eth0 port 67 or port 68 -n

# Check logs
journalctl -u isc-dhcp-server -n 50

# Verify config syntax
dhcpd -t -cf /etc/dhcp/dhcpd.conf
```

---

## VPN Issues

### Symptom: WireGuard peers cannot connect

```bash
# Check WireGuard interface status
wg show

# Check if interface is up
ip addr show wg0

# Verify UDP port is open
ss -ulnp | grep 51820

# Check firewall rules
iptables -L -n -v | grep 51820

# Test connectivity to VPN server
nc -zvu <server-ip> 51820

# Check IP forwarding is enabled
sysctl net.ipv4.ip_forward

# Enable IP forwarding temporarily
sysctl -w net.ipv4.ip_forward=1
```

---

## Firewall Issues

### Symptom: Traffic being dropped unexpectedly

```bash
# List all rules with line numbers
iptables -L -n -v --line-numbers

# Check NAT rules
iptables -t nat -L -n -v

# Monitor dropped packets in real time
journalctl -f | grep iptables-dropped

# Temporarily allow all traffic for testing
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT

# Check if specific port is reachable
nc -zv <host> <port>
```

---

## General Connectivity

### Quick diagnostic checklist

```bash
# 1. Check interface is up
ip link show

# 2. Check IP address assigned
ip addr show

# 3. Check default route
ip route show

# 4. Ping gateway
ping -c 3 192.168.1.1

# 5. Ping external
ping -c 3 8.8.8.8

# 6. Check DNS
dig google.com

# 7. Check open ports
ss -tlnp

# 8. Trace route to destination
traceroute 8.8.8.8

# 9. Capture traffic on interface
tcpdump -i eth0 -n host 192.168.1.1
```
