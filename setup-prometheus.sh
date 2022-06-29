#!/bin/bash
if [ -z "$PROJECTNAME" ]; then
 	echo "No PROJECTNAME var could be found. Please ensure it exists."
	exit 1
fi

if [ -z "$SERVICENAME" ]; then
 	echo "No SERVICENAME var could be found. Please ensure it exists."
	exit 1
fi
# Install Prometheus
sudo echo PROMETHEUS_VERSION=0.8.1 >> $BASHRC
sudo echo PROMETHEUS_EVALUATION_STAGE=hardening >> $BASHRC
source $BASHRC

kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/prometheus --namespace monitoring --wait

helm upgrade --install -n keptn prometheus-service https://github.com/keptn-contrib/prometheus-service/releases/download/$PROMETHEUS_VERSION/prometheus-service-$PROMETHEUS_VERSION.tgz --reuse-values
kubectl -n monitoring apply -f https://raw.githubusercontent.com/keptn-contrib/prometheus-service/$PROMETHEUS_VERSION/deploy/role.yaml
keptn configure monitoring prometheus --project $PROJECTNAME --service $SERVICENAME
# Add SLI Definitions
keptn add-resource --project $PROJECTNAME --stage=$PROMETHEUS_EVALUATION_STAGE --service $SERVICENAME --resource ./configs/sli-config-prometheus.yaml --resourceUri=prometheus/sli.yaml
# Set up quality gate
keptn add-resource --project $PROJECTNAME --stage=$PROMETHEUS_EVALUATION_STAGE --service=$SERVICENAME --resource ./configs/slo-quality-gates.yaml --resourceUri=slo.yaml