#!/bin/bash

TELEKUBE_VERSION="5.2.0"

# Configure required kernel modules and parameters
modprobe overlay || true
modprobe br_netfilter || true
modprobe ebtable_filter || true

cat > /etc/modules-load.d/telekube.conf <<EOT
brigde
overlay
ebtable_filter
EOT

cat > /etc/sysctl.d/50-telekube.conf <<EOT
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-iptables=1
EOT

sysctl -p /etc/sysctl.d/50-telekube.conf

# Install tele binary to download all assets for telekube
curl -o /usr/local/bin/tele https://get.gravitational.io/telekube/bin/${TELEKUBE_VERSION}/linux/x86_64/tele
chmod +x /usr/local/bin/tele

# Install telekube. Telekube.tar package contains everything necessary to install telekube
# including kubernetes and docker
/usr/local/bin/tele pull telekube:${TELEKUBE_VERSION} -o /tmp/telekube.tar
pushd /tmp
mkdir telekube
tar -xvf /tmp/telekube.tar -C telekube
cd telekube && ./gravity install --advertise-addr=172.28.128.101 --token=test
popd
rm -f /tmp/telekube.tar
rm -rf /tmp/telekube

# Create username and password for local user
gravity resource create -f  /tmp/local.yaml
