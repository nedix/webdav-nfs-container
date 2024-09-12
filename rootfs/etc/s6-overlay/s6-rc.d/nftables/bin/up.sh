#!/usr/bin/env sh

iptables-save | iptables-restore-translate -f /dev/stdin > /etc/nftables.d/iptables.nft
iptables -F
iptables -X
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

exec nft -f /etc/nftables.nft
