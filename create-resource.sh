#!/bin/bash

if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
  echo "You have to pass PROJECTNAME, SERVICENAME & HELM_CHART as arguments"
  echo "usage: ./setup-project.sh demo demo-svc ./demo-svc-0.1.0"
  exit 1
fi

keptn add-resource --project $PROJECTNAME --service $SERVICENAME --all-stages --resource $HELM_CHART.tgz --resourceUri helm/$SERVICENAME.tgz

exit 0