#!/bin/bash

ISTIO_VERSION=1.14.1

# Install Istio CLI
echo "Downloading Istio CLI version $ISTIO_VERSION, for architecture $INSTALL_ARCH"
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VERSION TARGET_ARCH=$INSTALL_ARCH sh -
mv ./istio-$ISTIO_VERSION ~/istio-$ISTIO_VERSION
ISTIOCTL=~/istio-$ISTIO_VERSION/bin/istioctl

echo "Installing Istio into the cluster with default profile"
$ISTIOCTL install -y
echo "Sleeping for 10 seconds"
sleep 10s

echo "export ISTIO_VERSION=$ISTIO_VERSION" >> $RC_FILE
echo "export LINUX_ARCHITECTURE=$INSTALL_ARCH" >> $RC_FILE
echo "export ISTIOCTL=${ISTIOCTL}" >> $RC_FILE

echo "The next script to run is ./install-keptn.sh"

if [[ "$SETUP_PROCEED" == 1 ]]; then
  $WORKING_DIRECTORY/scripts/install/install-keptn.sh
fi