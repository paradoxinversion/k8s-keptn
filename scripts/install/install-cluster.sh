#!/bin/bash

export INSTALL_ARCH="$(uname -i)" # ie, x86_64, arm64
export INSTALL_OS="$(uname | tr '[:upper:]' '[:lower:]')" # ie, darwin, linux
export INSTALL_SHELL=$(echo $SHELL | grep --only-matching "bash\|zsh") # ie, bash, zsh



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

if [[ "$INSTALL_OS" == "linux" ]]; then
  # If we're using linux, only amd64 can be used as the architecture type
  curl -Lo ~/kubectl https://dl.k8s.io/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl
else
  # If we're using darwin, it could be an Intel or Apple chip as 
  curl -Lo ~/kubectl https://dl.k8s.io/release/v$KUBECTL_VERSION/bin/darwin/$INSTALL_ARCH/kubectl
fi

echo "Installing kubectl version $KUBECTL_VERSION"
if [[ "$INSTALL_OS" == "linux" ]]; then
  sudo install -o root -g root -m 0755 ~/kubectl /usr/local/bin/kubectl
  echo "source <(kubectl completion bash)" >> ~/.bashrc
else
  chmod +x ~/kubectl
  sudo mv ./kubectl /usr/local/bin/kubectl
  sudo chown root: /usr/local/bin/kubectl

  # Skip Autocompletion setup on macos if the user is using bash
  if [[ "$INSTALL_OS" == "darwin" && "$INSTALL_SHELL" == "bash" ]]; then
    DARWIN_BASH_VERSION="$(echo $BASH_VERSION)"
    if [[ -z "$DARWIN_BASH_VERSION" ]]; then
      echo "Your bash version appears to be lower than 4.1. Skipping Kubectl autocompletion"
      echo "See details at: https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/#enable-shell-autocompletion"
    fi
    MAJOR_VERSION="$(echo ${DARWIN_BASH_VERSION:0:1})"
    MINOR_VERSION="$(echo ${DARWIN_BASH_VERSION:0:3})"
    # TODO: Aditional checking for proper version
  elif [[ "$INSTALL_SHELL" == "zsh" ]]; then
    source <(kubectl completion zsh)
    echo "source <(kubectl completion zsh)"
  fi
fi

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