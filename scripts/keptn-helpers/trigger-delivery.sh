#!/bin/bash

PROJECTNAME=$1
SERVICENAME=$2
IMAGE=$3
keptn trigger delivery --project $PROJECTNAME --service $SERVICENAME --image $IMAGE
