#!/bin/bash

# Install helm CLI
echo "Downloading Helm 3 installer"
curl -fsSL -o ~/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
echo "Changing file permissions for ./get_helm.sh"
chmod 700 ~/get_helm.sh
echo "Running ./get_helm"
~/get_helm.sh

if [[ "$INSTALL_OS" == "linux" && "$INSTALL_SHELL" == "bash" ]]; then
  source <(helm completion bash)
  helm completion bash > /etc/bash_completion.d/helm
elif [[ "$INSTALL_OS" == "darwin" && "$INSTALL_SHELL" == "zsh" ]]; then
  source <(helm completion zsh)
  helm completion zsh > "${fpath[1]}/_helm"
  # helm completion zsh # try uncommenting if there are issues
elif [[ "$INSTALL_OS" == "darwin" && "$INSTALL_SHELL" == "bash" ]]; then
  source <(helm completion bash)
  helm completion bash > /usr/local/etc/bash_completion.d/helm
fi

echo "The next script to run is ./setup-istio-cli.sh."

if [[ "$SETUP_PROCEED" == 1 ]]; then
  $WORKING_DIRECTORY/scripts/install/install-istio-cli.sh
fi