Setting up an OpsCenter
===

Up-to-date Ops Center documentation is available at
[https://gravitational.com/docs/opscenter/](https://gravitational.com/docs/opscenter/).

Note: To use the provided terraform/opscenter.tf script you need to have
Terraform of version 0.10.7 or higher.

Usage
===

Enter the directory with the terraform script:

```bash
$ cd terraform
```

Generate certificate and private key:

```bash
$ openssl req -newkey rsa:2048 -nodes -keyout server.key -x509 -days 365 -out server.crt
```

Alternatively, you can supply your own `server.crt` and `server.key`.

Then, launch provisioning:

```bash
$ terraform init
$ terraform apply
```

It will provision a single node and install an Ops Center application on it.

To destroy infrastructure:

```bash
$ terraform destroy -force
```
