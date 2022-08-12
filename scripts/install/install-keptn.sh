#!/bin/bash

export KEPTN_VERSION=0.15.1
KEPTN_DOWNLOAD_FILENAME=keptn-$KEPTN_VERSION-$INSTALL_OS-$INSTALL_ARCH
# Install Keptn CLI
# Download the versioned release from github
# keptn-[version]-[OS]-[arch].tar.gz
echo "Downloading $KEPTN_DOWNLOAD_FILENAME"
curl -LO https://github.com/keptn/keptn/releases/download/$KEPTN_VERSION/$KEPTN_DOWNLOAD_FILENAME.tar.gz

# It needs to be unpacked
tar -xf $KEPTN_DOWNLOAD_FILENAME.tar.gz

# Moved it into our install location
mv $KEPTN_DOWNLOAD_FILENAME /usr/local/bin/keptn

# Use Helm to Install Keptn 
echo "Installing Keptn into the cluster"
helm install keptn https://github.com/keptn/keptn/releases/download/$KEPTN_VERSION/keptn-$KEPTN_VERSION.tgz -n keptn --create-namespace --wait --set=continuous-delivery.enabled=true
helm install helm-service https://github.com/keptn/keptn/releases/download/$KEPTN_VERSION/helm-service-$KEPTN_VERSION.tgz -n keptn --create-namespace --wait

echo "export KEPTN_VERSION=${KEPTN_VERSION}" >> $RC_FILE

echo "The next script to run is ./configure-istio.sh"

if [[ "$SETUP_PROCEED" == 1 ]]; then
  $WORKING_DIRECTORY/scripts/configure/configure-istio.sh
fi