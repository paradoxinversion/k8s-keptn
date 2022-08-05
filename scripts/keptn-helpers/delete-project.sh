#!/bin/bash

if [[ -z "$1" ]]; then
  echo "You have to pass PROJECTNAME as arguments"
  echo "usage: ./setup-project.sh demo [./configs/shipyard.yaml]"
  exit 1
fi

# Setup Project
PROJECTNAME=$1
keptn delete project $PROJECTNAME