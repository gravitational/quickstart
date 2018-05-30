#!/bin/bash

# Configure required kernel modules and parameters
modprobe overlay || true
modprobe br_netfilter || true
modprobe ebtable_filter || true

cat > /etc/modules-load.d/telekube.conf <<EOT
br_netfilter
overlay
ebtable_filter
EOT

cat > /etc/sysctl.d/50-telekube.conf <<EOT
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-iptables=1
EOT

sysctl -p /etc/sysctl.d/50-telekube.conf

# Install mattermost application
cd /vagrant
tar -xvf mattermost.tar
./gravity install --advertise-addr=172.28.128.101 --token=test
gravity resource create -f  /tmp/local.yaml
