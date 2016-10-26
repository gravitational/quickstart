# Quick Start

This guide will help you to release Kubernetes-Powered Private version of Mattermost

## Installation

### Requirements

This guide runs on Linux and Requires docker >= 1.8.x
To verify that you have Docker running, try `docker info` before continuing.

Mattermost application consists of a worker process that connects to PostgreSQL instance.

### Gravity

```
curl https://gravitational.com/install | bash
```

Make sure it worked, by typing `gravity version`.

**Creating Mattermost Containers**

```
cd mattermost/worker
sudo docker build -t mattermost-worker:2.2.0 .
```

## Building Installable Version

* Connect to your Ops Center

Your OpsCenter is `companyname.gravitational.io`

You can use user email and password used to login into ops center.

```
gravity ops connect https://companyname.gravitational.io <email> <password>
```

* Import Application into Ops Center

```
gravity app import --vendor --ops-url=https://companyname.gravitational.io mattermost
```

Here's what it does:

* Scans Kubernetes resoureces for docker images
* Imports docker images from your local machine
* Publishes application to the ops center

## Installing application

### Using OpsCenter

You can launch AWS and OnPremise installs from the OpsCenter to quickly test new versions.
In this mode OpsCenter orchestrates the installation process.

To launch installer, click on "Install" button of the application, and follow the wizard instructions.


### Offline Mode

To test complete offline installation:

* click on "Download" link of the application.
* upload the installer to the server you wish to install
* tar -xf the installer tarball
* launch `./install` and follow wizard instructions.


