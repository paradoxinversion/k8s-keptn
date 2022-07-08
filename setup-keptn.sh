#!/bin/bash

BASHRC=~/.bashrc
source $BASHRC

sudo echo export KEPTN_VERSION=0.15.1 >> $BASHRC
source $BASHRC

# Install Keptn CLI
echo "Downloading, running Keptn installer version ${KEPTN_VERSION}"
curl -sL https://get.keptn.sh | KEPTN_VERSION=$KEPTN_VERSION bash

echo "Installing Keptn into the cluster"
helm install keptn https://github.com/keptn/keptn/releases/download/$KEPTN_VERSION/keptn-$KEPTN_VERSION.tgz -n keptn --create-namespace --wait --set=continuous-delivery.enabled=true
helm install jmeter-service https://github.com/keptn/keptn/releases/download/$KEPTN_VERSION/jmeter-service-$KEPTN_VERSION.tgz -n keptn --create-namespace --wait

helm install helm-service https://github.com/keptn/keptn/releases/download/$KEPTN_VERSION/helm-service-$KEPTN_VERSION.tgz -n keptn --create-namespace --wait

echo "export KEPTN_VERSION=${KEPTN_VERSION}" >> $BASHRC

echo "The next script to run is configure-istio.sh"

