#!/bin/bash

if [[ -z "$1" ]]; then
  echo "You have to pass PROJECTNAME (optionally, shipyard) as arguments"
  echo "usage: ./setup-project.sh demo [./configs/shipyard.yaml]"
  exit 1
fi

if [[ "$2" == "" ]]; then
  SHIPYARD=./configs/shipyard.yaml
else
  SHIPYARD=$2
fi

# Setup Project
PROJECTNAME=$1

keptn create project $PROJECTNAME --shipyard $SHIPYARD

exit 0