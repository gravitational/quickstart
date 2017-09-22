#!/bin/bash

# turn on ipv4 forwarding
egrep -q "^(\s*)net.ipv4.ip_forward\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.ip_forward\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.ip_forward = 1\2/" /etc/sysctl.conf || echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -w net.ipv4.ip_forward=1

cd /vagrant
tar -xf mattermost.tar
./gravity install --advertise-addr=172.28.128.101 --token=test
gravity resource create -f  /tmp/local.yaml

