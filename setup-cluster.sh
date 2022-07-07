#!/bin/bash

# Set initial setup variables. We copy them here to .bashrc for easier reuse. Further env vars will be gathered and added to bashrc throughout the run of the script as necessary.
BASHRC=~/.bashrc
sudo echo export KUBECTL_VERSION=1.22.6 >> $BASHRC
sudo echo export K8S_VERSION=5.3.0 >> $BASHRC
source $BASHRC

# Install kubectl
echo "Downloading kubectl version ${KUBECTL_VERSION}"
curl -LO https://dl.k8s.io/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl
echo "Installing kubectl version ${KUBECTL_VERSION}"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install k3s cluster
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v$K8S_VERSION+k3s1 K3S_KUBECONFIG_MODE="644" sh -s - --no-deploy=traefik
sudo echo export KUBECONFIG=/etc/rancher/k3s/k3s.yaml >> $BASHRC
source $BASHRC

echo "The next script to run is setup-helm.sh"

