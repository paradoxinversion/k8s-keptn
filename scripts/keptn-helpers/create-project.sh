#!/bin/bash

if [[ -z "$1" ]]; then
  echo "You have to pass PROJECTNAME (optionally, shipyard) as arguments"
  echo "usage: ./setup-project.sh demo [./configs/shipyard.yaml]"
  exit 1
fi

# Setup Project
PROJECTNAME=$1
SHIPYARD=$2
keptn create project $PROJECTNAME --shipyard $SHIPYARD

if [[ "$SETUP_PROCEED" == 1 ]]; then
  $WORKING_DIRECTORY/scripts/keptn-helpers/create-service.sh demo demo-svc 0.1.0 
fi