# Introduction

The purpose of this Quick Start Guide is to help software vendors evaluate
Gravitational technology for packaging complex applications for private 
cloud deployments.

We will use [Mattermost](https://www.mattermost.org/), an open source Slack
clone, as an example application. Mattermost consists of a worker process that
connects to PostgreSQL instance.

## Prerequisites

Before we start, please take a look at [Telekube Overview](overview.md) to get
familiar with basic concepts of the Telekube system.

!!! warning "Important Notice":
    [Telekube Overview](overview.md) uses new commands for its examples, for
    the upcoming (not yet released) version of Telekube, while this tutorial
    uses legacy commands. This shouldn't prevent you from getting started.

## System Requirements

Telekube is a Linux-based system. By default we support 64-bit versions of the following
distributions:

* Ubuntu LTS
* Debian 8+
* RHEL/CentOS 7.2+

If you have a need to support a Linux distribution not listed above,
Gravitational offers Implementation Services that may be able to assist you.

Additionally, this guide requires `Docker` version 1.8 or newer. Run `docker
info` before continuing to make sure you have Docker up and running on your
system.

You will also need `git` to be able to download our sample code from Github.

## Gravity Tools

Telekube consists of three major components:

* `gravity`   : CLI tool which is used for packaging and publishing applications.
* `OpsCenter` : the Web UI for managing published applications and remotely
  accessing private cloud deployments.
* `teleport`  : SSH server for establishing secure SSH connections between the
  OpsCenter and the instances of an application running on private clouds.
  [Teleport](http://gravitational.com/teleport/) is a free open source tool
  developed, maintained and supported by Gravitational. It can be used
  independently from Telekube.

## Getting the Tools

Lets start by installing the `gravity` CLI tool onto your machine. You need to
have `sudo` priviliges (the installer will ask for `sudo` password). 

Run:

```
curl https://gravitational.com/install | bash
```

To make sure the installation succeeded, try typing `gravity version`.

## Sample App

To download the sample build scripts for Mattermost, please run:

```bash
$ git clone https://github.com/gravitational/quickstart.git
```

## Building Containers

Before an application can be packaged and published via Telekube, you need
to "containerize" it first. 

The sample project you have fetched via `git` above contains Docker files 
for Mattermost, as well as its Kubernetes resources.

```python
$ cd quickstart/mattermost/worker
$ docker build -t mattermost-worker:2.2.0 .
```

## Packaging Mattermost

To package an application, you have to connect to the `OpsCenter` first.
You should already have an account with Gravitational, usually it's running
on https://yourcompany.gravitational.io 

Additionally, you should have your OpsCenter credentials (email+password)
ready.

To login into to the Ops Center using the CLI:

```python
gravity ops connect https://yourcompany.gravitational.io <email> <password>
```

Publish the application into the OpsCenter:

```python
$ gravity app import --vendor --ops-url=https://companyname.gravitational.io mattermost
```

The command above does the following:

* Scans Kubernetes resoureces for the docker images.
* Packages the containers into a single deployable unit (tarball) while
  removing the duplicate Docker layers to minimize the size of the deployment
  (de-duplication).
* Publishes the application tarball to the Ops Center.

Now the application is ready to be distributed and installed into private clouds.

## Installing the Application

As covered in the [Overview](overview.md), there are two ways to install an 
application packaged with Telekube:

* Online, via the OpsCenter.
* Offline, via a downloadable tarball.

## Online Installer

This method of installation is called [the online
mode](overview/#online-installer) and it assumes that the end user (a person
installing the application) has access to the Internet.

The simplest way to launch an online installer is to login into the Ops Center
and click on "Install" dropdown for the published application.

## Offline Mode

To test complete offline installation:

* Click on "Download" link of the application.
* Upload the installer to the server you wish to install.
* Unpack the tarball via `tar -xzf <tarball.tar.gz>` into a Linux machine.
* Launch `./install` CLI command and follow wizard instructions.

The installer will copy itself to additional cluster nodes if needed.

## Conclusion

This is, in a nutshell, how publishing and distributing an application looks
like on Telekube.

