#!/bin/bash
JES_VERSION=0.2.2
JES_NAMESPACE="keptn-jes"
TASK_SUBSCRIPTION=sh.keptn.event.bar.triggered

helm upgrade --install --create-namespace -n ${JES_NAMESPACE} \
  job-executor-service https://github.com/keptn-contrib/job-executor-service/releases/download/${JES_VERSION}/job-executor-service-${JES_VERSION}.tgz \
  --set remoteControlPlane.autoDetect.enabled=true \
  --set remoteControlPlane.topicSubscription=${TASK_SUBSCRIPTION} \
  --set remoteControlPlane.api.token="" \
  --set remoteControlPlane.api.hostname="" \
  --set remoteControlPlane.api.protocol=""

if [[ "$SETUP_PROCEED" == 1 ]]; then
  ./create-project.sh demo ./configs/shipyard-singlestage.yaml
fi