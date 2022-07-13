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

> The following steps were taken and code was created on a Windows 10 PC with the latest version of Multipass as of 6/28/2022.

> You will need administrator access in your Windows environment

Running these scripts will take place in a Powershell with Administrator privileges. On Windows 10, Powershell can be opened by typing "Windows Powershell" (or "Powershell") into the search bar, then right clicking the entry, and left clicking __Run As Administrator__ in the context menu.

## create-vm.ps1

Parameters

```
VM_NAME [DEBUG]
```

Usage

```
.\create-vm.ps1 -VM_NAME "k8s" [-DEBUG True]
```

This script handles creation of a multipass VM with baseline resources required for a Keptn installation. VM is launched with: the name $VM_NAME, 4 CPUs, 16G of memory, 20G of disk space on a bridged ethernet connection. 

We can confirm the VM has been properly created by running `multipass list`. Outptut should include our vm name and IPv4 address for the cluster. This is important, as we'll be binding/ingressing on this port.

```sh
Name                    State             IPv4             Image
k8s                     Running           172.24.152.27    Ubuntu 20.04 LTS
                                          10.0.0.114
```

We can enter our new VM by running `multipass shell k8s` in Powershell.

## remove-vm.ps1

Parameters

```
VM_NAME
```

Usage

```
.\remove -vm.ps1 -VM_NAME "k8s"
```

This script stops and deletes a virtual machine, then purges all deleted instances from multipass.

# Prepare the VM

> After running create-vm.ps1, run `multipass shell <vm-name>`

> You should be in the home folder of your VM

1. Clone the repo to your vm
```
git clone https://github.com/paradoxinversion/k8s-keptn.git
```
2. Make scripts executable in your virtual machine
```
sudo chmod +x -R ./k8s-keptn
```
3. Change your directory to the repository
```
cd ./k8s-keptn
```
4. Proceed with `setup-cluster.sh`

## setup-cluster.sh

Usage

```
. ./setup-cluster.sh
```

This script handles download and install of kubectl and k3s cluster. It should be run first. This script and others will add environment variables to your linux environment.

## setup-helm.sh

Usage

```
. ./setup-helm.sh
```

This script downloads and installs helm 3. Helm will be required to package helm charts for our microservices.

## setup-istio-cli.sh

Usage

```
. ./setup-istio-cli.sh
```

This script downloads istio and exports istioctl. It then installs istio into the cluster.

## setup-keptn

Usage

```
. ./setup-keptn.sh
```

This script installs the keptn control and execution plane into the cluster.

## configure-istio

Usage

```
. ./configure-istio.sh
```

This script configures ingress for keptn and a public gateway for deployed applications via istio.

## authenticate-keptn.sh

Usage

```
. ./authenticate-keptn.sh
```

This script authenticates the keptn cli and removes credentialing from the keptn bridge for demo purposes.

## create-project.sh

Parameters

```
PROJECTNAME [SHIPYARD]
```

Usage

```
. ./create-project.sh demo [./custom/path/to/shipyard.yaml]
```

This script creates a keptn project.

## create-service.sh

Parameters

```
PROJECTNAME SERVICENAME HELM_CHART_VERSION
```

Usage

```
. ./create-service demo demo-svc 0.1.0
```

This script checks for a helm chart definition at `./charts/$SERVICENAME` and fails early if it does not exists. It then checks for a helm chart at `./$SERVICENAME-$HELM_CHART_VERSION.tgz` and removes it if it exists. The chart is then packaged at that location, a keptn service is created, and the helm chart is applied via `keptn add-resource`.

## setup-jmeter.sh

Parameters

```
KEPTN_PROJECT KEPTN_SERVICE KEPTN_STAGE
```

Usage

```
. ./setup-jmeter.sh demo demo-svc hardening
```

This script adds jmeter resources `jmeter.conf.yaml`, `basiccheck.jmx`, and `load.jmx` via `keptn add-resource` to the supplied project, service, and stage.

# Support

__Please note, there will likely be limited support for this repository. It's intended to make my personal and professional life easier, while being a starting point for other folks. Feel free to fork, but don't expect requests to be managed in a timely fashion__

# Acknlowedgements

Keptn's examples and demos have been a great help pulling together the scripts needed to make a one-shot setup.