# K8s with Keptn

This repository seeks to reduce the amount of labor required to set up Keptn with Continuous Delivery and Multistage Deployment on a k8s cluster. There are two main scripts: `create-vm.ps1` and `k8s-keptn-cluster-setup.sh`.

# Prerequisites

## __Operating System__

Windows 10+ on Intel or AMD Architecture (Scripts are currently __untested__ on other systems/architectures)

## Software

### __Multipass__
Download & Install [Multipass](https://multipass.run)

### __Powershell__

We'll be running commands in [Powershell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.2), so that should be installed on your machine and running as __Administrator__

# Run the Scripts

The following steps were taken and code was created on a Windows 10 PC with the latest version of Multipass as of 6/28/2022.

## create-vm.ps1

This script handles creation of a multipass VM with baseline resources required for a Keptn installation. VM is launched with: the name k8s, 4 CPUs, 16G of memory, 20G of disk space on a bridged ethernet connection. 

We can confirm the VM has been properly created by running `multipass list`. Outptut should include our vm name and IPv4 address for the cluster. This is important, as we'll be binding/ingressing on this port.

```sh
Name                    State             IPv4             Image
k8s                     Running           172.24.152.27    Ubuntu 20.04 LTS
                                          10.0.0.114
```

We can enter our new VM by running `multipass shell k8s` in Powershell.

## k8s-keptn-cluster-setup.sh

This script handles _all_ k8s cluster setup for Keptn. The following walks through each step of the install script.

#### __Setup Env Vars__

Our script first sets up some basic environment variables used throughout the process.

```sh
K8S_VERSION=1.21.1
KEPTN_VERSION=0.15.1
ISTIO_VERSION=1.14.1
LINUX_ARCHITECTURE=x86_64
```

#### __Download and Install Kubectl__

To access Kubernetes, we'll need kubectl. Here, we specify version 1.21.1, which is within constrains for Keptn's k8s requirements. Using k8s versions that are too high or too low may cause problems.

```sh
curl -LO https://dl.k8s.io/release/v$K8S_VERSION/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

#### __Download and Install k3s cluster__

Download the specified k3s release and start the cluster. Then, export KUBECONFIG so we can use `kubectl`. 

```sh
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v$K8S_VERSION+k3s1 K3S_KUBECONFIG_MODE="644" sh -s - --no-deploy=traefik
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

> __We need to use `export KUBECONFIG=/etc/rancher/k3s/k3s.yaml` to access the k8s cluster after the script is finished running.__

#### __Download and install Helm CLI__

Download the Helm installer via curl and install.

```sh
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

#### __Download and install Istio CLI__

Similarly, download the Istio installer. Run it directly (instead of finagling PATH setup, etc).

```sh
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VERSION TARGET_ARCH=$LINUX_ARCHITECTURE sh -
./istio-$ISTIO_VERSION/bin/istioctl install -y
sleep 10s
```

> Without Istio, we'll be unable to make multi-stage  deployments.

#### __Download and install Keptn CLI, Install Keptn into the cluster__

Download and install the Keptn CLI. Then, install Keptn into the cluster.

```sh
curl -sL https://get.keptn.sh | KEPTN_VERSION=$KEPTN_VERSION bash
keptn install --use-case=continuous-delivery
```

#### __Setup Istio Ingress__

Here, we extract important Istio variables, INGRESS_HOST, INGRESS_PORT, SECURE_INGRESS_PORT, and TCP_INGRESS_PORT. The first two are the most important values for setting up the ingress. After setting up the environment variables, we check the INGRESS_HOST for a valid IP with which to set up the Ingress object. Next, we directly apply an ingress, using the INGRESS_HOST to create a host $INGRESS_HOST.nip.io. This is the web address we'll use to access keptn, for example `http://172.24.152.27.nip.io/api`

We then apply an istio Gateway, public-gateway.istio-service as a gateway to applications deployed with Kepth, allowing us to access them via urls like `http://demo-dev.demo-svc.172.24.152.27.nip.io`, if we have a Keptn project called demo and a deployed service called `demo-svc` in the `dev` stage. 
```sh
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
export TCP_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="tcp")].port}')

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

sleep 10s

kubectl create configmap -n keptn ingress-config --from-literal=ingress_hostname_suffix=$(kubectl -n keptn get ingress api-keptn-ingress -ojsonpath='{.spec.rules[0].host}') --from-literal=ingress_port=80 --from-literal=ingress_protocol=http --from-literal=istio_gateway=public-gateway.istio-system -oyaml --dry-run=client | kubectl apply -f -

kubectl delete pod -n keptn -lapp.kubernetes.io/name=helm-service
```

#### __Authenticate Keptn CLI and remove Keptn Bridge Authentication__

First we authenticate the Keptn CLI to allow us to use the command line to execute keptn commands within this script. __Note that we'll need to authenticate after we have connected to the cluster if we want to interact with Keptn after the script has run. Once the script stops running, the shell is no longer aware of kubectl or Keptn's authentication.__ 

Next, we disable the login for Keptn's bridge, for ease of use. While we want a secure bridge in production environments, for this demo, we will bypass bridge login completely by deleting the `secret bridge-credentials` and restarting the bridge. 

```sh
KEPTN_API_TOKEN=$(kubectl get secret keptn-api-token -n keptn -ojsonpath={.data.keptn-api-token} | base64 --decode)
KEPTN_ENDPOINT=http://$INGRESS_HOST.nip.io/api
keptn auth --endpoint=$KEPTN_ENDPOINT --api-token=$KEPTN_API_TOKEN
kubectl -n keptn delete secret bridge-credentials --ignore-not-found=true
kubectl -n keptn delete pods --selector=app.kubernetes.io/name=bridge --wait
```

#### __Get Helm chart for Service Deployment__

Keptn utilizes helm charts to deploy applications. This step downloads a chart for a containerized node app and packages it to be consumed by Keptn as a service resource.

```sh
git clone https://github.com/paradoxinversion/containerized-node-app-helm-chart.git
helm package containerized-node-app-helm-chart
```

#### __Set up a Project & Service in Keptn, and Trigger Deployment of the Service__

Here we create a project named demo with a service called demo-svc, which utilizes the containerized application docker.io/paradoxinversion/containerized-node-app. We then use the packaged helm chart we created in the previous step to add a resource to the service. Finally, we trigger a delivery of the application.

```sh
PROJECTNAME=demo
SERVICENAME=demo-svc
HELM_CHART=./demo-svc-0.1.0
keptn create project $PROJECTNAME --shipyard="./configs/shipyard.yaml"
keptn create service $SERVICENAME --project=$PROJECTNAME
keptn add-resource --project=$PROJECTNAME --service=$SERVICENAME --all-stages --resource=$HELM_CHART.tgz --resourceUri=helm/$SERVICENAME.tgz
keptn trigger delivery --project $PROJECTNAME --service $SERVICENAME --image docker.io/paradoxinversion/containerized-node-app
```

# Support

__Please note, there will likely be limited support for this repository. It's intended to make my personal and professional life easier, while being a starting point for other folks. Feel free to fork, but don't expect requests to be managed in a timely fashion__

# Acknlowedgements

Keptn's examples and demos have been a great help pulling together the scripts needed to make a one-shot setup.