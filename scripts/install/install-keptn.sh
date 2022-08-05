#!/bin/bash

export KEPTN_VERSION=0.15.1

# Install Keptn CLI
echo "Downloading, running Keptn installer version ${KEPTN_VERSION}"
curl -sL https://get.keptn.sh | KEPTN_VERSION=$KEPTN_VERSION bash

echo "Installing Keptn into the cluster"
helm install keptn https://github.com/keptn/keptn/releases/download/$KEPTN_VERSION/keptn-$KEPTN_VERSION.tgz -n keptn --create-namespace --wait --set=continuous-delivery.enabled=true
helm install helm-service https://github.com/keptn/keptn/releases/download/$KEPTN_VERSION/helm-service-$KEPTN_VERSION.tgz -n keptn --create-namespace --wait

echo "export KEPTN_VERSION=${KEPTN_VERSION}" >> $BASHRC

echo "The next script to run is ./configure-istio.sh"

if [[ "$SETUP_PROCEED" == 1 ]]; then
  $WORKING_DIRECTORY/scripts/configure/configure-istio.sh
fi