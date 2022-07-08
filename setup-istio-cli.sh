#!/bin/bash

BASHRC=~/.bashrc
source $BASHRC

ISTIO_VERSION=1.14.1
LINUX_ARCHITECTURE=x86_64

# Install Istio CLI
echo "Downloading Istio CLI version $ISTIO_VERSION, for architecture $LINUX_ARCHITECTURE"
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VERSION TARGET_ARCH=$LINUX_ARCHITECTURE sh -
ISTIOCTL=./istio-$ISTIO_VERSION/bin/istioctl

echo "Installing Istio into the cluster with default profile"
$ISTIOCTL install -y
echo "Sleeping for 10 seconds"
sleep 10s

echo "export ISTIO_VERSION=$ISTIO_VERSION" >> $BASHRC
echo "export LINUX_ARCHITECTURE=$LINUX_ARCHITECTURE" >> $BASHRC
echo "export ISTIOCTL=./istio-$ISTIO_VERSION/bin/istioctl" >> $BASHRC

echo "The next script to run is setup-keptn.sh"

