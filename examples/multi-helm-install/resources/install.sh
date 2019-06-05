#!/bin/sh

set -x

echo "Installing mattermost..."
/usr/local/bin/helm install /var/lib/gravity/resources/charts/mattermost --set registry=leader.telekube.local:5000/

echo "Installing node-problem-detector..."
/usr/local/bin/helm install /var/lib/gravity/resources/charts/consul --set image=leader.telekube.local:5000/consul

echo "Install Complete"