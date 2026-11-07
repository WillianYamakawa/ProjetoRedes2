#!/bin/bash

service NetworkManager stop
service networking stop
ifconfig enp0s3 down
ifconfig enp0s8 down
ip a flush enp0s3
ip a flush enp0s8

ifconfig enp0s3 172.26.24.2/25 up
ifconfig enp0s8 172.26.24.129/25 up

route add default gw 172.26.24.1

echo 1 > /proc/sys/net/ipv4/ip_forward

route -n
