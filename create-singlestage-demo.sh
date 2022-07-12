#!/bin/bash
# NOTE: Because of git upstream requirements, this script will not work with Keptn > 0.15.x
# This can be remedied by adding --git-user, --git-token, and --git-remote-url to keptn create project command
helm package ./charts/demo-svc
keptn create project demo --shipyard ./configs/shipyard-singlestage.yaml
keptn create service demo-svc --project demo
keptn add-resource --project demo --service demo-svc --all-stages --resource ./demo-svc-0.1.0.tgz --resourceUri helm/demo-svc.tgz
keptn trigger delivery --project demo --service demo-svc --image paradoxinversion/containerized-node-app:latest