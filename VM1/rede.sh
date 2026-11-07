#!/bin/bash

IP_EXTERNO="IP_DA_VM1/PREFIXO"
GATEWAY_EXTERNO="IP_DO_GATEWAY"

if ! command -v iptables >/dev/null 2>&1; then
    apt-get update && apt-get install -y iptables || exit 1
fi

service NetworkManager stop
service networking stop
ifconfig enp0s3 down
ifconfig enp0s8 down
ip a flush enp0s3
ip a flush enp0s8

ifconfig enp0s3 "$IP_EXTERNO" up
ifconfig enp0s8 172.26.24.1/25 up

route add default gw "$GATEWAY_EXTERNO"
route add -net 172.26.24.128/25 gw 172.26.24.2

echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -t nat -F
iptables -t nat -A POSTROUTING -o enp0s3 -j SNAT --to "${IP_EXTERNO%/*}"

route -n
