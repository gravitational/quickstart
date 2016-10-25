# Quick Start 

This guide will help you to release Kubernetes-Powered Private version of Mattermost

## Installation

### Requirements

This guide runs on Linux and Requires docker >= 1.8.x

Mattermost application consists of a worker process that connects to PostgreSQL instance.

**Creating Mattermost Containers**

```
cd mattermost/worker
sudo docker build -t mattermost-worker:2.1.0 .
```

**Note:** Notice the `apiserver:5000` prefix. This is a private registry we've set up on our master server.


