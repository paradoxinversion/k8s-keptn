#!/bin/bash

if [[ -z "$BASHRC" ]]; then
  echo "You have need to set BASHRC as an env var"
  exit 1
fi

sudo echo export ISTIO_VERSION=1.14.1 >> $BASHRC
sudo echo export LINUX_ARCHITECTURE=x86_64 >> $BASHRC
source $BASHRC

# Install Istio CLI
echo "Downloading Istio CLI version ${ISTIO_VERSION}, for architecture ${LINUX_ARCHITECTURE}"
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VERSION TARGET_ARCH=$LINUX_ARCHITECTURE sh -
sudo echo export ISTIOCTL=./istio-$ISTIO_VERSION/bin/istioctl >> $BASHRC
source $BASHRC

echo "Installing Istio into the cluster with default profile"
$ISTIOCTL install -y
echo "Sleeping for 10 seconds"
sleep 10s

echo "The next script to run is setup-keptn.sh"

