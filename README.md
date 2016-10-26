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
sudo docker build -t mattermost-worker:2.1.0 .
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

## Using application

Login to the ops center, and use it to install on AWS or OnPremise!
