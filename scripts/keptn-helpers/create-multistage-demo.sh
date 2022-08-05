#!/bin/bash
# NOTE: Because of git upstream requirements, this script will not work with Keptn > 0.15.x
# This can be remedied by adding --git-user, --git-token, and --git-remote-url to keptn create project command
helm package ../../charts/demo-svc
keptn create project demo --shipyard ../../configs/shipyard-multistage.yaml
keptn create service demo-svc --project demo
keptn add-resource --project demo --service demo-svc --all-stages --resource ../../demo-svc-0.1.0.tgz --resourceUri helm/demo-svc.tgz

keptn configure monitoring prometheus --project demo --service demo-svc
cat <<EOF | kubectl apply -f -
kind: ConfigMap
apiVersion: v1
metadata:
  name: lighthouse-config-demo
  namespace: keptn
data:
  sli-provider: "prometheus"
EOF

keptn add-resource --project demo --stage staging --service demo-svc --resource ../../configs/sli-config-multistage.yaml --resourceUri prometheus/sli.yaml
keptn add-resource --project demo --service demo-svc --stage staging --resource ../../configs/slo.yaml --resourceUri slo.yaml
keptn trigger delivery --project demo --service demo-svc --image paradoxinversion/containerized-node-app:latest
