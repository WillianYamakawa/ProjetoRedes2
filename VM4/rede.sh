#!/bin/bash

service NetworkManager stop
service networking stop
ifconfig enp0s3 down
ip a flush enp0s3

ifconfig enp0s3 172.26.24.4/25 up

route add default gw 172.26.24.1
route add -net 172.26.24.128/25 gw 172.26.24.2

route -n
