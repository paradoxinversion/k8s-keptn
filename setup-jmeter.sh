#!/bin/bash

if [[ -z "$PROJECTNAME" ]]; then
  PROJECTNAME=$1
fi
if [[ -z "$SERVICENAME" ]]; then
  SERVICENAME=$2
fi
if [[ -z "$KEPTN_STAGE" ]]; then
  KEPTN_STAGE=$3
fi

if [[ -z "$PROJECTNAME" || -z "$SERVICENAME" || -z "$KEPTN_STAGE" ]]; then
  echo "You have to either set KEPTN_PROJECT, KEPTN_STAGE & KEPTN_SERVICE or pass them as arguments"
  echo "usage: ./add_resources.sh simplenodeproject staging simplenode [basic|perftest]"
  exit 1
fi

keptn add-resource --project=$PROJECTNAME --service=$SERVICENAME --stage=$KEPTN_STAGE --resource=jmeter/jmeter.conf.yaml --resourceUri=jmeter/jmeter.conf.yaml
keptn add-resource --project=$PROJECTNAME --service=$SERVICENAME --stage=$KEPTN_STAGE --resource=jmeter/basiccheck.jmx --resourceUri=jmeter/basiccheck.jmx
keptn add-resource --project=$PROJECTNAME --service=$SERVICENAME --stage=$KEPTN_STAGE --resource=jmeter/load.jmx --resourceUri=jmeter/load.jmx