variable "key_pair" {}
variable "provisioning_token" {}

variable "advertise_addr" {
    description = "format: <hostname>:<https-port>,<ssh-port>, e.g. example.com:443,33008"
}

variable "region" {
    default = "us-east-1"
}

variable "cluster_name" {
    default = "telekube-opscenter-test-2"
}

variable "server_key" {
    default = "server.key"
}

variable "server_cert" {
    default = "server.crt"
}

variable "nodes" {
    default = 1
}

variable "ami" {
    default = "ami-f19395e6"
}

variable "instance_type" {
    default = "m4.xlarge"
}

provider "aws" {
    region = "${var.region}"
}

resource "aws_placement_group" "cluster" {
    name = "${var.cluster_name}"
    strategy = "cluster"
}

output "public_ip" {
    value = "${join(" ", aws_instance.node.*.public_ip)}"
}

output "private_ip" {
    value = "${join(" ", aws_instance.node.*.private_ip)}"
}

resource "aws_iam_role_policy" "k8s_policy" {
    name = "${var.cluster_name}"
    role = "${aws_iam_role.k8s_role.id}"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::kubernetes-*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "k8s_role" {
    name = "${var.cluster_name}"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "k8s_profile" {
    name = "${var.cluster_name}"
    roles = ["${aws_iam_role.k8s_role.name}"]
}

resource "aws_security_group" "cluster" {
    tags {
        Name = "${var.cluster_name}"
    }

    # SSH access from anywhere
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # SSH 61822 access from anywhere
    ingress {
        from_port   = 61822
        to_port     = 61822
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        self = true
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "node" {
    ami = "${var.ami}"
    instance_type = "${var.instance_type}"
    iam_instance_profile = "${aws_iam_instance_profile.k8s_profile.name}"
    associate_public_ip_address = true
    source_dest_check = "false"
    ebs_optimized = true
    security_groups = ["${aws_security_group.cluster.name}"]
    key_name = "${var.key_pair}"
    placement_group = "${aws_placement_group.cluster.id}"
    count = "${var.nodes}"

    tags {
        Name = "${var.cluster_name}"
        KubernetesCluster = "${var.cluster_name}"
    }

    user_data = <<EOF
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

# install config
mkdir -p /etc/gravitational
cat > /etc/gravitational/tlskeypair.yaml <<EOT
kind: tlskeypair
version: v2
metadata:
  name: keypair
spec:
  private_key: |
    ${indent(4, file(var.server_key))}
  cert: |
    ${indent(4, file(var.server_cert))}
EOT

# install opscenter
yum -y install net-tools curl
curl https://get.gravitational.io/telekube/install | bash

mkdir -p /home/centos/opscenter
cd /home/centos/opscenter
tele pull opscenter:0.0.0+latest -o installer.tar.gz
tar xvf ./installer.tar.gz

PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

./gravity install --advertise-addr=$PRIVATE_IP --token=${var.provisioning_token} --flavor=standalone --cluster=${var.cluster_name} --ops-advertise-addr=${var.advertise_addr} --debug
./gravity resource create /etc/gravitational/tlskeypair.yaml

EOF

    root_block_device {
        delete_on_termination = true
        volume_type = "gp2"
        volume_size = "50"
    }

    # /var/lib/gravity device
    ebs_block_device = {
        volume_size = "100"
        volume_type = "gp2"
        device_name = "/dev/xvdb"
        delete_on_termination = true
    }

    # etcd device
    ebs_block_device = {
        volume_size = "50"
        volume_type = "io1"
        device_name = "/dev/xvdf"
        iops = 2500
        delete_on_termination = true
    }
}
