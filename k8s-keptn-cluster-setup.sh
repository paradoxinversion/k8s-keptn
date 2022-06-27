$K8S_VERSION=1.21.1
$KEPTN_VERSION=0.15.1
$ISTIO_VERSION=1.41.1
$LINUX_ARCHITECTURE=x86_64

# Install kubectl
echo "Downloading kubectl version ${K8S_VERSION}"
curl -LO https://dl.k8s.io/release/v$K8S_VERSION/bin/linux/amd64/kubectl
echo "Installing kubectl version ${K8S_VERSION}"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install helm
echo "Downloading Helm 3 installer"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
echo "Changing file permissions for ./get_helm.sh"
chmod 700 get_helm.sh
echo "Running ./get_helm"
./get_helm.sh

# Install Istio
echo "Downloading Istio version ${ISTIO_VERSION}, for architecture ${LINUX_ARCHITECTURE}"
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VERSION TARGET_ARCH=$LINUX_ARCHITECTURE sh -
echo "Downloading, running Keptn installer version ${KEPTN_VERSION}"
curl -sL https://get.keptn.sh | KEPTN_VERSION=$KEPTN_VERSION bash
