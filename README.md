# Quick Start 

This guide will help you to release Kubernetes-Powered Private version of Mattermost

## Installation

### Requirements

This guide runs on Linux and Requires docker >= 1.8.x

Mattermost application consists of a worker process that connects to PostgreSQL instance.

### Gravity

```
curl https://gravitational.com/gravity/0.45 | sudo bash
```

(script should do this:

```
install -m 0755 /usr/local/bin/gravity
mkdir -p /var/lib/gravity
chown -R $(USER):$(USER) /var/lib/bravity
```

**Creating Mattermost Containers**

```
cd mattermost/worker
sudo docker build -t mattermost-worker:2.1.0 .
```

**Note:** Notice the `apiserver:5000` prefix. This is a private registry we've set up on our master server.


## Building Installable Version

* Connect to your Ops Center

Your OpsCenter is <companyname>.gravitational.io

```
gravity ops connect https://<companyname>.gravitational.io <username> <password>
```

* Import Application into Ops Center


```
gravity app import --vendor --ops-url=https://<companyname>.gravitational.io mattermost
```
