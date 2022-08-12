#!/bin/bash

UNAME_ARCH_RESULT="$(uname -m)"
if [[ "$UNAME_ARCH_RESULT" == "x86_64" ]]; then
  UNAME_ARCH_RESULT="amd64"
fi

export INSTALL_ARCH="$UNAME_ARCH_RESULT" # ie, x86_64, arm64
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
RC_FILE=
if [[ "$INSTALL_SHELL" == "zsh" ]]; then
  export RC_FILE=~/.zshrc
elif [[ "$INSTALL_SHELL" == "bash" ]]; then
  export RC_FILE=~/.bashrc
fi

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
  elif [[ "$INSTALL_SHELL" == "zsh" ]]; then
    source <(kubectl completion zsh)
    echo "source <(kubectl completion zsh)"
  fi
fi

# If the user is using Linux, use k3s, otherwise k3d
echo "Installing k3s kubernetes cluster, version $K8S_VERSION"
if [[ "$INSTALL_OS" == "linux" ]]; then
  curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v$K8S_VERSION+k3s1 K3S_KUBECONFIG_MODE="644" sh -s - --no-deploy=traefik
  export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
  echo "The k3s kubernetes cluster has been created and is accessible by running: export KUBECONFIG=/etc/rancher/k3s/k3s.yaml"
  echo "export KUBECONFIG=$KUBECONFIG" >> $RC_FILE
else
  K3D_TAG=5.0.0
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=v$K3D_TAG bash
fi

echo "export KUBECTL_VERSION=$KUBECTL_VERSION" >> $RC_FILE
echo "export K8S_VERSION=$K8S_VERSION" >> $RC_FILE

echo "The next script to run is ./install-helm.sh"

if [[ "$SETUP_PROCEED" == 1 ]]; then
  $WORKING_DIRECTORY/scripts/install/install-helm.sh
fi