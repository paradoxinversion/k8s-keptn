#!/bin/bash

echo "You have the option of automically proceeding to the next step after each script is complete. Would you like to do that?"
select ync in "Yes" "No" "Cancel"; do
    case $ync in
        Yes ) export SETUP_PROCEED=1; break;;
        No ) export SETUP_PROCEED=0; break;;
        Cancel ) break;;
    esac
done


if [[ "$SETUP_PROCEED" == "1" ]]; then
  echo "You have opted to proceed automatically"
else
  echo "You have opted to proceed manually. Take close note of the instructions after each step to ensure the best experience."
fi

# Set initial setup variables. We copy them here to .bashrc for easier reuse. Further env vars will be gathered and added to bashrc throughout the run of the script as necessary.
export BASHRC=~/.bashrc
export KUBECTL_VERSION=1.22.6
export K8S_VERSION=1.22.6

# Install kubectl
echo "Downloading kubectl version $KUBECTL_VERSION"
curl -Lo ~/kubectl https://dl.k8s.io/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl

echo "Installing kubectl version $KUBECTL_VERSION"
sudo install -o root -g root -m 0755 ~/kubectl /usr/local/bin/kubectl
echo "source <(kubectl completion bash)" >> ~/.bashrc

# Install k3s cluster
echo "Installing k3s kubernetes cluster, version $K8S_VERSION"
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v$K8S_VERSION+k3s1 K3S_KUBECONFIG_MODE="644" sh -s - --no-deploy=traefik
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
echo "The k3s kubernetes cluster has been created and is accessible by running: export KUBECONFIG=/etc/rancher/k3s/k3s.yaml"
echo "export KUBECTL_VERSION=$KUBECTL_VERSION" >> $BASHRC
echo "export K8S_VERSION=$K8S_VERSION" >> $BASHRC
echo "export KUBECONFIG=$KUBECONFIG" >> $BASHRC

echo "The next script to run is ./setup-helm.sh"

if [[ "$SETUP_PROCEED" == 1 ]]; then
  $WORKING_DIRECTORY/scripts/install/install-helm.sh
fi