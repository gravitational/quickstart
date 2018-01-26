#!/bin/bash

TELEKUBE_VERSION="4.53.0"

# turn on ipv4 forwarding
egrep -q "^(\s*)net.ipv4.ip_forward\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.ip_forward\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.ip_forward = 1\2/" /etc/sysctl.conf || echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -w net.ipv4.ip_forward=1

# Install tele binary to download all assets for telekube
curl -o /usr/local/bin/tele https://get.gravitational.io/telekube/bin/${TELEKUBE_VERSION}/linux/x86_64/tele
chmod +x /usr/local/bin/tele

# Install telekube. Telekube.tar package contains everything necessary to install telekube
# including kubernetes and docker
/usr/local/bin/tele pull telekube:${TELEKUBE_VERSION} -o /tmp/telekube.tar
pushd /tmp
mkdir telekube
tar -xf /tmp/telekube.tar -C telekube
cd telekube && ./gravity install --advertise-addr=172.28.128.101 --token=test
popd
rm -f /tmp/telekube.tar
rm -rf /tmp/telekube

# Create username and password for local user
gravity resource create -f  /tmp/local.yaml

