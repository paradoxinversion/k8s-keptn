#!/bin/bash
if [[ -z "$BASHRC" ]]; then
  echo "You have need to set BASHRC as an env var"
  exit 1
elif [[ -z "$1" || -z "$2" ]]; then
  echo "You have to pass PROJECTNAME and SERVICENAME as arguments"
  echo "usage: ./setup-prometheus.sh demo demo-svc"
  exit 1
else
  PROJECTNAME=$1
  SERVICENAME=$2

  keptn configure monitoring prometheus --project $PROJECTNAME --service $SERVICENAME
fi

