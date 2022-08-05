#!/bin/bash

if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
  echo "You have to either set KEPTN_PROJECT, KEPTN_SERVICE & KEPTN_STAGE or pass them as arguments"
  echo "usage: ./setup-jmeter.sh demo demo-svc staging"
  exit 1
fi

PROJECTNAME=$1
SERVICENAME=$2
KEPTN_STAGE=$3

keptn add-resource --project=$PROJECTNAME --service=$SERVICENAME --stage=$KEPTN_STAGE --resource=../../jmeter/jmeter.conf.yaml --resourceUri=jmeter/jmeter.conf.yaml
keptn add-resource --project=$PROJECTNAME --service=$SERVICENAME --stage=$KEPTN_STAGE --resource=../../jmeter/basiccheck.jmx --resourceUri=jmeter/basiccheck.jmx
keptn add-resource --project=$PROJECTNAME --service=$SERVICENAME --stage=$KEPTN_STAGE --resource=../../jmeter/load.jmx --resourceUri=jmeter/load.jmx