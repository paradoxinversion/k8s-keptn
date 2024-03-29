#!/bin/bash

if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
  echo "You have to pass PROJECTNAME, SERVICENAME, and HELM_CHART_VERSION as arguments"
  echo "usage: ./setup-project.sh demo demo-svc ./demo-svc 0.1.0 "
  exit 1
fi

PROJECTNAME=$1
SERVICENAME=$2
HELM_CHART_VERSION=$3
HELM_CHART=$WORKING_DIRECTORY/$SERVICENAME-$HELM_CHART_VERSION.tgz

if [[ ! -d "$WORKING_DIRECTORY/charts/$SERVICENAME" ]]; then
  echo "Chart directory $SERVICENAME does not exist."
  exit 1
fi

if [[ ! -f "$HELM_CHART" ]]; then
  rm $HELM_CHART
fi

helm package $WORKING_DIRECTORY/charts/$SERVICENAME

keptn create service $SERVICENAME --project $PROJECTNAME
keptn add-resource --project $PROJECTNAME --service $SERVICENAME --all-stages --resource $HELM_CHART --resourceUri helm/$SERVICENAME.tgz

if [[ "$SETUP_PROCEED" == 1 ]]; then
  $WORKING_DIRECTORY/scripts/keptn-helpers/trigger-delivery.sh demo demo-svc paradoxinversion/containerized-node-app
fi