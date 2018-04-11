variable "key_pair" {}
variable "provisioning_token" {}

variable "advertise_addr" {
    description = "format: <hostname>:<port>, e.g. example.com:443"
}

variable "region" {
    default = "us-east-1"
}

variable "cluster_name" {
    default = "telekube-opscenter-test"
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

data "template_file" "user_data" {
  template = "${file("userdata.tpl")}"
  vars {
    server_key = "${indent(4, file(var.server_key))}"
    server_cert = "${indent(4, file(var.server_cert))}"
    provisioning_token = "${var.provisioning_token}"
    cluster_name = "${var.cluster_name}"
    advertise_addr = "${var.advertise_addr}"
  }
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
                "autoscaling:*",
                "ec2:*",
                "elasticloadbalancing:*",
                "iam:AddRoleToInstanceProfile",
                "iam:CreateInstanceProfile",
                "iam:CreateRole",
                "iam:DeleteInstanceProfile",
                "iam:DeleteRole",
                "iam:DeleteRolePolicy",
                "iam:GetInstanceProfile",
                "iam:GetRole",
                "iam:GetRolePolicy",
                "iam:ListInstanceProfiles",
                "iam:ListInstanceProfilesForRole",
                "iam:ListRoles",
                "iam:PassRole",
                "iam:PutRolePolicy",
                "iam:RemoveRoleFromInstanceProfile",
                "kms:DescribeKey",
                "kms:ListAliases",
                "kms:ListKeys",
                "s3:*",
                "sqs:ChangeMessageVisibility",
                "sqs:ChangeMessageVisibilityBatch",
                "sqs:CreateQueue",
                "sqs:DeleteMessage",
                "sqs:DeleteMessageBatch",
                "sqs:DeleteQueue",
                "sqs:GetQueueAttributes",
                "sqs:GetQueueUrl",
                "sqs:ListDeadLetterSourceQueues",
                "sqs:ListQueueTags",
                "sqs:ListQueues",
                "sqs:PurgeQueue",
                "sqs:ReceiveMessage",
                "sqs:SendMessage",
                "sqs:SendMessageBatch",
                "sqs:SetQueueAttributes",
                "sqs:TagQueue",
                "sqs:UntagQueue",
                "ssm:DeleteParameter",
                "ssm:DeleteParameters",
                "ssm:DescribeParameters",
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:ListTagsForResource",
                "ssm:PutParameter"
            ],
            "Resource": "*"
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
    user_data = "${data.template_file.user_data.rendered}"

    lifecycle {
      ignore_changes = ["user_data"]
    }

    tags {
        Name = "${var.cluster_name}"
        KubernetesCluster = "${var.cluster_name}"
    }


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
