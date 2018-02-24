# Copyright (c) 2015 Spinpunch, Inc. All Rights Reserved.
# See License.txt for license information.
FROM quay.io/gravitational/debian-grande:latest

# Add helm
ADD https://storage.googleapis.com/kubernetes-helm/helm-v2.8.1-linux-amd64.tar.gz /tmp
RUN cd /tmp && tar -xzf /tmp/helm-v2.8.1-linux-amd64.tar.gz && mv /tmp/linux-amd64/helm /usr/local/bin/ && rm /tmp/helm* && rm -rf /tmp/linux-amd64


