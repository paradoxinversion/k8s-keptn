#!/bin/bash

if  [[ -z "$INGRESS_HOST" || -z "$INGRESS_PORT" ]]; then
  echo "You need to set INGRESS_HOST and INGRESS_PORT post as env vars. This is usually done during configure-istio.sh"
else
  # Install Prometheus
  PROMETHEUS_VERSION=0.8.1

  kubectl create namespace monitoring
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm install prometheus prometheus-community/prometheus --namespace monitoring --wait -f ./configs/prometheus-community-install.yaml

  cat <<EOF | kubectl apply -f -
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    annotations:
      kubernetes.io/ingress.class: istio
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

  helm upgrade --install -n keptn prometheus-service https://github.com/keptn-contrib/prometheus-service/releases/download/$PROMETHEUS_VERSION/prometheus-service-$PROMETHEUS_VERSION.tgz \
  --reuse-values \ 
  --set prometheus.createTargets=false \
  --set prometheus.createAlerts=false

  kubectl -n monitoring apply -f https://raw.githubusercontent.com/keptn-contrib/prometheus-service/$PROMETHEUS_VERSION/deploy/role.yaml

  echo "Prometheus is available at http://prometheus.$INGRESS_HOST.nip.io:$INGRESS_PORT"
fi


