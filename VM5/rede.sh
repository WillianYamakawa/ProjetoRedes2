#!/bin/bash

service NetworkManager stop
service networking stop
ifconfig enp0s3 down
ip a flush enp0s3

ifconfig enp0s3 172.26.24.130/25 up

route add default gw 172.26.24.129

route -n
