#!/bin/bash

if [[ -z "$BASHRC" ]]; then
  echo "You have need to set BASHRC as an env var"
elif [[ -z "$INGRESS_HOST" ]]; then
  echo "You have need to set INGRESS_HOST as an env var"
elif [[ -z "$1" || -z "$2" || -z "$3" ]]; then
  echo "You have to pass PROJECTNAME, SERVICENAME, and HELM_CHART_VERSION as arguments"
  echo "usage: ./setup-project.sh demo demo-svc ./demo-svc 0.1.0 "
else
  
  PROJECTNAME=$1
  SERVICENAME=$2

  # Install Prometheus
  sudo echo PROMETHEUS_VERSION=0.8.0 >> $BASHRC
  sudo echo PROMETHEUS_EVALUATION_STAGE=hardening >> $BASHRC
  source $BASHRC

  kubectl create namespace monitoring
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm install prometheus prometheus-community/prometheus --namespace monitoring --wait

  cat <<EOF | kubectl apply -f -
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: prometheus-ingress
    namespace: monitoring
  spec:
    rules:
    - host: prometheus.$INGRESS_HOST.nip.io
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: prometheus-server
              port:
                number: 80
EOF

  helm upgrade --install -n keptn prometheus-service https://github.com/keptn-contrib/prometheus-service/releases/download/$PROMETHEUS_VERSION/prometheus-service-$PROMETHEUS_VERSION.tgz --reuse-values
  kubectl -n monitoring apply -f https://raw.githubusercontent.com/keptn-contrib/prometheus-service/$PROMETHEUS_VERSION/deploy/role.yaml

  echo "Prometheus is available at http://prometheus.$INGRESS_IP.nip.io:$INGRESS_PORT "
fi


