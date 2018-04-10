#!/bin/bash
set -euo pipefail

# disk management
umount /dev/xvdb || true
mkfs.ext4 /dev/xvdb
mkfs.ext4 /dev/xvdf
sed -i.bak '/xvdb/d' /etc/fstab
sed -i.bak '/xvdc/d' /etc/fstab
echo -e '/dev/xvdb\t/var/lib/gravity\text4\tdefaults\t0\t2' >> /etc/fstab
echo -e '/dev/xvdf\t/var/lib/gravity/planet/etcd\text4\tdefaults\t0\t2' >> /etc/fstab
mkdir -p /var/lib/gravity
mount /var/lib/gravity
mkdir -p /var/lib/gravity/planet/etcd
mount /var/lib/gravity/planet/etcd
chown -R 1000:1000 /var/lib/gravity /var/lib/gravity/planet/etcd
sed -i.bak 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers

modprobe overlay || true
modprobe bridge || true
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

# install config
mkdir -p /etc/gravitational
cat > /etc/gravitational/tlskeypair.yaml <<EOT
kind: tlskeypair
version: v2
metadata:
  name: keypair
spec:
  private_key: |
    ${server_key}
  cert: |
    ${server_cert}
EOT

# install opscenter
yum -y install net-tools curl
curl https://get.gravitational.io/telekube/install | bash

mkdir -p /home/centos/opscenter
cd /home/centos/opscenter
tele pull opscenter:0.0.0+latest -o installer.tar.gz
tar xvf ./installer.tar.gz

PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

./gravity install --debug \
          --advertise-addr=$PRIVATE_IP \
          --token=${provisioning_token} \
          --flavor=standalone \
          --cluster=${cluster_name} \
          --ops-advertise-addr=${advertise_addr}

./gravity resource create /etc/gravitational/tlskeypair.yaml
