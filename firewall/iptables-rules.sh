#!/bin/bash
# iptables-rules.sh — Production Linux Server Firewall Rules
# Usage: sudo ./iptables-rules.sh
# Tested on: Ubuntu 20.04+, Debian 11+, RHEL 8+

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root.${NC}"
    exit 1
fi

# ── CONFIGURATION ─────────────────────────────────────────────────────────────
SSH_PORT=22
WG_PORT=51820
HTTP_PORT=80
HTTPS_PORT=443
MONITORING_PORT=9090
ADMIN_IP="192.168.1.0/24"    # Trusted network for admin access

echo "=================================================="
echo "  Applying iptables firewall rules"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "=================================================="

# ── FLUSH EXISTING RULES ──────────────────────────────────────────────────────
echo -e "\n${YELLOW}Flushing existing rules...${NC}"
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# ── DEFAULT POLICIES ──────────────────────────────────────────────────────────
echo -e "${YELLOW}Setting default policies...${NC}"
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# ── LOOPBACK ──────────────────────────────────────────────────────────────────
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# ── ESTABLISHED CONNECTIONS ───────────────────────────────────────────────────
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# ── ICMP (PING) ───────────────────────────────────────────────────────────────
iptables -A INPUT -p icmp --icmp-type echo-request -m limit \
    --limit 1/s --limit-burst 5 -j ACCEPT

# ── SSH ───────────────────────────────────────────────────────────────────────
# Allow SSH only from trusted network
iptables -A INPUT -p tcp --dport $SSH_PORT -s $ADMIN_IP \
    -m conntrack --ctstate NEW -j ACCEPT
# Rate limit SSH to prevent brute force
iptables -A INPUT -p tcp --dport $SSH_PORT \
    -m conntrack --ctstate NEW \
    -m recent --set --name SSH
iptables -A INPUT -p tcp --dport $SSH_PORT \
    -m conntrack --ctstate NEW \
    -m recent --update --seconds 60 --hitcount 4 --name SSH -j DROP

# ── WEB ───────────────────────────────────────────────────────────────────────
iptables -A INPUT -p tcp --dport $HTTP_PORT -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -p tcp --dport $HTTPS_PORT -m conntrack --ctstate NEW -j ACCEPT

# ── WIREGUARD VPN ─────────────────────────────────────────────────────────────
iptables -A INPUT -p udp --dport $WG_PORT -j ACCEPT
iptables -A FORWARD -i wg0 -j ACCEPT
iptables -A FORWARD -o wg0 -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# ── MONITORING ────────────────────────────────────────────────────────────────
# Allow Prometheus only from trusted network
iptables -A INPUT -p tcp --dport $MONITORING_PORT -s $ADMIN_IP -j ACCEPT

# ── DROP INVALID PACKETS ──────────────────────────────────────────────────────
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# ── LOG DROPPED PACKETS ───────────────────────────────────────────────────────
iptables -A INPUT -m limit --limit 5/min -j LOG \
    --log-prefix "iptables-dropped: " --log-level 4

echo -e "${GREEN}Firewall rules applied successfully.${NC}"
echo ""
echo "Current rules:"
iptables -L -n -v --line-numbers

echo ""
echo "=================================================="
echo -e "${YELLOW}Note: Rules are not persistent across reboots.${NC}"
echo "To persist: apt install iptables-persistent"
echo "            netfilter-persistent save"
echo "=================================================="
