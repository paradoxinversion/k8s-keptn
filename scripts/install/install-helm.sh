#!/bin/bash

# Install helm CLI
echo "Downloading Helm 3 installer"
curl -fsSL -o ~/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
echo "Changing file permissions for ./get_helm.sh"
chmod 700 ~/get_helm.sh
echo "Running ./get_helm"
~/get_helm.sh

echo "The next script to run is ./setup-istio-cli.sh."

if [[ "$SETUP_PROCEED" == 1 ]]; then
  ./install-istio-cli.sh
fi