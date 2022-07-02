#!/bin/bash

# Set initial setup variables. We copy them here to .bashrc for easier reuse. Further env vars will be gathered and added to bashrc throughout the run of the script as necessary.
BASHRC=~/.bashrc
sudo echo export K8S_VERSION=1.20.4 >> $BASHRC
sudo echo export KEPTN_VERSION=0.14.2 >> $BASHRC
sudo echo export ISTIO_VERSION=1.13.5 >> $BASHRC
sudo echo export LINUX_ARCHITECTURE=x86_64 >> $BASHRC

source $BASHRC
# Permanently add them to our .bashrc

# Install kubectl
echo "Downloading kubectl version ${K8S_VERSION}"
curl -LO https://dl.k8s.io/release/v$K8S_VERSION/bin/linux/amd64/kubectl
echo "Installing kubectl version ${K8S_VERSION}"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install k3s cluster
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v$K8S_VERSION+k3s1 K3S_KUBECONFIG_MODE="644" sh -s - --no-deploy=traefik

# Set our KUBECONFIG to use kubectl after cluster is created. Make it permanent for easy future access.
sudo echo export KUBECONFIG=/etc/rancher/k3s/k3s.yaml >> $BASHRC
source $BASHRC

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
sudo echo export ISTIOCTL=./istio-$ISTIO_VERSION/bin/istioctl >> $BASHRC
source $BASHRC

echo "Installing Istio into the cluster with default profile"
$ISTIOCTL install -y
echo "Sleeping for 10 seconds"
sleep 10s

# Install Keptn CLI
echo "Downloading, running Keptn installer version ${KEPTN_VERSION}"
curl -sL https://get.keptn.sh | KEPTN_VERSION=$KEPTN_VERSION bash

echo "Installing Keptn into the cluster"
# keptn install --use-case=continuous-delivery
helm install keptn https://github.com/keptn/keptn/releases/download/$KEPTN_VERSION/keptn-$KEPTN_VERSION.tgz -n keptn --create-namespace --wait --set=continuous-delivery.enabled=true
helm install jmeter-service https://github.com/keptn/keptn/releases/download/$KEPTN_VERSION/jmeter-service-$KEPTN_VERSION.tgz -n keptn --create-namespace --wait

helm install helm-service https://github.com/keptn/keptn/releases/download/$KEPTN_VERSION/helm-service-$KEPTN_VERSION.tgz -n keptn --create-namespace --wait


echo "Getting Istio Ingress info"
sudo echo export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}') >> $BASHRC
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}') >> $BASHRC
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}') >> $BASHRC
export TCP_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="tcp")].port}') >> $BASHRC
source $BASHRC

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

sudo echo KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -ojsonpath={.data.keptn-api-token} | base64 --decode) >> $BASHRC

sudo echo KEPTN_ENDPOINT=http://$INGRESS_HOST.nip.io/api >> $BASHRC
source $BASHRC

keptn auth --endpoint=$KEPTN_ENDPOINT --api-token=$KEPTN_API_TOKEN

kubectl -n keptn delete secret bridge-credentials --ignore-not-found=true

kubectl -n keptn delete pods --selector=app.kubernetes.io/name=bridge --wait



echo "Setup is complete, make k3s available on the command line via export KUBECONFIG=/etc/rancher/k3s/k3s.yaml"
echo "The Keptn endpoint can be found at $KEPTN_ENDPOINT"