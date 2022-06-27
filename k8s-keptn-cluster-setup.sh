#!/bin/bash

K8S_VERSION=1.21.1
KEPTN_VERSION=0.15.1
ISTIO_VERSION=1.14.1
LINUX_ARCHITECTURE=x86_64

# Install kubectl
echo "Downloading kubectl version ${K8S_VERSION}"
curl -LO https://dl.k8s.io/release/v$K8S_VERSION/bin/linux/amd64/kubectl
echo "Installing kubectl version ${K8S_VERSION}"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install k3s cluster

curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v$K8S_VERSION+k3s1 K3S_KUBECONFIG_MODE="644" sh -s - --no-deploy=traefik
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml



# Install helm CLI
echo "Downloading Helm 3 installer"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
echo "Changing file permissions for ./get_helm.sh"
chmod 700 get_helm.sh
echo "Running ./get_helm"
./get_helm.sh

# Install Istio CLI
echo "Downloading Istio CLI version ${ISTIO_VERSION}, for architecture ${LINUX_ARCHITECTURE}"
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VERSION TARGET_ARCH=$LINUX_ARCHITECTURE sh -

echo "Installing Istio into the cluster with default profile"
./istio-$ISTIO_VERSION/bin/istioctl install -y
echo "Sleeping for 10 seconds"
sleep 10s

# Install Keptn CLI
echo "Downloading, running Keptn installer version ${KEPTN_VERSION}"
curl -sL https://get.keptn.sh | KEPTN_VERSION=$KEPTN_VERSION bash

echo "Installing Keptn into the cluster"
keptn install --use-case=continuous-delivery

echo "Getting Istio Ingress info"
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
export TCP_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="tcp")].port}')

# Check that ingress host info is valid
if [ -z "$INGRESS_HOST" ] || [ "$INGRESS_HOST" = "Pending" ] ; then
 	echo "Could not determine the external IP address of istio-ingressgateway in namespace istio-system. Please make sure it is ready and has an external IP address:"
 	echo " - kubectl -n istio-system get svc istio-ingressgateway"
 	echo ""
 	echo "Please consult the istio docs for more information: https://istio.io/latest/docs/tasks/traffic-management/ingress/ingress-control/#determining-the-ingress-ip-and-ports"
	exit 1
fi

echo "External IP for istio-gateway is $INGRESS_HOST, Creating keptn configmaps"
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: istio
  name: api-keptn-ingress
  namespace: keptn
spec:
  rules:
  - host: $INGRESS_HOST.nip.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-gateway-nginx
            port:
              number: 80
EOF

echo "Applying public gateway"
kubectl apply -f - <<EOF
---
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: public-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      name: http
      number: 80
      protocol: HTTP
    hosts:
    - '*'
EOF

echo "Sleeping for 10 seconds"
sleep 10s

#Create Keptn ingress config map
echo "Creating keptn ingress config map"
kubectl create configmap -n keptn ingress-config --from-literal=ingress_hostname_suffix=$(kubectl -n keptn get ingress api-keptn-ingress -ojsonpath='{.spec.rules[0].host}') --from-literal=ingress_port=80 --from-literal=ingress_protocol=http --from-literal=istio_gateway=public-gateway.istio-system -oyaml --dry-run=client | kubectl apply -f -

echo "Restarting helm service"
kubectl delete pod -n keptn -lapp.kubernetes.io/name=helm-service