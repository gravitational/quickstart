Setting up an OpsCenter
===
An OpsCenter is a service that you can setup to provide a distribution point for your applications and dependant applications. Depending on how you choose to configure the service, it can retrieve updates from Gravitational's OpsCenter.

Pre-requisites
---
 - Login for [https://get.gravitational.io](https://get.gravitational.io)
 - Telekube binaries

Create a TLS certificate
---
The OpsCenter will use TLS to secure connections to it. In this repository are the files `example-server.crt` and `example-server.key` which hold the certificate and key to a self-signed certificate for `example.gravitational.io`. To deploy your own OpsCenter, you should create a certificate for your server. We recommend using a certificate signed by a trusted root authority, but you can use self-signed certificates if you wish.

Once you have a certificate, please place the PEM encoded certificate in this directory as `server.crt` and the PEM encoded key as `server.key`.

Generating a token
---
To connect your OpsCenter to `get.gravitational.io` to retrieve updates, you'll need an API token. Using the `tele` tool, you can quickly get one. First, login:

```
$ tele login -o get.gravitational.io
If browser window does not open automatically, open it by clicking on the link:
 https://accounts.google.com/o/oauth2/v2/auth?client_id=2...snip
Ops Center:	get.gravitational.io
Username:	meta@gravitational.io
Cluster:	N/A
Expires:	Wed Mar 29 11:48 UTC (19 hours from now)
```

Finally, using your authenticated session, generate an API token:

```
$ tele keys new
4340d6dbf469c13ba9ff56efccddffeb0ac1faf107fe99e49aa668ec85ec4e99%
```

We'll need to use this value in an environment variable named `TOKEN`, but for now you can store it in a file, or wherever is convenient.

Configuring OpsCenter
---
The last step prior to provisioning is creating a file with the full set of configuration. We've provided an example configuration for you in the file `example-opscenter.yaml`.

```
advertise_addr: <example.gravitational.io:443>
ssh_advertise_addr: <example.gravitational.io:33008>
tls:
  cert_file: /etc/gravitational/server.crt
  key_file: /etc/gravitational/server.key
oidc_connectors:
  - id: google
    redirect_url: https://<example.gravitational.io>/portalapi/v1/oidc/callback
    client_id: <example>.apps.googleusercontent.com
    client_secret: <secret>
    issuer_url: https://accounts.google.com
smtp:
  enabled: true
  password: <pass>
  username: username
  server: smtp.mailgun.org:587
users:
  # list of static users pre-configured for this portal
  - email: "admin@yourdomain.com"
    password: please-generate-it
    type: "admin"
    org: "yourdomain.com"
    identities:
      - connector_id: "google"
        email: "admin@yourdomain.com"
```

You'll need to create your own version of this file, with your own settings. Specifically, you'll need to provide the DNS names for `advertise_addr` and `ssh_advertise_addr` that you plan to use. You can leave the `tls` settings alone as we will use those paths on the server we provision.

To create a Google `oidc_connector` you'll need to [create the appropriate application credentials in Google's settings](https://developers.google.com/identity/protocols/OpenIDConnect). Be sure to specify the allowed callback URL in Google's settings as `https://<your chosen domain>/portalapi/v1/oidc/callback`.

You'll also need to specify SMTP settings if you wish to send email. Finally, you can specify an email and password for an admin user, who will be able to login with those credentials.

Once you've made your changes, save the file as `opscenter.yaml` in this directory.

Provisioning an OpsCenter
---
Included in this directory is configuration to provision a Vagrant VM, as well as an AWS instance to run your OpsCenter. Once you have created the required files above, you can provision one of your choices as follows:

- AWS: `make aws KEY_PAIR=<aws key name> TOKEN=<api token>`
- Vagrant: `make vagrant TOKEN=<api token>`

Manually provisioning
---
Instead of using the provided `Makefile` you can easily run the provisioning yourself by hand.

For AWS:
```
terraform apply -var key_pair=<your key pair name> -var provisioning_token=<API token> ./terraform
```

Or for Vagrant:
```
cd vagrant
export TOKEN=<your token>
vagrant up
```

Post-provisioning
---
Once provisioning is done, you'll need to point a DNS record for your chosen hostname at either the ELB load balancer that was created (for AWS) or the IP of your virtual machine (for Vagrant). Once the DNS record is configured, you should be able to sign in to your OpsCenter with your admin credentials, or configured OIDC connector.

Generating a self-signed TLS certificate
---
Here's  some information on [how to create your own self-signed certificate](http://www.akadia.com/services/ssh_test_certificate.html).
