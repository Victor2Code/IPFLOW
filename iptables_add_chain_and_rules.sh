#!/bin/bash

iptables -N IPFLOW

while read ip
do
iptables -I IPFLOW -i tun0 -d $ip -j ACCEPT
iptables -I IPFLOW -o tun0 -s $ip -j ACCEPT
done<ips.txt

iptables -I FORWARD -i tun0 -d 192.168.115.0/24 -j IPFLOW
iptables -I FORWARD -o tun0 -s 192.168.115.0/24 -j IPFLOW
